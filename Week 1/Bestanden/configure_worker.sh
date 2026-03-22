#!/bin/bash
# Kubernetes Worker Node setup script
# Ubuntu 25.10 (Questing) — containerd v2.x — Kubernetes v1.35
# After running this script, execute the 'sudo kubeadm join ...' command from the master.
set -e

echo "=== [1/8] System update ==="
sudo apt-get update && sudo apt-get upgrade -y

echo "=== [2/8] Kernel modules ==="
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

echo "=== [3/8] Kernel parameters ==="
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

echo "=== [4/8] Install containerd ==="
sudo apt-get install -y containerd

echo "=== [5/8] Configure containerd (systemd cgroup) ==="
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

echo "=== [6/8] Install gnupg + Kubernetes packages (v1.35) ==="
sudo apt-get install -y gnupg curl

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /" \
    | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "=== [7/8] Disable swap ==="
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "=== [8/8] Enable kubelet ==="
sudo systemctl enable kubelet
sudo systemctl start kubelet

echo ""
echo "============================================"
echo "  Worker node setup complete!"
echo "============================================"
echo ""
echo "Now join this node to the cluster by running the"
echo "'sudo kubeadm join ...' command from the master."
echo "(Get it on master with: kubeadm token create --print-join-command)"
