---
title: "Bestanden"
weight: 3
---

Alle scripts en configuratiebestanden die gebruikt zijn voor Week 1. De broncode staat op [GitHub](https://github.com/Stensel8/public-cloud-concepts/tree/main/static/docs/week-1/bestanden).

<a href="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week1.yml" target="_blank" rel="noopener noreferrer"><img src="https://github.com/Stensel8/public-cloud-concepts/actions/workflows/ci_week1.yml/badge.svg" alt="CI Week 1" style="display:inline;vertical-align:middle;" /></a>

---

## configure\_master.sh

Script om de Kubernetes **masternode** in te richten op Ubuntu 25.10. Het script doorloopt tien stappen: systeemupdates, kernelmodules, containerd installeren en configureren (inclusief `SystemdCgroup = true` via een Python patch die werkt voor zowel containerd v1 als v2), Kubernetes v1.35-pakketten installeren, swap uitschakelen, `kubeadm init` uitvoeren en tot slot Flannel installeren.

```bash
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

sudo python3 << 'PYEOF'
content = open('/etc/containerd/config.toml').read()
if 'SystemdCgroup = false' in content:
    content = content.replace('SystemdCgroup = false', 'SystemdCgroup = true')
elif 'SystemdCgroup = true' not in content:
    marker = "[plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc.options]"
    if marker in content:
        content = content.replace(marker, marker + "\n            SystemdCgroup = true")
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
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

echo "=== [9b/10] Configure kubeconfig ==="
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    mkdir -p "$USER_HOME/.kube"
    cp /etc/kubernetes/admin.conf "$USER_HOME/.kube/config"
    chown "$SUDO_USER:$SUDO_USER" "$USER_HOME/.kube/config"
fi

echo "=== [10/10] Install Flannel CNI ==="
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

kubeadm token create --print-join-command
```

---

## configure\_worker.sh

Script om een **workernode** in te richten. Doet dezelfde stappen als het master-script (stappen 1-8), maar voert geen `kubeadm init` uit. Na het uitvoeren van dit script kopieer je het `kubeadm join ...` commando van de master om de node aan het cluster toe te voegen.

```bash
#!/bin/bash
# Kubernetes Worker Node setup script
# Ubuntu 25.10 (Questing) — containerd v2.x — Kubernetes v1.35
set -e

# Stappen 1-8 identiek aan configure_master.sh (update, modules, containerd, kubernetes pakketten, swap uit)
# ...

echo "Worker node setup complete!"
echo "Voer nu het 'sudo kubeadm join ...' commando uit van de master."
echo "(Ophalen op master: kubeadm token create --print-join-command)"
```

---

## AUTOSTART-configure\_classic\_sudo.sh

GCP startup-script dat bij elke opstart klassieke `sudo` installeert ter vervanging van `sudo-rs`. Ubuntu 25.10 wordt standaard geleverd met `sudo-rs` (versie 0.2.8), dat een bekende sessiebug heeft waardoor `sudo reboot` mislukt.

---

## Dockerfile

```dockerfile
FROM nginx:1-alpine-slim

RUN apk upgrade --no-cache

COPY static-site/ /usr/share/nginx/html/
COPY nginx-default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

De Alpine-variant is bewust gekozen: ~5 MB versus ~180 MB voor de Debian-variant. Kleiner aanvalsoppervlak en snellere pull-tijden.

---

## deployment.yml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: first-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-container
  template:
    metadata:
      labels:
        app: my-container
    spec:
      containers:
      - name: my-container
        image: stensel8/public-cloud-concepts:latest
        ports:
        - containerPort: 80
```

---

## service.yml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: first-service
spec:
  type: LoadBalancer
  selector:
    app: my-container
  ports:
    - port: 80
      targetPort: 80
```
