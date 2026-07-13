FROM alpine:latest

# PocketBase Version
ENV PB_VERSION=0.24.0

# Install unzip, ca-certificates, and wget
RUN apk add --no-cache unzip ca-certificates wget

# Download and unzip PocketBase
RUN wget https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip \
    && unzip pocketbase_${PB_VERSION}_linux_amd64.zip -d /pb \
    && rm pocketbase_${PB_VERSION}_linux_amd64.zip

# Create directories for persistent volume
RUN mkdir -p /pb/pb_data /pb/pb_migrations

# Expose default port
EXPOSE 8080

# Serve PocketBase on port 8080
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8080"]
