#!/bin/bash
exec > /var/log/startup.log 2>&1
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive

# Wait for the 'ubuntu' user directory to be ready
while [ ! -d "/home/ubuntu" ]; do
  echo "Waiting for /home/ubuntu to be created..."
  sleep 2
done

apt-get update -y
apt-get upgrade -y
sudo apt install unzip
apt install -y openjdk-21-jdk maven git lsof


curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
apt-get install -y unzip curl
unzip /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install

export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH=$JAVA_HOME/bin:$PATH

# Clone the repo as ubuntu user
sudo -u ubuntu bash <<EOF
cd /home/ubuntu
if [ ! -d "techeazy-devops" ]; then
  git clone https://github.com/techeazy-consulting/techeazy-devops.git
fi
cd techeazy-devops
chmod +x mvnw
export HOME=/home/ubuntu

JAVA_PATH=$(readlink -f "$(which java)")
EOF

# Set capability outside sudo block
JAVA_PATH=$(readlink -f "$(which java)")
setcap 'cap_net_bind_service=+ep' "$JAVA_PATH"

# Modify app properties and run app as ubuntu
sudo -u ubuntu bash <<EOF
cd /home/ubuntu/techeazy-devops
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

# Set ownership
chown -R ubuntu:ubuntu /home/ubuntu/techeazy-devops
chown ubuntu:ubuntu /home/ubuntu/techeazy-devops/app.log

# Upload logs to S3
BUCKET_NAME="${logs_bucket_name}" 
DATE=$(date +%F-%T)
aws s3 cp /var/log/startup.log s3://$BUCKET_NAME/ec2_logs/startup-$DATE.log || true
aws s3 cp /home/ubuntu/techeazy-devops/app.log s3://$BUCKET_NAME/app/logs/app-$DATE.log || true

# Schedule shutdown
shutdown -h +30
