# Use a modern Ubuntu 22.04 (Jammy) desktop image with LXDE, VNC, and noVNC.
FROM dorowu/ubuntu-desktop-lxde-vnc:jammy

# Switch to root for package installations.
USER root

# Update apt and install prerequisites.
RUN apt-get update && \
    apt-get install -y wget gnupg2 software-properties-common apt-transport-https

# Download and install the latest stable VS Code .deb package.
RUN wget -O /tmp/code.deb "https://update.code.visualstudio.com/latest/linux-deb-x64/stable" && \
    dpkg -i /tmp/code.deb || apt-get -f install -y && \
    rm /tmp/code.deb

# Clean up the apt cache to reduce image size.
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose the ports for VNC (5900) and noVNC (6080).
EXPOSE 5900 6080

# The base image’s ENTRYPOINT will start the LXDE desktop and noVNC automatically.
