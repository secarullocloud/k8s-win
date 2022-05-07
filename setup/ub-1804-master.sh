#!/bin/bash

POD_NETWORK_CIDR="10.244.0.0/16"
SERVICE_CIDR="10.96.0.0/12"
KUBERNETES_VERSION="1.23.5"

# initialise Kube

kubeadm init --pod-network-cidr=$POD_NETWORK_CIDR --service-cidr=$SERVICE_CIDR

# install Flannel pod network (https://github.com/flannel-io/flannel)
wget https://raw.githubusercontent.com/secarullocloud/k8s-win/main/setup/flannel/kube-flannel.yml

kubectl --kubeconfig='/etc/kubernetes/admin.conf' apply -f kube-flannel.yml

# check cluster
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl get nodes

# export config to vagrant host
# scp -i ./.vagrant/machines/default/virtualbox/private_key -r -P2222 vagrant@127.0.0.1:/home/vagrant/somefolder ./


# Add Windows Flannel and kube-proxy DaemonSets
curl -L https://github.com/kubernetes-sigs/sig-windows-tools/releases/latest/download/kube-proxy.yml | sed 's/VERSION/v$KUBERNETES_VERSION/g' | kubectl apply -f -
kubectl apply -f https://github.com/kubernetes-sigs/sig-windows-tools/releases/latest/download/flannel-overlay.yml