# Use a prebuilt image that provides an Ubuntu desktop with XFCE, VNC, and noVNC.
FROM consol/ubuntu-xfce-vnc

# Switch to root so we can install packages.
USER root

# Update apt and install prerequisites.
RUN apt-get update && \
    apt-get install -y wget gnupg2 software-properties-common apt-transport-https

# Download the latest stable VS Code .deb package directly.
RUN wget -O /tmp/code.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" && \
    apt-get update && \
    apt-get install -y ./tmp/code.deb && \
    rm /tmp/code.deb

# Clean up apt cache to reduce image size.
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose the VNC (5901) and noVNC (6080) ports.
EXPOSE 5901 6080

# Use the base image's startup script to launch the desktop environment.
CMD ["/startup.sh"]
