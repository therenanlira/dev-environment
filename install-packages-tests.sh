# Test if the script is supported for Linux
OS="Linux"
DISTRO="debian"
./install-packages.sh
# Expected output: This script is not supported for your OS

# Test if the script is supported for Darwin
OS="Darwin"
./install-packages.sh
# Expected output: This script is not supported for your OS