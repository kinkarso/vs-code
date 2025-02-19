# Use a prebuilt image that provides an Ubuntu desktop with XFCE, VNC and noVNC.
# We use the image from "consol/ubuntu-xfce-vnc" which is popular for this purpose.
FROM consol/ubuntu-xfce-vnc

# Switch to root to install additional software
USER root

# Update apt and install dependencies for VS Code Desktop
RUN apt-get update && apt-get install -y wget gnupg2 software-properties-common

# Add the Microsoft GPG key and VS Code repository
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg
RUN add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"

# Install VS Code (the official desktop version)
RUN apt-get update && apt-get install -y code

# (Optional) Clean up apt cache to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose the VNC and noVNC ports.
# By default, the base image uses 5901 for VNC and 6080 for noVNC.
EXPOSE 5901 6080

# Set the default command to start the desktop environment.
# The base image's startup script (/startup.sh) launches XFCE, the VNC server, and noVNC.
CMD ["/startup.sh"]
