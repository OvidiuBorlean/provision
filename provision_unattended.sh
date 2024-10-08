#!/bin/bash

exists()
{
  command -v "$1" >/dev/null 2>&1
}

install_azure_cli () {
   echo "---> Azure CLI Installation"
   AZ_DIST=$(lsb_release -cs)
   AZ_VER="2.64.0"
   #command -v az >/dev/null 2>&1
   if exists az; then
      echo "Az CLI exists"
   fi 
   if [ "$1" == true ]  || [ ! $(which az) ]; then
        echo 'Installing Azure CLI - latest'
        sudo apt-get update -y
        sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y
        sudo mkdir -p /etc/apt/keyrings
        curl -sLS https://packages.microsoft.com/keys/microsoft.asc |
            gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
        sudo chmod go+r /etc/apt/keyrings/microsoft.gpg
        echo "Types: deb
URIs: https://packages.microsoft.com/repos/azure-cli/
Suites: ${AZ_DIST}
Components: main
Architectures: $(dpkg --print-architecture)
Signed-by: /etc/apt/keyrings/microsoft.gpg" | sudo tee /etc/apt/sources.list.d/azure-cli.sources
        echo "Updating repos"
        sudo apt-get update -y
        sudo apt-get install azure-cli=${AZ_VER}-1~${AZ_DIST} -y
        sudo apt-mark hold azure-cli
        #az extension add --name accounts
        #az extension add --name azure-devops``
    else
      echo "Exit Azure CLI Function"
fi


 }

install_kubectl () {
    echo "---> Kubectl Installation"
    version="v1.31.0"
    echo "Checking for existing kubectl installation"
    if exists kubectl; then
       echo "kubectl already installed"
    fi
    if [ "$1" == true ]  || [ ! $(which kubectl) ]; then
       echo "Installing kubectl binary"
       curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
       sudo chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl && sudo chmod +x /usr/local/bin/kubectl
    else
      echo "Abort kubectl installation"
fi
}

install_eksctl () {
    # In Work
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
    echo "---> Helm Installation"
    version="v3.16.1"
    if exists helm; then
      echo "Helm already installed"
    fi
    if [ "$1" == true ]  || [ ! $(which helm) ]; then
      wget https://get.helm.sh/helm-$version-linux-amd64.tar.gz
      tar -zxvf helm-$version-linux-amd64.tar.gz
      sudo mv ./linux-amd64/helm /usr/sbin/helm
      rm -rf ./inux-amd64
      rm helm-$version-linux-amd64.tar.gz
   else
     echo "Exit Helm Installation"
   fi

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
    version="v0.1.4"
    sudo apt update && sudo apt install unzip -y 
    echo "Checking for existing kubelogin"
    if  kubelogin  >/dev/null 2>&1; then
       current_kubelogin_version=$(kubelogin --version)
        echo "kubelogin is installed $current_kubelogin_version"
    fi
    if [ "$1" == true ]  || [ ! $(which kubelogin) ]; then   
        echo "Install/Reinstall kubelogin"
        wget https://github.com/Azure/kubelogin/releases/download/$version/kubelogin-linux-amd64.zip
        unzip ./kubelogin-linux-amd64.zip
        sudo mv -f ./bin/linux_amd64/kubelogin /usr/sbin/kubelogin
        
    fi
}

install_docker () {
  #curl -o getdocker.sh https://get.docker.com/ && chmod +x ./getdocker.sh && ./getdocker
  sudo apt-get update
  sudo apt-get install docker.io -y
  sudo usermod -aG docker atx-admin
  sudo touch /etc/docker/daemon.json
  # Configuring Docker to not use the 172.17.0.0 and higher range, which would overlap with  MUC network (172.20.0.0/16)
  # Details, see: https://serverfault.com/questions/916941/configuring-docker-to-not-use-the-172-17-0-0-range
  sudo chmod 666 /etc/docker/daemon.json
  sudo echo '{ "default-address-pools": [ {"base":"10.10.0.0/16","size":24} ] }' | jq > /etc/docker/daemon.json
 
  # Restart Docker daemon
  sudo systemctl restart docker
}

install_podman () {
    curl -o podman.tar.gz https://github.com/containers/podman/releases/download/v5.1.2/podman-remote-static-linux_amd64.tar.gz
    tar zxvf ./podman.tar.gz
}

install_oc () {
  fileName="~/oc.tar"
  echo "Installing oc binary"   
  tar xvf $fileName
  sudo mv ~/oc /usr/sbin
  rm $fileName
}

install_node () {
  sudo apt install -y nodejs
  sudo apt install -y npm
 }

install_java () {
  echo "---> Installing Java"
  version="openjdk-17-jdk"
  echo "Checking for existing Java installation"
  if  java --version  >/dev/null 2>&1; then
      current_java_version=$(java --version)
      echo "Java already installed $current_java_version"
  fi   
  if [ "$1" == true ]  || [ ! $(which java) ]; then 
    echo "Install/Reinstall Java"
    sudo apt install $version -y
    sudo apt-mark hold $version    
    echo "Done install Java"
  fi
}

install_terraform () {
    echo "Installing Terraform"
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
    wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
    gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update
    sudo apt-get install terraform
}

install_terragrunt () {
    version="v0.67.4"
    echo "Installing Terragrunt binary"
    wget -P /tmp https://github.com/gruntwork-io/terragrunt/releases/download/$version/terragrunt_linux_amd64
    sudo chmod +x /tmp/terragrunt_linux_amd64
    echo "Moving"
    sudo mv terragrunt_linux_amd64 /usr/sbin/terragrunt
    echo "Done"
}

devops_agent () {
  #systemctl status | grep -i [v]sts.agent
  if [ -z "$1" ]
    then
      echo "Agent Name needs to be suplied"
      exit 1
   fi

   if [ -z "$2" ]
    then
      echo "Pool Name needs to be suplied"
      exit 1
   fi

   agent_version="3.243.1"
   token=""
   #poolname="akspool"
   #agentname="vm-devopeagent01-36"
   agentname=$1
   poolname=$2
   operation=$3
   echo "Checking for exising agent installation and version"
   #current_agent_version=${/opt/$agentname/bin/Agent.Listener --version}
   #if [ "current_agent_version" = "$agent_version" ]; then
   #  echo "Currently there is same Agent version installed"
   #  exit
   #fi

   echo "Installing DevOps Agent"
   cd /opt
   sudo mkdir -p $agentname
   sudo chown atx-admin:atx-admin $agentname
   cd $agentname
   wget https://vstsagentpackage.azureedge.net/agent/$agent_version/vsts-agent-linux-x64-$agent_version.tar.gz
   # extract File
   tar zxvf vsts-agent-linux-x64-$agent_version.tar.gz
   # start config
   echo "Starting configuration of Azure DevOps Agent"
   ./config.sh --unattended --url https://dev.azure.com/xcloud --auth pat --token $token --pool $poolname --agent $agentname --acceptTeeEula
   # install server
   sudo ./svc.sh install
   # start service
   sudo ./svc.sh start
   echo "Done Installing DevOps Agent"
}

devops_agent_remove () {
  echo "Remove an exiting agent"
  agentname=$1
  if [ -z "$1" ]
    then
      echo "Agent Name needs to be suplied"
      exit 1
   fi
   cd /opt/$agentname
   sudo ./svc.sh stop
   sudo ./svc.sh uninstall
   ./config.sh remove
  sudo rm -rf /opt/$agentname
}

x_devops_config () {
  
    echo "---> X Devops Config - Start"
    echo "Adding DNS Suffix"
    # This could not be written, eventually needs to be added in the interface configuration file
    #sudo echo "Domains=azp.xcloud.com de.xcloud.com ch.xcloud.com" >> /etc/systemd/resolved.conf
    
    #echo "Restarting daemon"
    #sudo systemctl restart systemd-resolved
    
    echo "Modifying Git"
    echo "   name = CI/CD pipeline" >> ~/gitconfig
    echo "   email = monitoring.cloud.solution@x.com" >> ~.gitconfig
    
    echo "Adding SWAP space"
    
    sudo fallocate -l 4G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

    echo "SSH Configuration"
    chmod 700 ~/.ssh
    echo 'ServerAliveInterval 60' | tee -a ~/.ssh/config
    echo 'ServerAliveCountMax 720' | tee -a ~/.ssh/config
    
    locale -m
    echo "X Devops Config - End"
}


linux_common_packages () {
    
    echo "---> Installing Linux Common Packages - Start"
    sudo apt -y install apache2-utils
    sudo apt-get -y install zip
    sudo apt -y install nfs-common
    sudo apt-get -y install sshpass
    echo "---> Installing Linux Common Packages - Start"
}

python_packages () {

    sudo apt install python3-pip -y
    
    sudo pip install adal --break-system-packages
    sudo python3 -m pip install pyzabbix  --break-system-packages
    
    #Update setup tools to latest version due to: 
    sudo /opt/az/bin/python3 -Im pip install -U setuptools

}

install_powershell () {
   # Workaround installation due to https://github.com/PowerShell/PowerShell/issues/23197
   sudo apt get update
   wget https://mirror.it.ubc.ca/ubuntu/pool/main/i/icu/libicu72_72.1-3ubuntu3_amd64.deb
   sudo dpkg -i libicu72_72.1-3ubuntu3_amd64.deb
   wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.3/powershell_7.4.3-1.deb_amd64.deb
   sudo dpkg -i powershell_7.4.3-1.deb_amd64.deb
  
    pwsh -Command  Install-Module -Name SqlServer -Force
    pwsh -Command  Install-Module -Name Az -Force
    pwsh -Command  Import-Module SqlServer
    # Updating PowerShell Modules
    #pwsh -Cmmand Update-Module -Name ...
   # Official Powershell Installation Instruction
   
   # VERSION_ID="7.4"
   # sudo apt-get update -y
   # Install pre-requisite packages.
   # sudo apt-get install -y wget apt-transport-https software-properties-common
   # Get the version of Ubuntu
   # source /etc/os-release
   # Download the Microsoft repository keys
   #wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb
   # Register the Microsoft repository keys
   #sudo dpkg -i packages-microsoft-prod.deb
   # Delete the Microsoft repository keys file
   #rm packages-microsoft-prod.deb
   # Update the list of packages after we added packages.microsoft.com
   #sudo apt-get update -y
    ###################################
    # Install PowerShell
    #sudo apt-get install -y powershell




 
    # Az
#    Install-Module -Name Az -Force
 
    # SqlServer
#    Install-Module -Name SqlServer -Force
#    Import-Module SqlServer
}

#done
install_yq () {
  VERSION="v4.44.3"
  echo "Checking for existing yq installation"
  if  yq --version  >/dev/null 2>&1; then
      current_yq_version=$(yq --version)
      echo "YQ already installed $current_yq_version"
      read -p "Continue install/upgrade  yq (y/n)?" choice
      case "$choice" in 
        n|N ) exit 1;;
        y|Y ) echo "Install/Reinstall YQ"
              sudo wget https://github.com/mikefarah/yq/releases/download/$VERSION/yq_linux_amd64
              sudo mv yq_linux_amd64 /usr/sbin/yq && sudo chmod +x /usr/sbin/yq;;
          * ) echo "invalid";;
        esac
    fi

 
}

#done
install_mssqlpackage () {
    echo "---> Installing MSSQL Packages"
    folder="/opt/sqlpackage"
    if [ -d "$folder" ]; then
        echo "Folder $folder exists."
    fi
    if [ "$1" == true ]; then
        echo "Installing mssql package"
        cd /tmp && wget https://aka.ms/sqlpackage-linux
        sudo mkdir -p /opt/sqlpackagea
        sudo unzip /tmp/sqlpackage-linux -d /opt/sqlpackage
        sudo chmod a+x /opt/sqlpackage/sqlpackage
        #sudo ln -s /opt/sqlpackage/sqlpackage /usr/bin/sqlpackage
        rm /tmp/sqlpackage-linux
        echo "Done installing MSSQLPackages"
    fi
    
}

get_agents_shell () {
echo "provision.sh v0.050924"

#echo "Getting active agents on the machine through SystemD Services:"

desiredNumber=2
agents=$(systemctl status | grep -i [v]sts.agent |  awk '{print $2}' |  cut -d "_" -f 2 | cut -d "." -f 1)

#| tail -n +3)
IFS=$'\n'

for agent in $agents
do
        #echo $((10#$listener+increment))
        # Initialize an empty array and adding the agens Number into this array
        arr=()
        # Append agent number into array
        arr+=($agent)
done

# The array will keep the last element (outside of loop)
# Calculate the new Number for VM agents by increment with One
indexNew=$((10#$arr+1))
indexLast=$((indexNew+desiredNumber-1))
echo "Installing agents from $indexNew to $indexLast"
for i in $(seq $indexNew $indexLast);
do
    echo "Install agent vm-devopsagent02_$i"
    #devops_agent vm-devops-agent02_$i Default
done

# ================= End of Code that uses SystemD services =======================

}

get_agents_ado () {
###############################################################################################################
################# Code for taking the agent numbers through Az CLI Pipelines for using in ADO #################

desiredNumber=2
agents=$(az pipelines agent list --pool-id 1 --organization https://dev.azure.com/xloud -o table | grep vm-devops-agent02 | awk '{print $2}' | cut -d "_" -f 2)


#|  awk '{print $2}' |  cut -d "_" -f 2 | cut -d "." -f 1)

#| tail -n +3)
IFS=$'\n'

for agent in $agents
do
        echo $agent
        arr=()
        # Append agent number into array
        arr+=($agent)

done

# The array will keep the last element (outside of loop)
# Calculate the new Number for VM agents by increment with One


indexNew=$((10#$arr+1))
indexLast=$((indexNew+desiredNumber-1))


echo "IndexLast --- $indexLast"
echo "Installing agents from $indexNew to $indexLast"
for i in $(seq $indexNew $indexLast);
do
    echo "Install agent vm-devopsagent02_$i"
    #devops_agent vm-devops-agent02_$i Default
done

################################## End of Code to get the agent numbers through Az CLI ##################################
###############################################################################################################
}



#devops_agent vm-devops-agent02_01 Default
#

install_azure_cli
sleep 3
install_kubectl
sleep 3
install_mssqlpackage
sleep 3
#install_yq
#install_powershell
#python-packages
#linux_common_packages
install_java
sleep 3
install_kubelogin
sleep 3
install_helm
#install_terragrunt


#Taint resource to not be update

