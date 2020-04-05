#!/bin/bash
sudo apt install git subversion build-essential python gawk unzip libncurses5-dev zlib1g-dev libssl-dev wget time || exit 1
sudo apt clean
sudo rm -rf /var/lib/apt/lists/*
