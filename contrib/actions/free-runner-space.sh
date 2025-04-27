#!/bin/bash

# For a List of pre-installed packages on the runner image see
# https://github.com/actions/runner-images/tree/main?tab=readme-ov-file#available-images

echo "Disk space before cleanup"
df -h

# Remove packages not required to run the Gluon build CI
sudo apt-get -y remove \
	dotnet-* \
	firefox \
	google-chrome-stable \
	kubectl \
	microsoft-edge-stable \
	temurin-*-jdk

# Remove Android SDK tools
sudo rm -rf /usr/local/lib/android

echo "Disk space after cleanup"
df -h

