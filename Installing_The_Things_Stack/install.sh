SCRIPT=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPT")


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




mkdir ~/example-stack
cd ~/example-stack

# Certificates:
	# Automatic Certificate Management (ACME):
mkdir ./acme
sudo chown 886:886 ./acme

	# Custom Certificate Authority:
		# cfssl:
			# Go:
cd ~
wget https://golang.org/dl/go1.14.7.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.14.7.linux-amd64.tar.gz
cd ~/example-stack
export GOROOT=/usr/local/go
export GOPATH=~/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

go get -u github.com/cloudflare/cfssl/cmd/...

cp "$SCRIPTDIR/ca.json" .
cfssl genkey -initca ca.json | cfssljson -bare ca

cp "$SCRIPTDIR/cert.json" .
cfssl gencert -ca ca.pem -ca-key ca-key.pem cert.json | cfssljson -bare cert

mv cert-key.pem key.pem
sudo chown 886:886 ./cert.pem ./key.pem




# Configuration:
cp "$SCRIPTDIR/docker-compose.yml" .

mkdir ./config
cd ./config
mkdir ./stack
cd ./stack
cp "$SCRIPTDIR/ttn-lw-stack-docker.yml" .



# Running The Things Stack:
docker-compose pull

docker-compose run --rm stack is-db init

docker-compose run --rm stack is-db create-admin-user \
  --id admin \
  --email your@email.com

docker-compose run --rm stack is-db create-oauth-client \
  --id cli \
  --name "Command Line Interface" \
  --owner admin \
  --no-secret \
  --redirect-uri "local-callback" \
  --redirect-uri "code"

docker-compose run --rm stack is-db create-oauth-client \
  --id console \
  --name "Console" \
  --owner admin \
  --secret the secret you generated before \
  --redirect-uri "https://thethings.example.com/console/oauth/callback" \
  --redirect-uri "/console/oauth/callback" \
  --logout-redirect-uri "https://thethings.example.com/console" \
  --logout-redirect-uri "/console"

docker-compose up
