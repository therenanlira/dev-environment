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
chsh -s /bin/bash $USER &>/dev/null
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
        install_homebrew
        INSTALL="brew install"
fi

## Install initial packages
$INSTALL neofetch figlet ed jq wget curl git gawk

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

## Extras Bash configurations
rm $HOME/.extras &>/dev/null \
&& curl -o $HOME/.extras https://raw.githubusercontent.com/therenanlira/dev-environment/main/extras \
&& echo -e "\n# Load extras\ntest -f \$HOME/.extras && source \$HOME/.extras" >> $BASHFILE

## Install programming languages
$INSTALL nodejs npm python3 pipx golang

## Install X Code
test $OS == "Darwin" && xcode-select --install

## Install TLDR
npm install -g tldr

## Install Cloud tools
$INSTALL awscli azure-cli terraform

## Install Kubernetes tools
$INSTALL kubectl kubectx k9s kubent bash-completion fzf helm k9s
kubectl completion bash > $(brew --prefix)/etc/bash_completion.d/kubectl

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
chmod +x ./kubectl-node_shell
sudo mv ./kubectl-node_shell /usr/local/bin/kubectl-node_shell

### Install CMCTL and CFSSL
if [ $OS == "Linux" ]; then
    CMCTL_VERSION=0.5.0
    curl -L -s "https://github.com/oleewere/cmctl/releases/download/v${CMCTL_VERSION}/cmctl_${CMCTL_VERSION}_linux_64-bit.tar.gz" | tar -C /usr/bin -xzv cmctl
elif [ $OS == "Darwin" ]; then
    brew tap oleewere/repo
    $INSTALL cmctl
    $INSTALL cfssl
fi

## Install e1s
E1S_VERSION=1.0.34
E1S_URL="https://github.com/keidarcy/e1s/releases/download/v$E1S_VERSION/e1s_$E1S_VERSION_$E1S_OS.tar.gz"
test $OS == "Linux" && E1S_OS="linux_amd64" || E1S_OS="darwin_all"

if [ $OS == "Linux" ]; then
    curl -L -s $E1S_URL | tar -C /usr/bin -xzv e1s
elif [ $OS == "Darwin" ]; then
    curl -L -s $E1S_URL | tar -C /usr/local/bin -xzv e1s
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
