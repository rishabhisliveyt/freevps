#!/bin/bash

set -u

SSH_USER="ipx"
SSH_PASSWORD="DESTROYER009@a"
SERVEO_ALIAS="DESTROYER"

echo "Creating SSH user..."

if ! id "$SSH_USER" >/dev/null 2>&1; then
    useradd -m -s /bin/bash "$SSH_USER"
fi

echo "$SSH_USER:$SSH_PASSWORD" | chpasswd
usermod -aG sudo "$SSH_USER"

echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$SSH_USER"
chmod 440 "/etc/sudoers.d/$SSH_USER"

mkdir -p /run/sshd
mkdir -p /etc/ssh/sshd_config.d

cat > /etc/ssh/sshd_config.d/railway.conf <<EOF
PasswordAuthentication yes
PermitRootLogin no
UsePAM no
X11Forwarding no
PrintMotd no
ClientAliveInterval 60
ClientAliveCountMax 3
EOF

ssh-keygen -A

echo "Testing SSH configuration..."
/usr/sbin/sshd -t

echo "Starting SSH server..."
/usr/sbin/sshd

echo ""
echo "=========================================="
echo " SSH SERVER STARTED"
echo " User: $SSH_USER"
echo " Serveo alias: $SERVEO_ALIAS"
echo "=========================================="
echo ""

while true; do
    echo "Connecting tunnel to Serveo..."

    ssh \
        -N \
        -T \
        -o StrictHostKeyChecking=accept-new \
        -o ServerAliveInterval=30 \
        -o ServerAliveCountMax=3 \
        -o TCPKeepAlive=yes \
        -o ConnectTimeout=20 \
        -o ExitOnForwardFailure=yes \
        -R "${SERVEO_ALIAS}:22:localhost:22" \
        serveo.net

    EXIT_CODE=$?

    echo ""
    echo "Serveo tunnel disconnected with code $EXIT_CODE."
    echo "Reconnecting in 5 seconds..."
    sleep 5
done
