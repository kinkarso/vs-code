# Use a prebuilt image that provides an Ubuntu desktop with XFCE, VNC and noVNC.
FROM consol/ubuntu-xfce-vnc

# Switch to root so we can install packages.
USER root

# Update apt and install prerequisites for adding the VS Code repository.
RUN apt-get update && \
    apt-get install -y wget gnupg2 software-properties-common apt-transport-https

# Import the Microsoft GPG key and add the VS Code repository.
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg && \
    rm microsoft.gpg && \
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

# Update apt again and install VS Code.
RUN apt-get update && \
    apt-get install -y code

# (Optional) Clean up apt cache to reduce image size.
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose the VNC and noVNC ports.
EXPOSE 5901 6080

# Start the desktop environment (XFCE, VNC, noVNC) using the base image’s startup script.
CMD ["/startup.sh"]
