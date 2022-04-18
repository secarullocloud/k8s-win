#!/bin/bash

POD_NETWORK_CIDR="10.244.0.0/16"
SERVICE_CIDR="10.96.0.0/12"

# initialise Kube

kubeadm init --pod-network-cidr=$POD_NETWORK_CIDR --service-cidr=$SERVICE_CIDR

# install Flannel pod network (https://github.com/flannel-io/flannel)
# wget https://raw.githubusercontent.com/secarullocloud/k8s-win/main/setup/flannel/kube-flannel-hybrid.yaml
wget https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
# wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml


kubectl --kubeconfig='/etc/kubernetes/admin.conf' apply -f kube-flannel.yml

# check cluster
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl get nodes