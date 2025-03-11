# Use an official Ubuntu LTS base image
FROM ubuntu:20.04

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Update apt repository and install basic packages
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    sudo \
    dpkg \
    apt-utils \
    gnupg \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Copy the setup shell script into the container
COPY setup_crd.sh /usr/local/bin/setup_crd.sh
RUN chmod +x /usr/local/bin/setup_crd.sh

# Expose any necessary ports (if applicable for CRD)
EXPOSE 3380

# Set the default command to run the setup script
CMD ["/usr/local/bin/setup_crd.sh"]
