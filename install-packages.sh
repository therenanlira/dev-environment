## Variables
OS=$(uname -s)
DISTRO=$(test -f /etc/os-release && grep "ID_LIKE" /etc/os-release | awk -F= '{ print $2 }')

## Functions
function install_homebrew() {
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
}

## Check if OS is Linux or Darwin
if [ $OS != "Linux" ] && [ $OS != "Darwin" ]; then
    echo "This script is not supported for your OS"
    exit 1
fi

## Set Bash as default shell

## Verify if Bash is the default shell and if it is not, change it
test $SHELL == "/bin/bash" || sudo chsh -s /bin/bash

if [ $OS == "Linux" ]; then
    BASHFILE=$HOME/.bashrc
elif [ $OS == "Darwin" ]; then
    BASHFILE=$HOME/.bash_profile
fi

## Update and install basic packages
if [ $OS == "Linux" ]; then
    if [ $DISTRO == "debian" ]; then
        sudo apt update
        INSTALL="sudo apt install -y"
    elif [ $DISTRO == "rhel" ]; then
        sudo dnf update
        INSTALL="sudo dnf install -y"
    fi
elif [ $OS == "Darwin" ]; then
        test ! -f /opt/homebrew/bin/brew && install_homebrew
        INSTALL="brew install"
fi

## Install initial packages
$INSTALL neofetch figlet ed jq wget curl git gawk make unzip

## Configure vim
$INSTALL vim
test -f $HOME/.vimrc && rm $HOME/.vimrc
test ! -f $HOME/.vimrc && echo -e 'set ic\nset nu\nset cul\nset cuc\nset bg=dark' >> $HOME/.vimrc

## Install network tools
$INSTALL watch whois nmap

## Configure git
echo -e "\n\n\n########## Configuring git... ##########\n\n\n"
read -p "Your name: " name
read -p "Your GitHub email: " email
git config --global user.name $name
git config --global user.email $email 

## Install and configure bash-it and themes
git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it \
&& printf 'y' | ~/.bash_it/install.sh
git clone --depth=1 https://github.com/therenanlira/bash-it-themes.git ~/.bash-it-themes \
&& printf 'y' | ~/.bash-it-themes/install.sh
sed -i "" "s/export BASH_IT_THEME=.*/\export BASH_IT_THEME=new-sushu/g" $BASHFILE
source $BASHFILE

## Install programming languages
$INSTALL nodejs npm python3 pipx golang

## Install X Code
test $OS == "Darwin" && xcode-select --install

## Install TLDR
if [ $OS == "Linux" ]; then
    sudo npm install -g tldr
elif [ $OS == "Darwin" ]; then
    npm install -g tldr
fi

## Install FZF
if [ $OS == "Linux" ]; then
    $INSTALL fzf
elif [ $OS == "Darwin" ]; then
    $INSTALL fzf
    $(brew --prefix)/opt/fzf/install
fi

## Install Terraform
$INSTALL terraform

## Install AWS CLI
if [ $OS == "Linux" ]; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws
elif [ $OS == "Darwin" ]; then
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    sudo installer -pkg AWSCLIV2.pkg -target /
    rm -rf AWSCLIV2.pkg
fi

## Install Azure CLI
if [ $OS == "Linux" ]; then
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
elif [ $OS == "Darwin" ]; then
    $INSTALL azure-cli
fi

## Install Google Cloud CLI
if [ $OS == "Linux" ]; then
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    sudo apt update
    $INSTALL google-cloud-sdk
elif [ $OS == "Darwin" ]; then
    $INSTALL --cask google-cloud-sdk
fi

## Install Kubernetes tools
if [ $OS == "Linux" ]; then
    $INSTALL kubectl
    source <(kubectl completion bash)

    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
    sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

    sh -c "$(curl -sSL https://git.io/install-kubent)"

    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm get_helm.sh

    curl -sS https://webinstall.dev/k9s | bash
elif [ $OS == "Darwin" ]; then
    $INSTALL kubectl
    $INSTALL bash-completion
    kubectl completion bash > $(brew --prefix)/etc/bash_completion.d/kubectl

    $INSTALL kubectl kubectx
    $INSTALL kubent

    $INSTALL helm
    
    $INSTALL k9s
fi

### Install krew
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

### Install kubectl-node-shell
kubectl krew install neat
curl -LO https://github.com/kvaps/kubectl-node-shell/raw/master/kubectl-node_shell
sudo chown root:root ./kubectl-node_shell
sudo chmod +x ./kubectl-node_shell
sudo mv ./kubectl-node_shell /usr/local/bin/kubectl-node_shell

### Install CMCTL and CFSSL
if [ $OS == "Linux" ]; then
    CMCTL_VERSION=0.5.0
    curl -fsSLO "https://github.com/oleewere/cmctl/releases/download/v${CMCTL_VERSION}/cmctl_${CMCTL_VERSION}_linux_64-bit.tar.gz" \ 
    && sudo tar zxvf cmctl_${CMCTL_VERSION}_linux_64-bit.tar.gz -C /usr/local/bin cmctl
    rm cmctl_${CMCTL_VERSION}_linux_64-bit.tar.gz

    CFSSL_VERSION=1.6.5
    curl -fsSLO "https://github.com/cloudflare/cfssl/releases/download/v${CFSSL_VERSION}/cfssl-bundle_${CFSSL_VERSION}_linux_amd64" \
    && sudo mv cfssl-bundle_${CFSSL_VERSION}_linux_amd64 /usr/local/bin/cfssl
    sudo chown root:root /usr/local/bin/cfssl
    sudo chmod +x /usr/local/bin/cfssl
elif [ $OS == "Darwin" ]; then
    brew tap oleewere/repo
    $INSTALL cmctl
    $INSTALL cfssl
fi

## Install e1s
if [ $OS == "Linux" ]; then
    E1S_VERSION=1.0.34
    E1S_OS=linux_amd64
    E1S_URL=https://github.com/keidarcy/e1s/releases/download/v$E1S_VERSION/e1s_$E1S_VERSION\_$E1S_OS.tar.gz

    curl -fsSLO $E1S_URL \
    && sudo tar zxvf e1s_$E1S_VERSION\_$E1S_OS.tar.gz -C /usr/local/bin e1s
    sudo chown root:root /usr/local/bin/e1s
    sudo chmod +x /usr/local/bin/e1s
    rm e1s_$E1S_VERSION\_$E1S_OS.tar.gz
elif [ $OS == "Darwin" ]; then
    $INSTALL e1s
fi

## Install Docker
read -p "Install Docker? [y/N] " yn
case $yn in
    [Yy] )
            if [ $OS == "Linux" ]; then
                $INSTALL docker.io
                sudo systemctl enable docker
                sudo systemctl start docker
            elif [ $OS == "Darwin" ]; then
                $INSTALL docker
                $INSTALL --cask docker
            fi;;
    [Nn]* ) ;;
esac

## Install VS Code
read -p "Install Visual Studio Code? [y/N] " yn
case $yn in
    [Yy] )
            if [ $OS == "Linux" ]; then
                $INSTALL code
            elif [ $OS == "Darwin" ]; then
                $INSTALL --cask visual-studio-code
            fi;;
    [Nn]* ) ;;
esac

## Install Postman
read -p "Install Postman? [y/N] " yn
case $yn in
    [Yy] )  $INSTALL postman;;
    [Nn]* ) ;;
esac

## Extras Bash configurations
rm $HOME/.extras &>/dev/null \
&& curl -o $HOME/.extras https://raw.githubusercontent.com/therenanlira/dev-environment/main/extras \
&& echo -e "\n# Load extras\ntest -f \$HOME/.extras && source \$HOME/.extras" >> $BASHFILE
