#!/usr/bin/env bash

# This script will add pam_reattach.so and pam_tid.so to the sudo_local file, enabling touch ID for sudo.
# Apple now providing sudo_local support that persists across system updates.
#
# Maintainer: vishvish@github
# Version: 1.0
# Last updated: 2024-11-21

sudo -v

# Define required packages and install if necessary
required_packages=("pam-reattach")

for package in "${required_packages[@]}"; do
    if ! brew list | grep -q "^${package}$"; then
        echo "${package} is not installed. Installing..."
        brew install "${package}"
    fi
done

# Copy the sudo_local.template file to sudo_local if it doesn't exist
if [[ ! -f /etc/pam.d/sudo_local ]]; then
    sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
fi

# Remove any lines containing pam_tid from sudo_local
sudo sed -i '' '/pam_tid/d' /etc/pam.d/sudo_local

# Remove any lines containing pam_reattach from sudo_local
sudo sed -i '' '/pam_reattach/d' /etc/pam.d/sudo_local

# Get the path to the pam_tid.so file, which is prefixed by the brew --prefix path
reattach_path=$(brew --prefix)/lib/pam/pam_reattach.so

# Add the pam_reattach.so path to the sudo_local file
sudo bash -c "echo 'auth       optional       ${reattach_path}' >> /etc/pam.d/sudo_local"

# Add the pam_tid.so path to the sudo_local file
sudo bash -c "echo 'auth       sufficient     pam_tid.so' >> /etc/pam.d/sudo_local"
