# Use a modern Ubuntu desktop image with VNC/noVNC from accetto (Ubuntu Jammy)
FROM accetto/ubuntu-desktop-vnc:jammy

# Switch to root for package installations.
USER root

# Set non-interactive apt environment
ENV DEBIAN_FRONTEND=noninteractive

# Update apt and install prerequisites.
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget gnupg2 software-properties-common apt-transport-https curl

# Add Microsoft GPG key and VS Code repository.
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list

# Update apt and install VS Code along with its required libraries.
RUN apt-get update && apt-get install -y --no-install-recommends \
    code libgtk-3-0 libxss1 libxkbfile1 libsecret-1-0 libnss3 libasound2 libgbm1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create the 'ubuntu' user if it doesn't already exist.
RUN id ubuntu || (useradd -m -s /bin/bash ubuntu && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu)

# Expose ports: VNC on 5900 and noVNC (web) on 6080.
EXPOSE 5900 6080

# Switch to the non-root 'ubuntu' user.
USER ubuntu
ENV DISPLAY=:0

# CMD: Start the virtual display (Xvfb), launch the Xfce desktop, then start x11vnc and websockify (for noVNC).
CMD bash -c "\
    Xvfb :0 -screen 0 1920x1080x24 & \
    sleep 2 && \
    startxfce4 & \
    sleep 5 && \
    x11vnc -display :0 -rfbport 5900 -forever -nopw -shared & \
    websockify --web=/usr/share/novnc/ \$PORT localhost:5900"
