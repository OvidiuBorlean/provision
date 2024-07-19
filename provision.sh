#!/bin/bash

install_azure_cli () {
   echo 'Installing Azure CLI - latest'
   sudo apt-get update
   sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release
   sudo mkdir -p /etc/apt/keyrings
   curl -sLS https://packages.microsoft.com/keys/microsoft.asc |
   gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
   sudo chmod go+r /etc/apt/keyrings/microsoft.gpg
   AZ_DIST=$(lsb_release -cs)
   echo "Types: deb
   URIs: https://packages.microsoft.com/repos/azure-cli/
   Suites: ${AZ_DIST}
   Components: main
   Architectures: $(dpkg --print-architecture)
   Signed-by: /etc/apt/keyrings/microsoft.gpg" | sudo tee /etc/apt/sources.list.d/azure-cli.sources
   sudo apt-get update
   sudo apt-get install azure-cli
}

install_kubectl () {

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x ./kubectl && sudo mv ./kubectl /usr/sbin
}


install_eksctl () {
    # for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
    ARCH=amd64
    PLATFORM=$(uname -s)_$ARCH
    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
    # (Optional) Verify checksum
    curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check
    tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
    sudo mv /tmp/eksctl /usr/local/bin
}

install_aws_cli () {
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
}

install_istioctl () {
     curl -sL https://istio.io/downloadIstioctl | sh -
    sudo mv $HOME/.istioctl/bin /usr/sbin 
    export PATH=$HOME/.istioctl/bin:$PATH
}

install_argocd_cli () {
  ARGOCD_VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
  curl -sSL -o /tmp/argocd-${ARGOCD_VERSION} https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64
  chmod +x /tmp/argocd-${VERSION}
  sudo mv /tmp/argocd-${VERSION} /usr/local/bin/argocd 
}

install_k9s () {
    VERSION=v0.32.5
    curl -sSL -o ./k9s https://github.com/derailed/k9s/releases/download/$VERSION/k9s_Linux_amd64.tar.gz
    sudo mv ./k9s /usr/sbin
}

install_krew () {
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
  echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> $HOME/.bashrc
}

install_helm () {
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    sudo apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm

}

install_utils () {
    apt update && apt install git yq 
}

install_mkcert () {
    curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
    chmod +x mkcert-v*-linux-amd64
    sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert
}

install_kind () {
    # For AMD64 / x86_64
    [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
    # For ARM64
    [ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-arm64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
}

install_kubelogin () {
    VERSION="v0.1.4"
    curl -o lubelogin.zip https://github.com/Azure/kubelogin/releases/download/$VERSION/kubelogin-linux-amd64.zip && unzip ./kubelogin-linux-amd64.zip
    sudo mv ./kubelogin /usr/sbin
}

install_docker () {
    curl -o getdocker.sh https://get.docker.com/ && chmod +x ./getdocker.sh && ./getdocker
}

install_podman () {
    curl -o podman.tar.gz https://github.com/containers/podman/releases/download/v5.1.2/podman-remote-static-linux_amd64.tar.gz
    tar zxvf ./podman.tar.gz
}

install_oc () {
    
}


