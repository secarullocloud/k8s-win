#!/bin/bash

# DOCKER_VERSION="5:20.10.14~3-0~ubuntu-bionic"
DOCKER_VERSION="5:20.10.9~3-0~ubuntu-bionic"
KUBERNETES_VERSION="1.23.5-00"

# turn off swap - for the Kubelet
swapoff -a 
sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

# install Docker 20.10 (https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)
apt-get update
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y \
    docker-ce=$DOCKER_VERSION \
    docker-ce-cli=$DOCKER_VERSION \
    containerd.io

# Cgroup drivers (https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cgroup-drivers)
# on every node exec
echo '{"exec-opts": ["native.cgroupdriver=systemd"]}' >> /etc/docker/daemon.json
systemctl restart docker

# install Kubeadm 1.23.5 
apt-get update
apt-get install -y apt-transport-https
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y \
    kubelet=$KUBERNETES_VERSION \
    kubeadm=$KUBERNETES_VERSION \
    kubectl=$KUBERNETES_VERSION
apt-mark hold kubelet kubeadm kubectl

# set iptables for Flannel
# sysctl net.bridge.bridge-nf-call-iptables=1
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system


# Manage Docker as a non-root user
usermod -aG docker vagrant