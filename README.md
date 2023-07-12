# kubernetes-terraform
IAC with Terraform for k8s deployment using DigitalOcean provider

### Infos

SSH public keys and installation scripts are both remote resources because they are susceptible to change.

Will add support for more nodes in future commits

```sh
# public key
# https://cdn.abderraziq.com/k8s/id_rsa.pub
# Installation script
# https://cdn.abderraziq.com/k8s/init.sh


#!/bin/bash
# update apt and download k8s & containerd
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl containerd.io
sudo apt-mark hold kubelet kubeadm kubectl

mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
# enable full support of systemd cgroups, otherwise k8s containers will keep crashing
sudo sed -i "s|SystemdCgroup = false|SystemdCgroup = true|g" /etc/containerd/config.toml
sudo sed -i "s|registry.k8s.io/pause:3.6|registry.k8s.io/pause:3.9|g" /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

kubeadm init --pod-network-cidr=10.244.0.0/16

echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >>~/.bashrc

source ~/.bashrc
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

echo 'Done, to start using kubectl in this terminal source the bashrc file'

```
