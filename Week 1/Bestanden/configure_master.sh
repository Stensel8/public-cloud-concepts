#!/bin/bash
# Kubernetes Master Node setup script
# Ubuntu 25.10 (Questing) — containerd v2.x — Kubernetes v1.35 — Flannel CNI
set -e

echo "=== [1/10] System update ==="
sudo apt-get update && sudo apt-get upgrade -y

echo "=== [2/10] Kernel modules ==="
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

echo "=== [3/10] Kernel parameters ==="
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

echo "=== [4/10] Install containerd ==="
sudo apt-get install -y containerd

echo "=== [5/10] Configure containerd (systemd cgroup) ==="
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null

# Patch SystemdCgroup — works for both containerd v1 and v2 config formats
sudo python3 << 'PYEOF'
content = open('/etc/containerd/config.toml').read()
if 'SystemdCgroup = false' in content:
    content = content.replace('SystemdCgroup = false', 'SystemdCgroup = true')
    print("Replaced SystemdCgroup = false -> true")
elif 'SystemdCgroup = true' in content:
    print("SystemdCgroup already set to true")
else:
    # containerd v2.x: field absent, add it under runc options
    marker = "[plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc.options]"
    if marker in content:
        content = content.replace(marker, marker + "\n            SystemdCgroup = true")
        print("Added SystemdCgroup = true (containerd v2.x)")
    else:
        print("WARNING: Could not locate runc options section — check config.toml manually")
open('/etc/containerd/config.toml', 'w').write(content)
PYEOF

sudo systemctl restart containerd
sudo systemctl enable containerd

echo "=== [6/10] Install gnupg + Kubernetes packages (v1.35) ==="
sudo apt-get install -y gnupg curl

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /" \
    | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "=== [7/10] Disable swap ==="
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "=== [8/10] Enable kubelet ==="
sudo systemctl enable kubelet
sudo systemctl start kubelet

echo "=== [9/10] Initialize Kubernetes cluster ==="
# 10.244.0.0/16 is required for Flannel CNI
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

echo "=== [9b/10] Configure kubeconfig ==="
# For root
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config

# Also for the user who invoked sudo (so kubectl works without sudo)
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    mkdir -p "$USER_HOME/.kube"
    cp /etc/kubernetes/admin.conf "$USER_HOME/.kube/config"
    chown "$SUDO_USER:$SUDO_USER" "$USER_HOME/.kube/config"
    echo "kubeconfig configured for $SUDO_USER at $USER_HOME/.kube/config"
fi

echo "=== [10/10] Install Flannel CNI ==="
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

echo ""
echo "============================================"
echo "  Master node setup complete!"
echo "============================================"
echo ""
echo "Run the following command on each worker node:"
echo ""
kubeadm token create --print-join-command
echo ""
echo "After workers have joined, verify with:"
echo "  kubectl get nodes"
echo "  kubectl get pods -n kube-system"
