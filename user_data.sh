#!/bin/bash
exec > /var/log/startup.log 2>&1
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive

# Wait until /home/ubuntu is available
while [ ! -d "/home/ubuntu" ]; do
  echo "Waiting for /home/ubuntu to be created..."
  sleep 2
done

# System update and install dependencies
apt-get update -y
apt-get upgrade -y
apt-get install -y unzip openjdk-21-jdk maven git lsof curl

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

# Set JAVA environment
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH=$JAVA_HOME/bin:$PATH

# Switch to ubuntu user for app setup
sudo -u ubuntu bash <<EOF
cd /home/ubuntu

REPO_URL="https://github.com/techeazy-consulting/techeazy-devops.git"
if [ "\${stage}" == "prod" ]; then
  REPO_URL="https://${github_pat}@github.com/Debasish-87/tech_eazy_prod_repo.git"
fi

# Clone repo if not already present
if [ ! -d "techeazy-devops" ]; then
  git clone \$REPO_URL
fi

cd techeazy-devops

# Make sure mvnw is executable
chmod +x mvnw

# Ensure application.properties has correct port
mkdir -p src/main/resources
if grep -q "^server.port=" src/main/resources/application.properties 2>/dev/null; then
  sed -i 's/^server.port=.*/server.port=80/' src/main/resources/application.properties
else
  echo "server.port=80" >> src/main/resources/application.properties
fi

# Prepare log and build
rm -f app.log
touch app.log
./mvnw clean package
nohup ./mvnw spring-boot:run > app.log 2>&1 &
EOF

# Adjust ownership
chown -R ubuntu:ubuntu /home/ubuntu/techeazy-devops
chown ubuntu:ubuntu /home/ubuntu/techeazy-devops/app.log

# Upload logs to S3
DATE=$(date +%F-%T)
aws s3 cp /var/log/startup.log s3://${logs_bucket_name}/logs/${stage}/startup-${DATE}.log || true
aws s3 cp /home/ubuntu/techeazy-devops/app.log s3://${logs_bucket_name}/logs/${stage}/app-${DATE}.log || true

# Readiness check signal
echo "Application is up and running" > /tmp/app_ready.txt
aws s3 cp /tmp/app_ready.txt s3://${logs_bucket_name}/logs/${stage}/app_ready.txt || true

# Auto-shutdown after 30 mins
shutdown -h +30
