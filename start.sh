#!/bin/bash
set -e

# ==============================
# HARDCODED LOGIN DETAILS
# ==============================

SSH_USER="ipx"
SSH_PASSWORD="DESTROYER009@a"

# ==============================
# CREATE SSH USER
# ==============================

echo "Creating SSH user..."

if ! id "$SSH_USER" >/dev/null 2>&1; then
    useradd -m -s /bin/bash "$SSH_USER"
fi

echo "$SSH_USER:$SSH_PASSWORD" | chpasswd

usermod -aG sudo "$SSH_USER"

echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" \
    > "/etc/sudoers.d/$SSH_USER"

chmod 440 "/etc/sudoers.d/$SSH_USER"

# ==============================
# CONFIGURE SSH
# ==============================

mkdir -p /run/sshd
mkdir -p /etc/ssh/sshd_config.d

cat > /etc/ssh/sshd_config.d/railway.conf <<EOF
Port 22
ListenAddress 0.0.0.0
PasswordAuthentication yes
KbdInteractiveAuthentication no
PermitRootLogin no
UsePAM no
X11Forwarding no
PrintMotd no
ClientAliveInterval 60
ClientAliveCountMax 3
EOF

# Generate SSH host keys
ssh-keygen -A

# Test configuration
/usr/sbin/sshd -t

echo ""
echo "======================================"
echo " SSH SERVER READY"
echo " User: $SSH_USER"
echo " Internal port: 22"
echo "======================================"
echo ""

# Keep container alive with SSH as main process
exec /usr/sbin/sshd -D -e
