#!/bin/bash
exec > /var/log/startup.log 2>&1
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive

while [ ! -d "/home/ubuntu" ]; do
  echo "Waiting for /home/ubuntu to be created..."
  sleep 2
done

apt-get update -y
apt-get upgrade -y
apt-get install -y awscli || snap install aws-cli
apt install -y openjdk-21-jdk maven git lsof

export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH=$JAVA_HOME/bin:$PATH

cd /home/ubuntu

git clone https://github.com/techeazy-consulting/techeazy-devops.git

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


shutdown -h +15


BUCKET_NAME="${logs_bucket_name}"  
DATE=$(date +%F-%T)

aws s3 cp /var/log/startup.log s3://$BUCKET_NAME/ec2_logs/startup-$DATE.log
aws s3 cp /home/ubuntu/techeazy-devops/app.log s3://$BUCKET_NAME/app/logs/app-$DATE.log
