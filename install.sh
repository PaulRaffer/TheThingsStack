BASEDIR=$(dirname "$0")

# Preparation:
	# Docker:
sudo apt-get remove docker docker-engine docker.io containerd runc


sudo apt-get update
sudo apt-get install \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg-agent \
	software-properties-common

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/debian \
	$(lsb_release -cs) \
	stable"


sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

sudo docker run hello-world



	# Docker Compose:
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version




# Certificates:
	# Automatic Certificate Management (ACME):
cd /var/lib
mkdir ./acme
sudo chown 886:886 ./acme

	# Custom Certificate Authority:
		# cfssl:
			# Go:
cd ~/Downloads
wget https://golang.org/dl/go1.14.7.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.14.7.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

go get -u github.com/cloudflare/cfssl/cmd/...

cd /run
mkdir ./secrets
cd ./secrets

cp "$BASEDIR/ca.json" .
cfssl genkey -initca ca.json | cfssljson -bare ca

cp "$BASEDIR/cert.json" .
cfssl gencert -ca ca.pem -ca-key ca-key.pem cert.json | cfssljson -bare cert

mv cert-key.pem key.pem
