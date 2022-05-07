$KUBERNETES_VERSION="1.23.5"

Start-Service docker  

curl.exe -LO https://raw.githubusercontent.com/kubernetes-sigs/sig-windows-tools/master/kubeadm/scripts/PrepareNode.ps1
.\PrepareNode.ps1 -KubernetesVersion v$KUBERNETES_VERSION