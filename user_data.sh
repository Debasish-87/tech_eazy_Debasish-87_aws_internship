#!/bin/bash
exec > /var/log/startup.log 2>&1
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get upgrade -y
apt install -y openjdk-21-jdk maven git lsof


export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH=$JAVA_HOME/bin:$PATH

cd /home/ubuntu

if [ ! -d "techeazy-devops" ]; then
  git clone https://github.com/techeazy-consulting/techeazy-devops.git
else
  echo "Repo already cloned."
fi

cd techeazy-devops
chown -R ubuntu:ubuntu /home/ubuntu/techeazy-devops
chmod +x mvnw
export HOME=/home/ubuntu

JAVA_PATH=$(readlink -f "$(which java)")
setcap 'cap_net_bind_service=+ep' "$JAVA_PATH"

APP_PROPS_FILE="src/main/resources/application.properties"
mkdir -p src/main/resources
if grep -q "^server.port=" "$APP_PROPS_FILE" 2>/dev/null; then
  sed -i 's/^server.port=.*/server.port=80/' "$APP_PROPS_FILE"
else
  echo "server.port=80" >> "$APP_PROPS_FILE"
fi

rm -f app.log
touch app.log
chown ubuntu:ubuntu app.log

if lsof -i :80 -t >/dev/null; then
  echo "Port 80 in use, killing process..."
  kill -9 $(lsof -i :80 -t)
fi

sudo -u ubuntu ./mvnw clean package
sudo -u ubuntu nohup ./mvnw spring-boot:run > app.log 2>&1 &
disown


sudo shutdown -h +30

