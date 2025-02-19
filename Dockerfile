# Use latest stable Ubuntu (24.04 LTS).
FROM ubuntu:24.04

# Disable interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive

# Install Xfce desktop, X11/VNC components, noVNC, and utilities (no display manager).
# Also install VS Code (latest stable) and clean up to reduce image size.
RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 xfce4-terminal dbus-x11 x11vnc xvfb \
    novnc python3-websockify python3-numpy \
    fonts-dejavu-core ca-certificates curl wget gpg apt-transport-https && \
    wget -qO /tmp/vscode.deb "https://go.microsoft.com/fwlink/?LinkID=760868" && \
    echo "code code/add-microsoft-repo boolean true" | debconf-set-selections && \
    apt-get install -y /tmp/vscode.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/vscode.deb

# Set environment variables for display and noVNC port
ENV DISPLAY=:0

# Expose VNC and noVNC ports
EXPOSE 5900 6080

# Switch to the ubuntu user for running the desktop environment.
# (This container uses the default root user; if you need a non-root user, you can add one.)
USER ubuntu

# Start all required services via CMD:
# - Start Xvfb on display :0
# - Launch Xfce desktop
# - Start x11vnc (VNC server) on port 5900
# - Start websockify to serve noVNC on port 6080, serving the noVNC files from /usr/share/novnc/
CMD bash -c "\
    echo 'Starting Xvfb...' && \
    Xvfb :0 -screen 0 1920x1080x24 & \
    sleep 5 && \
    echo 'Starting Xfce...' && \
    startxfce4 & \
    sleep 10 && \
    echo 'Starting x11vnc...' && \
    x11vnc -display :0 -rfbport 5900 -forever -nopw -shared & \
    echo 'Starting websockify on port 6080...' && \
    websockify 6080 localhost:5900 --web=/usr/share/novnc/"
