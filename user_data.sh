#!/bin/bash
exec > >(tee /var/log/startup.log) 2>&1
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

# Injected via Terraform
BUCKET_NAME="${BUCKET_NAME}"
ENVIRONMENT="${ENVIRONMENT}"
DATE="${DATE}"
GITHUB_PAT="${GITHUB_PAT:-}"  # Optional – only required in prod

echo "[DEBUG] BUCKET_NAME=$BUCKET_NAME"
echo "[DEBUG] ENVIRONMENT=$ENVIRONMENT"
echo "[DEBUG] DATE=$DATE"

# Wait until EC2 is ready
while [ ! -d "/home/ubuntu" ]; do
  echo "[INFO] Waiting for /home/ubuntu..."
  sleep 2
done

echo "[INFO] Installing dependencies..."
apt-get update -y
apt-get upgrade -y
apt-get install -y unzip curl openjdk-21-jdk maven git lsof software-properties-common

# Clean previous AWS CLI (if any)
rm -rf /tmp/aws

echo "[INFO] Installing AWS CLI..."
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install --update --bin-dir /usr/bin --install-dir /usr/local/aws-cli || true

which aws && aws --version

# Set JAVA permissions
JAVA_PATH=$(readlink -f "$(which java)")
setcap 'cap_net_bind_service=+ep' "$JAVA_PATH" || true

export JAVA_HOME=$(dirname $(dirname "$JAVA_PATH"))
export PATH="$JAVA_HOME/bin:$PATH"

# ============================
# ✅ Repo Selection
# ============================
if [ "$ENVIRONMENT" == "prod" ]; then
  REPO_URL="https://${GITHUB_PAT}@github.com/Debasish-87/tech_eazy_prod_repo.git"
else
  REPO_URL="https://github.com/Debasish-87/tech_eazy_Debasish-87_aws_internship.git"
fi

echo "[INFO] Cloning Spring Boot app from: $REPO_URL"

# ============================
# ✅ Run as ubuntu user
# ============================
sudo -u ubuntu bash <<EOF
cd /home/ubuntu
APP_DIR="app"

if [ ! -d "\$APP_DIR" ]; then
  git clone "$REPO_URL" "\$APP_DIR" || {
    echo "[ERROR] Git clone failed!"
    exit 1
  }
fi

cd "\$APP_DIR"

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

echo "[INFO] Building app..."
./mvnw clean package -DskipTests || {
  echo "[ERROR] Maven build failed!"
  exit 1
}

echo "[INFO] Running Spring Boot app..."
nohup ./mvnw spring-boot:run > app.log 2>&1 &
EOF

# Fix permissions
chown -R ubuntu:ubuntu "/home/ubuntu/app"
chown ubuntu:ubuntu "/home/ubuntu/app/app.log"

# Health check marker
APP_READY_PATH="/tmp/app_ready.txt"
echo "Application is running on environment: $ENVIRONMENT" | tee "$APP_READY_PATH"

# Upload logs
echo "[INFO] Uploading logs to S3..."
aws s3 cp /var/log/startup.log "s3://${BUCKET_NAME}/logs/${ENVIRONMENT}/ec2_logs/startup-${DATE}.log" || true
aws s3 cp "/home/ubuntu/app/app.log" "s3://${BUCKET_NAME}/logs/${ENVIRONMENT}/app_logs/app-${DATE}.log" || true
aws s3 cp "$APP_READY_PATH" "s3://${BUCKET_NAME}/status/${ENVIRONMENT}/app_ready.txt" || {
  echo "[ERROR] Failed to upload app_ready.txt!"
  echo "Application failed to start" | tee /tmp/app_failed.txt
  aws s3 cp /tmp/app_failed.txt "s3://${BUCKET_NAME}/status/${ENVIRONMENT}/app_failed.txt" || true
}
