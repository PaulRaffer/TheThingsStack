SCRIPT=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPT")
SERVERADDR="$1"
DEPLOYDIR="$2"


# Prerequisites:
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



# Configuration:
mkdir -p $DEPLOYDIR
cp "$SCRIPTDIR/docker-compose.yml" $DEPLOYDIR

mkdir -p $DEPLOYDIR/config/stack
cp "$SCRIPTDIR/ttn-lw-stack-docker.yml" $DEPLOYDIR/config/stack
sed -i "s/thethings.example.com/$SERVERADDR/g" $DEPLOYDIR/config/stack/ttn-lw-stack-docker.yml



# Certificates:
mkdir -p $DEPLOYDIR/acme
sudo chown 886:886 $DEPLOYDIR/acme



# Running The Things Stack:
cd $DEPLOYDIR

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
  --secret console \
  --redirect-uri "https://$SERVERADDR/console/oauth/callback" \
  --redirect-uri "/console/oauth/callback" \
  --logout-redirect-uri "https://$SERVERADDR/console" \
  --logout-redirect-uri "/console"

docker-compose up
