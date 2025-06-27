#!/bin/bash
# Redirect output to log and console
exec > >(tee /var/log/startup.log | logger -t user-data -s 2>/dev/console) 2>&1
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive

# Wait until home directory is ready
while [ ! -d "/home/ubuntu" ]; do
  echo "Waiting for /home/ubuntu to be created..."
  sleep 2
done

# Install necessary packages
apt-get update -y
apt-get upgrade -y
apt-get install -y unzip openjdk-21-jdk maven git lsof curl

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

# Set Java environment
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH=$JAVA_HOME/bin:$PATH

# Vars from Terraform
STAGE="${stage}"
LOG_BUCKET="${logs_bucket_name}"
GITHUB_PAT="${github_pat}"

# Application deployment block
sudo -u ubuntu bash <<EOF
cd /home/ubuntu

# Select repo based on stage
REPO_URL="https://github.com/techeazy-consulting/techeazy-devops.git"
if [ "$STAGE" == "prod" ]; then
  REPO_URL="https://$GITHUB_PAT@github.com/Debasish-87/tech_eazy_prod_repo.git"
fi

# Clone repo if not already
if [ ! -d "techeazy-devops" ]; then
  git clone \$REPO_URL
fi

cd techeazy-devops
chmod +x mvnw

# Set port to 80
mkdir -p src/main/resources
echo "server.port=80" > src/main/resources/application.properties

# Build and run the app
rm -f app.log
touch app.log
./mvnw clean package
nohup ./mvnw spring-boot:run > app.log 2>&1 &
EOF

# Set permissions
chown -R ubuntu:ubuntu /home/ubuntu/techeazy-devops
chown ubuntu:ubuntu /home/ubuntu/techeazy-devops/app.log

# Wait for the app to start
sleep 5

# Upload logs to S3
DATE=$(date +%F-%T)
aws s3 cp /var/log/startup.log s3://$LOG_BUCKET/logs/$STAGE/startup-$DATE.log || true
aws s3 cp /home/ubuntu/techeazy-devops/app.log s3://$LOG_BUCKET/logs/$STAGE/app-$DATE.log || true

# Signal readiness to S3
echo "Application is up and running" > /tmp/app_ready.txt
aws s3 cp /tmp/app_ready.txt s3://$LOG_BUCKET/logs/$STAGE/app_ready.txt || true

# Schedule shutdown
shutdown -h +30
