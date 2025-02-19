# Use latest Ubuntu LTS (24.04 “Noble Numbat”). Use 22.04 (Jammy) if 24.04 is not available.
FROM ubuntu:24.04

# Disable interactive prompts and upgrade base packages
ENV DEBIAN_FRONTEND=noninteractive 
RUN apt-get update && apt-get -y upgrade && apt-get install -y --no-install-recommends \
    # Install Xfce desktop and X11 components
    xfce4 xfce4-terminal dbus-x11 x11-xserver-utils x11vfb x11vnc \
    # Install noVNC and websockify for browser-based VNC
    novnc websockify \
    # Install tools for adding VS Code repository
    wget gnupg2 ca-certificates \
    # Add Microsoft GPG key and VS Code repository
 && wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
 && install -o root -g root -m 644 microsoft.gpg /etc/apt/keyrings/microsoft.gpg && rm microsoft.gpg \
 && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list \
 && apt-get update \
    # Install VS Code and its dependencies
 && apt-get install -y --no-install-recommends code libgtk-3-0 libxss1 libxkbfile1 libsecret-1-0 libnss3 libasound2 libgbm1 \
    # Clean up apt caches to reduce image size
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy and set up startup script
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Switch to the default non-root user for the desktop session (UID 1000)
USER ubuntu
# Ensure the DISPLAY environment is set for X11
ENV DISPLAY=:0

# Expose VNC and noVNC ports
EXPOSE 5900 6080
