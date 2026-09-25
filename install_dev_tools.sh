#!/bin/bash

sudo apt update

if command -v docker > /dev/null 2>&1; then
    echo "Docker вже встановлено"
else
    echo "Встановлюю Docker..."
    sudo apt install -y docker.io
fi

if command -v docker-compose > /dev/null 2>&1; then
    echo "Docker Compose вже встановлено"
else
    echo "Встановлюю Docker Compose..."
    sudo apt install -y docker-compose
fi

if command -v python3 > /dev/null 2>&1; then
    echo "Python вже встановлено: $(python3 --version)"
else
    echo "Встановлюю Python..."
    sudo apt install -y python3
fi

if python3 -c "import django" > /dev/null 2>&1; then
    echo "Django вже встановлено"
else
    echo "Встановлюю Django..."
    sudo apt install -y python3-pip
    sudo pip3 install django || sudo pip3 install --break-system-packages django
fi

echo "Готово"
