#!/bin/bash
sudo cp contrib/actions/sources.list /etc/apt/sources.list
sudo rm -rf /etc/apt/sources.list.d
sudo apt update
sudo apt install git subversion build-essential python gawk unzip libncurses5-dev zlib1g-dev libssl-dev wget time || exit 1
sudo apt clean
sudo rm -rf /var/lib/apt/lists/*
