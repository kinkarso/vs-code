# Use a prebuilt image that provides an Ubuntu desktop with XFCE, VNC, and noVNC.
FROM consol/ubuntu-xfce-vnc

# Switch to root to install packages.
USER root

# Update apt and install prerequisites.
RUN apt-get update && \
    apt-get install -y wget gnupg2 software-properties-common apt-transport-https

# Instead of relying on the repository, download the latest stable VS Code .deb package directly.
RUN wget -O /tmp/code.deb "https://update.code.visualstudio.com/latest/linux-deb-x64/stable" && \
    apt-get update && \
    apt-get install -y /tmp/code.deb && \
    rm /tmp/code.deb

# (Optional) Clean up apt cache to reduce image size.
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose the VNC and noVNC ports.
EXPOSE 5901 6080

# Use the base image's startup script to launch the desktop environment.
CMD ["/startup.sh"]
