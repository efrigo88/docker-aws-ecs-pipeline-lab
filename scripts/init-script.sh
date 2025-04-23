#!/bin/bash

# Set up logging
exec > >(tee /var/log/chroma-init.log) 2>&1
echo "Starting Chroma DB initialization at $(date)"

# Update and install Docker
apt-get update
apt-get install -y docker.io curl

# Start Docker service
systemctl start docker
systemctl enable docker

# Create Chroma directory and Dockerfile
mkdir -p /home/ec2-user/chroma
cat > /home/ec2-user/chroma/Dockerfile << 'EOL'
FROM ghcr.io/chroma-core/chroma:latest

ENV ALLOW_RESET=true
ENV CHROMA_SERVER_AUTH_CREDENTIALS_ENABLE=false

VOLUME /chroma/.chroma/index

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost:8000/api/v1/heartbeat || exit 1
EOL

# Build and run Chroma container
cd /home/ec2-user/chroma
docker build -t chroma .
docker run -d --name chroma -p 8000:8000 -v chroma_data:/chroma/.chroma/index chroma

# Wait for Chroma to be ready
echo "Waiting for Chroma DB to be ready..."
for i in {1..30}; do
    if curl -s http://localhost:8000/api/v1/heartbeat > /dev/null; then
        echo "Chroma DB is ready!"
        exit 0
    fi
    echo "Waiting for Chroma DB... (Attempt $i/30)"
    sleep 10
done

echo "Chroma DB failed to start after 30 attempts"
exit 1