#!/bin/bash

DEFAULT_USER="githubrunner"
USER_HOME="/home/$DEFAULT_USER"
USER_PASSWORD="password"
RUNNER_VERSION="2.317.0"
RUNNER_PACKAGE="actions-runner-linux-x64-$RUNNER_VERSION.tar.gz"

# Function to display error message and exit
die() {
    echo >&2 "Error: $@"
    exit 1
}

# Function to install required packages
install_packages() {
    local packages="$@"
    if [ -x "$(command -v apt-get)" ]; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y update
        sudo DEBIAN_FRONTEND=noninteractive apt-get -y install $packages || die "Failed to install $packages. Aborting."
    elif [ -x "$(command -v yum)" ]; then
        sudo yum -y install $packages || die "Failed to install $packages. Aborting."
    elif [ -x "$(command -v dnf)" ]; then
        sudo dnf -y install $packages || die "Failed to install $packages. Aborting."
    elif [ -x "$(command -v pacman)" ]; then
        sudo pacman -Sy --noconfirm $packages || die "Failed to install $packages. Aborting."
    else
        die "Unsupported package manager. Please install $packages manually."
    fi
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to set up runner directory and permissions
setup_runner_directory() {
    local RUNNER_NAME="$1"
    local RUNNER_DIR="$USER_HOME/$RUNNER_NAME/actions-runner"

    sudo mkdir -p "$RUNNER_DIR" || die "Failed to create $RUNNER_DIR directory."
    sudo chown -R $DEFAULT_USER:$DEFAULT_USER "$RUNNER_DIR" || die "Failed to set ownership for $RUNNER_DIR."
}

# Function to download and extract GitHub Actions runner package
download_and_extract_runner() {
    local RUNNER_NAME="$1"
    local EXPECTED_CHECKSUM="9e883d210df8c6028aff475475a457d380353f9d01877d51cc01a17b2a91161d"
    local RUNNER="https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-linux-x64-2.317.0.tar.gz"

    # Ensure directory exists and has correct ownership
    sudo mkdir -p "$USER_HOME/$RUNNER_NAME/actions-runner" || die "Failed to create $USER_HOME/$RUNNER_NAME/actions-runner directory."
    sudo chown -R $DEFAULT_USER:$DEFAULT_USER "$USER_HOME/$RUNNER_NAME/actions-runner" || die "Failed to set ownership for $USER_HOME/$RUNNER_NAME/actions-runner."

    # Download and verify checksum
    sudo -u $DEFAULT_USER curl -o "$USER_HOME/$RUNNER_NAME/actions-runner/$RUNNER_PACKAGE" -L "$RUNNER" || die "Failed to download $RUNNER_PACKAGE."
    sudo chown $DEFAULT_USER:$DEFAULT_USER "$USER_HOME/$RUNNER_NAME/actions-runner/$RUNNER_PACKAGE" || die "Failed to set ownership for $USER_HOME/$RUNNER_NAME/actions-runner/$RUNNER_PACKAGE."

    # Verify SHA256 checksum
    actual_checksum=$(sudo -u $DEFAULT_USER sha256sum "$USER_HOME/$RUNNER_NAME/actions-runner/$RUNNER_PACKAGE" | awk '{print $1}')
    if [ "$EXPECTED_CHECKSUM" != "$actual_checksum" ]; then
        die "Checksum verification failed for $USER_HOME/$RUNNER_NAME/actions-runner/$RUNNER_PACKAGE. Aborting."
    fi

    # Extract the runner package
    sudo -u $DEFAULT_USER tar xzf "$USER_HOME/$RUNNER_NAME/actions-runner/$RUNNER_PACKAGE" -C "$USER_HOME/$RUNNER_NAME/actions-runner" || die "Failed to extract $USER_HOME/$RUNNER_NAME/actions-runner/$RUNNER_PACKAGE."
    sudo chown -R $DEFAULT_USER:$DEFAULT_USER "$USER_HOME/$RUNNER_NAME/actions-runner" || die "Failed to set ownership for $USER_HOME/$RUNNER_NAME/actions-runner."
}

# Function to fetch GitHub Actions runner registration token
fetch_runner_token() {
    local response
    response=$(curl -s -X POST -H "Authorization: token ${GITHUB_PAT}" "https://api.github.com/repos/${GITHUB_ORG}/${GITHUB_REPO}/actions/runners/registration-token")
    echo $(echo "$response" | jq -r .token)
}

# Function to configure and start the runner
configure_and_start_runner() {
    local RUNNER_NAME="$1"
    local RUNNER_TOKEN
    RUNNER_TOKEN=$(fetch_runner_token) || die "Failed to fetch GitHub Actions runner registration token."

    sudo -u $DEFAULT_USER -i <<EOF
    cd "$USER_HOME/$RUNNER_NAME/actions-runner" || exit 1

    ./config.sh --url "https://github.com/${GITHUB_ORG}/${GITHUB_REPO}" \
                --token "$RUNNER_TOKEN" \
                --name "$RUNNER_NAME" \
                --runnergroup "Default" \
                --work "_work" \
                --labels "self-hosted,Linux,X64,$RUNNER_NAME" \
                --unattended \
                --replace || { echo "Failed to configure GitHub Actions runner"; exit 1; }

    echo "GitHub Actions runner setup for $RUNNER_NAME completed successfully."
    echo "The runner is running in the background. Check runner.log for output."
EOF

    # Create systemd service
    sudo tee /etc/systemd/system/github-runner.service >/dev/null <<EOL
[Unit]
Description=GitHub Actions Runner
After=network.target

[Service]
User=$DEFAULT_USER
WorkingDirectory=$USER_HOME/$RUNNER_NAME/actions-runner
ExecStart=$USER_HOME/$RUNNER_NAME/actions-runner/run.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOL

    # Reload systemd and start the service
    sudo systemctl daemon-reload
    sudo systemctl enable github-runner
    sudo systemctl start github-runner

    echo "Systemd service for GitHub Actions runner $RUNNER_NAME created and started."
}

# Main script
main() {
    local RUNNER_NAME="deck"
    # Install required packages if not already installed
    command_exists curl || install_packages curl
    install_packages curl jq

    # Ensure default user exists and has necessary permissions (no longer creating new users)
    sudo useradd -m -s /bin/bash $DEFAULT_USER 2>/dev/null || true
    echo "$DEFAULT_USER:$USER_PASSWORD" | sudo chpasswd || die "Failed to set password for $DEFAULT_USER. Aborting."
    echo "$DEFAULT_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$DEFAULT_USER >/dev/null
    sudo chmod 0440 /etc/sudoers.d/$DEFAULT_USER

    setup_runner_directory "$RUNNER_NAME"
    download_and_extract_runner "$RUNNER_NAME"
    configure_and_start_runner "$RUNNER_NAME"

    echo "All GitHub Actions runners setup completed successfully."
}

# Execute main script
main
