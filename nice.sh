#!/bin/bash

# Install NICE DCV on Amazone Linux 2 base images

# Install Pre-reqs
# --------------------------------

# Install Desktop Environment
sudo yum install gdm gnome-session gnome-classic-session gnome-session-xsession -y
sudo yum install xorg-x11-server-Xorg xorg-x11-fonts-Type1 xorg-x11-drivers -y
sudo yum install gnome-terminal gnu-free-fonts-common gnu-free-mono-fonts gnu-free-sans-fonts gnu-free-serif-fonts -y

# Update all packages
sudo yum upgrade -y

# Configure X server to start automatically on boot
sudo systemctl set-default graphical.target
sudo systemctl isolate graphical.target

# Install glx-utils
sudo yum install glx-utils

# Install Dummy OpenGL Drivers
sudo yum install xorg-x11-drv-dummy -y

# Configure XDummy
sudo cat >/etc/myconfig.conf <<EOL
Section "Device"
    Identifier "DummyDevice"
    Driver "dummy"
    Option "ConstantDPI" "true"
    Option "IgnoreEDID" "true"
    Option "NoDDC" "true"
    VideoRam 2048000
EndSection

Section "Monitor"
    Identifier "DummyMonitor"
    HorizSync   5.0 - 1000.0
    VertRefresh 5.0 - 200.0
    Modeline "1920x1080" 23.53 1920 1952 2040 2072 1080 1106 1108 1135
    Modeline "1600x900" 33.92 1600 1632 1760 1792 900 921 924 946
    Modeline "1440x900" 30.66 1440 1472 1584 1616 900 921 924 946
    ModeLine "1366x768" 72.00 1366 1414 1446 1494  768 771 777 803
    Modeline "1280x800" 24.15 1280 1312 1400 1432 800 819 822 841
    Modeline "1024x768" 18.71 1024 1056 1120 1152 768 786 789 807
EndSection

Section "Screen"
    Identifier "DummyScreen"
    Device "DummyDevice"
    Monitor "DummyMonitor"
    DefaultDepth 24
    SubSection "Display"
        Viewport 0 0
        Depth 24
        Modes "1920x1080" "1600x900" "1440x900" "1366x768" "1280x800" "1024x768"
        virtual 1920 1080
    EndSubSection
EndSection
... 
EOL

# Restart X Server
sudo systemctl isolate multi-user.target
sudo systemctl isolate graphical.target

# Install NICE DCV
# --------------------------------
sudo rpm --import https://d1uj6qtbmh3dt5.cloudfront.net/NICE-GPG-KEY

# Install latest version of NICE
wget https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-el7-x86_64.tgz
tar -xvzf nice-dcv-el7-x86_64.tgz && cd `ls -d nice-dcv*/`

sudo yum install `ls | grep nice.*server.*` -y
sudo yum install `ls | grep nice.*viewer.*` -y

# Restart X server
sudo systemctl isolate multi-user.target
sudo systemctl isolate graphical.target

# Start DCV Server and Configure to start automatically
sudo systemctl start dcvserver
sudo systemctl enable dcvserver

#TODO - File Cleanup