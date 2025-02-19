# Use latest stable Ubuntu (24.04 LTS). If not available, use 22.04 LTS.
FROM ubuntu:24.04

# Disable interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive

# Install Xfce desktop, X11/VNC components, noVNC, and utilities (no display manager).
# Also install VS Code (latest stable) and clean up to reduce image size.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      xfce4 xfce4-terminal dbus-x11 x11vnc xvfb \
      novnc python3-websockify python3-numpy \
      fonts-dejavu-core ca-certificates curl wget gpg apt-transport-https && \
    wget -qO /tmp/vscode.deb "https://go.microsoft.com/fwlink/?LinkID=760868" && \
    echo "code code/add-microsoft-repo boolean true" | debconf-set-selections && \
    apt-get install -y /tmp/vscode.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/vscode.deb

# Set environment variables for display and default noVNC port
ENV DISPLAY=:0 \
    PORT=6080

# Expose VNC and noVNC ports
EXPOSE 5900 6080

# Switch to the ubuntu user for running the desktop environment
USER ubuntu

# Start all required services:
# - Xvfb on display :0 with a virtual screen.
# - Xfce desktop session.
# - x11vnc (with no password) on port 5900.
# - websockify to serve noVNC on $PORT (default 6080).
CMD bash -c "\
    Xvfb :0 -screen 0 1920x1080x24 & \
    sleep 1 && \
    DISPLAY=:0 startxfce4 & \
    sleep 2 && \
    x11vnc -forever -nopw -shared -display :0 -rfbport 5900 & \
    websockify --web=/usr/share/novnc/ \$PORT localhost:5900"
