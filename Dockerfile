# Use latest stable Ubuntu (24.04 LTS).
FROM ubuntu:24.04

# Disable interactive prompts during package installs.
ENV DEBIAN_FRONTEND=noninteractive

# Install Xfce desktop, X11/VNC components, noVNC, and utilities.
RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 xfce4-terminal dbus-x11 x11vnc xvfb \
    novnc python3-websockify python3-numpy \
    fonts-dejavu-core ca-certificates curl wget gpg apt-transport-https && \
    wget -qO /tmp/vscode.deb "https://go.microsoft.com/fwlink/?LinkID=760868" && \
    echo "code code/add-microsoft-repo boolean true" | debconf-set-selections && \
    apt-get install -y /tmp/vscode.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/vscode.deb

# Install Google Chrome stable.
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && apt-get install -y google-chrome-stable && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set environment variables for display.
ENV DISPLAY=:0

# Expose VNC (5900) and noVNC (6080) ports.
EXPOSE 5900 6080

# Set root password so you can use 'su -'.
RUN echo "root:12345" | chpasswd

# Switch to the ubuntu user.
USER ubuntu

# Install NVM and the latest Node.js.
# This installs NVM into /home/ubuntu/.nvm, uses it to install Node, and adds sourcing of nvm to .bashrc.
ENV NVM_DIR=/home/ubuntu/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash && \
    bash -c "source $NVM_DIR/nvm.sh && nvm install node && nvm alias default node" && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load nvm' >> ~/.bashrc

# Start all required services.
CMD bash -c "\
    echo 'Starting Xvfb...' && \
    Xvfb :0 -screen 0 1920x1080x24 & \
    sleep 1 && \
    DISPLAY=:0 startxfce4 & \
    sleep 2 && \
    echo 'Starting x11vnc...' && \
    x11vnc -forever -nopw -shared -display :0 -rfbport 5900 & \
    echo 'Starting websockify on port 6080...' && \
    websockify --web=/usr/share/novnc/ 6080 localhost:5900"
