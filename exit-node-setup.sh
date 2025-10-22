#!/usr/bin/env bash

# This script sets a new persistent hostname in Debian.
# It takes one argument: the new hostname.
# It MUST be run with sudo or as root.

# --- Configuration ---
NEW_HOSTNAME="$1"
TAILSCALE_AUTH_KEY="$2"
HOSTS_FILE="/etc/hosts"

# --- Validation ---

# 1. Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root or with sudo."
  exit 1
fi

# 2. Check if an argument was provided
if [ -z "$NEW_HOSTNAME" ]; then
  echo "Usage: $0 <new-hostname>"
  echo "Example: $0 my-server"
  exit 1
fi

# --- Execution ---

# 1. Get the current (old) hostname
# We use 'hostname' to get the name currently active.
OLD_HOSTNAME=$(hostname)
echo "Current hostname is '$OLD_HOSTNAME'."

# 2. Check if a change is even needed
if [ "$OLD_HOSTNAME" == "$NEW_HOSTNAME" ]; then
  echo "Hostname is already set to '$NEW_HOSTNAME'. No changes made."
  exit 0
fi

echo "Changing hostname from '$OLD_HOSTNAME' to '$NEW_HOSTNAME'..."

# 3. Set the new hostname persistently
# This updates /etc/hostname and tells the kernel the new name.
hostnamectl set-hostname "$NEW_HOSTNAME"

if [ $? -ne 0 ]; then
  echo "Error: 'hostnamectl' command failed."
  exit 1
fi

# 4. Update the /etc/hosts file to replace the old name
# This finds all exact matches of the old hostname and replaces them.
echo "Updating $HOSTS_FILE..."
sed -i "s/\b$OLD_HOSTNAME\b/$NEW_HOSTNAME/g" "$HOSTS_FILE"

if [ $? -ne 0 ]; then
  echo "Error: Failed to update $HOSTS_FILE."
  exit 1
fi

echo ""
echo "Hostname change complete! 🚀"
echo "Log out and log back in for the new name to appear in your terminal prompt."


apt-get update -y
curl -fsSL https://tailscale.com/install.sh | sh 
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
sudo tailscale up --auth-key="$TAILSCALE_AUTH_KEY" --advertise-exit-node --ssh
sudo reboot
