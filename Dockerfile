# Use a prebuilt image that provides an Ubuntu desktop with XFCE, VNC, and noVNC.
FROM consol/ubuntu-xfce-vnc

USER root

# Update apt and install prerequisites.
RUN apt-get update && \
    apt-get install -y curl gnupg2 software-properties-common apt-transport-https

# Install common VS Code dependencies (if not already in the base image)
RUN apt-get update && apt-get install -y \
    libasound2 \
    libgtk-3-0 \
    libxss1 \
    libxkbfile1 \
    libsecret-1-0 \
    libnss3 \
    libgbm1

# Download the latest stable VS Code .deb package using curl.
RUN curl -L -o /tmp/code.deb "https://update.code.visualstudio.com/latest/linux-deb-x64/stable" && \
    ls -l /tmp/code.deb

# Install VS Code; if there are dependency issues, fix them automatically.
RUN dpkg -i /tmp/code.deb || apt-get -f install -y && \
    rm /tmp/code.deb

# Clean up apt cache.
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose the ports for VNC and noVNC.
EXPOSE 5901 6901

# Use the base image's startup script (do not override CMD).
