apt-get install snapd
sudo snap install ttn-lw-stack
sudo snap alias ttn-lw-stack.ttn-lw-cli ttn-lw-cli
export PATH=$PATH:/snap/ttn-lw-stack/current

cd ~
ttn-lw-cli use thethings.example.com

ttn-lw-cli login
