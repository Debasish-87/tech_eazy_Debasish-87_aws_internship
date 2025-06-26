#!/bin/bash
exec > >(tee /var/log/startup.log) 2>&1
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

# Injected via Terraform
BUCKET_NAME="${BUCKET_NAME}"
ENVIRONMENT="${ENVIRONMENT}"
DATE="${DATE}"
GITHUB_PAT="${GITHUB_PAT:-}"  # optional, only needed for prod

# Wait until /home/ubuntu exists (EC2 home ready)
while [ ! -d "/home/ubuntu" ]; do
  echo "[INFO] Waiting for /home/ubuntu..."
  sleep 2
done

echo "[INFO] Updating and installing dependencies..."
apt-get update -y
apt-get upgrade -y

# Fast install with minimal confirmation delays
apt-get install -y unzip curl openjdk-21-jdk maven git lsof software-properties-common

# Clean up leftover aws install dir to avoid unzip prompt
rm -rf /tmp/aws

echo "[INFO] Installing AWS CLI..."
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install --update --bin-dir /usr/bin --install-dir /usr/local/aws-cli || true

# JAVA path for port 80 access
JAVA_PATH=$(readlink -f "$(which java)")
setcap 'cap_net_bind_service=+ep' "$JAVA_PATH" || true

# Set JAVA_HOME for Maven
export JAVA_HOME=$(dirname $(dirname "$JAVA_PATH"))
export PATH="$JAVA_HOME/bin:$PATH"

# Repo Selection
if [ "$STAGE" == "prod" ]; then
  REPO_URL="https://${GITHUB_PAT}@github.com/Debasish-87/tech_eazy_prod_repo.git"
else
  REPO_URL="https://github.com/Debasish-87/tech_eazy_Debasish-87_aws_internship.git"
fi


echo "[INFO] Cloning and building Spring Boot app from $REPO_URL..."

sudo -u ubuntu bash <<EOF
cd /home/ubuntu

if [ ! -d "$APP_DIR" ]; then
  git clone $REPO_URL $APP_DIR
fi

cd $APP_DIR

# Ensure server runs on port 80
mkdir -p src/main/resources
APP_PROPS="src/main/resources/application.properties"
if grep -q "^server.port=" "\$APP_PROPS" 2>/dev/null; then
  sed -i 's/^server.port=.*/server.port=80/' "\$APP_PROPS"
else
  echo "server.port=80" >> "\$APP_PROPS"
fi

chmod +x mvnw
rm -f app.log
touch app.log

./mvnw clean package -DskipTests
nohup ./mvnw spring-boot:run > app.log 2>&1 &
EOF

# Fix permissions
chown -R ubuntu:ubuntu "$APP_DIR"
chown ubuntu:ubuntu "$APP_DIR/app.log"

# Health marker
echo " Application is running on environment: $ENVIRONMENT" | tee /tmp/app_ready.txt

echo "[INFO] Uploading logs to S3..."
aws s3 cp /var/log/startup.log "s3://${BUCKET_NAME}/logs/${ENVIRONMENT}/ec2_logs/startup-${DATE}.log" || true
aws s3 cp "$APP_DIR/app.log" "s3://${BUCKET_NAME}/logs/${ENVIRONMENT}/app_logs/app-${DATE}.log" || true
aws s3 cp /tmp/app_ready.txt "s3://${BUCKET_NAME}/status/${ENVIRONMENT}/app_ready.txt" || true
