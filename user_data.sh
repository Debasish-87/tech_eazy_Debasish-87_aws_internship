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
apt-get install -y unzip openjdk-21-jdk maven git lsof curl

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH=$JAVA_HOME/bin:$PATH

# Vars passed from Terraform
STAGE="${stage}"
LOG_BUCKET="${logs_bucket_name}"
GITHUB_PAT="${github_pat}"

sudo -u ubuntu bash <<EOF
cd /home/ubuntu

REPO_URL="https://github.com/techeazy-consulting/techeazy-devops.git"
if [ "$STAGE" == "prod" ]; then
  REPO_URL="https://$GITHUB_PAT@github.com/Debasish-87/tech_eazy_prod_repo.git"
fi

if [ ! -d "techeazy-devops" ]; then
  git clone \$REPO_URL
fi

cd techeazy-devops
chmod +x mvnw

mkdir -p src/main/resources
if grep -q "^server.port=" src/main/resources/application.properties 2>/dev/null; then
  sed -i 's/^server.port=.*/server.port=80/' src/main/resources/application.properties
else
  echo "server.port=80" >> src/main/resources/application.properties
fi

rm -f app.log
touch app.log
./mvnw clean package
nohup ./mvnw spring-boot:run > app.log 2>&1 &
EOF

chown -R ubuntu:ubuntu /home/ubuntu/techeazy-devops
chown ubuntu:ubuntu /home/ubuntu/techeazy-devops/app.log

DATE=$(date +%F-%T)
aws s3 cp /var/log/startup.log s3://$LOG_BUCKET/logs/$STAGE/startup-$DATE.log || true
aws s3 cp /home/ubuntu/techeazy-devops/app.log s3://$LOG_BUCKET/logs/$STAGE/app-$DATE.log || true

echo "Application is up and running" > /tmp/app_ready.txt
aws s3 cp /tmp/app_ready.txt s3://$LOG_BUCKET/logs/$STAGE/app_ready.txt || true

shutdown -h +30
