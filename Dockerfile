# Use a prebuilt image that provides an Ubuntu desktop with XFCE, VNC, and noVNC.
FROM consol/ubuntu-xfce-vnc

# Switch to root to install packages.
USER root

# Update apt and install prerequisites.
RUN apt-get update && \
    apt-get install -y wget gnupg2 software-properties-common apt-transport-https

# Download and install the latest stable VS Code .deb package directly.
RUN wget -O /tmp/code.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" && \
    dpkg -i /tmp/code.deb || apt-get -f install -y && \
    rm /tmp/code.deb

# Clean up apt cache to reduce image size.
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose the VNC (5901) and noVNC (6080) ports.
EXPOSE 5901 6080

# Do NOT override the CMD.
# The base image already includes an ENTRYPOINT that starts the desktop environment.
