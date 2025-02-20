# Use latest stable Ubuntu (24.04 LTS).
FROM ubuntu:24.04

# Disable interactive prompts during package installs.
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists, upgrade installed packages, and install XFCE desktop, X11/VNC components, python3, pip3, python3-venv, additional build tools, and other utilities.
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    xfce4 xfce4-terminal dbus-x11 x11vnc xvfb \
    python3 python3-pip python3-venv python3-websockify python3-numpy \
    fonts-dejavu-core ca-certificates curl wget gpg apt-transport-https \
    build-essential python3-dev && \
    wget -qO /tmp/vscode.deb "https://go.microsoft.com/fwlink/?LinkID=760868" && \
    echo "code code/add-microsoft-repo boolean true" | debconf-set-selections && \
    apt-get install -y /tmp/vscode.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/vscode.deb

# Install Google Chrome stable using the new keyring method.
RUN wget -qO- https://dl.google.com/linux/linux_signing_key.pub | \
    gpg --dearmor -o /usr/share/keyrings/google-linux-signing-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-signing-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
    > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && apt-get install -y google-chrome-stable && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Download and install noVNC (use a known working version from GitHub).
RUN wget -qO- https://github.com/novnc/noVNC/archive/refs/tags/v1.3.0.tar.gz | tar -xz -C /usr/share && \
    mv /usr/share/noVNC-1.3.0 /usr/share/novnc

# Create a Python virtual environment and install pydantic inside it.
RUN python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip && \
    /venv/bin/pip install --no-cache-dir pydantic

# Update PATH so that the virtual environment’s python and pip take precedence.
ENV PATH="/venv/bin:$PATH"

# Set environment variables for display.
ENV DISPLAY=:0

# Expose VNC (5900) and noVNC (6080) ports.
EXPOSE 5900 6080

# Set root password so you can use 'su -'.
RUN echo "root:12345" | chpasswd

# Switch to the ubuntu user.
USER ubuntu

# Install NVM and the latest Node.js for the ubuntu user.
ENV NVM_DIR=/home/ubuntu/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash && \
    bash -c "source $NVM_DIR/nvm.sh && nvm install node && nvm alias default node" && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # Load nvm' >> ~/.bashrc

# Start all required services and launch Chrome with custom flags.
CMD bash -c "\
    echo 'Starting Xvfb with high resolution (3200×1800)...' && \
    Xvfb :0 -screen 0 3200×1800x24 & \
    sleep 1 && \
    DISPLAY=:0 startxfce4 & \
    sleep 2 && \
    echo 'Starting x11vnc with scaling (scale factor 0.5)...' && \
    x11vnc -forever -nopw -shared -display :0 -rfbport 5900 -scale 0.5 & \
    echo 'Launching Google Chrome with custom flags...' && \
    google-chrome-stable --no-sandbox --disable-gpu --disable-dev-shm-usage --disable-software-rasterizer & \
    echo 'Starting websockify on port 6080...' && \
    websockify --web=/usr/share/novnc/ 6080 localhost:5900 && \
    wait"
