#!/bin/bash

set -e

export DISPLAY=:99

echo "Cleaning old processes..."
pkill -f "Xvfb :99" || true
pkill -f fluxbox || true
pkill -f x11vnc || true
pkill -f websockify || true
pkill -f novnc || true
pkill -f chrome || true
pkill -f chrome-devtools-mcp || true

rm -f /tmp/.X99-lock
rm -rf /tmp/.X11-unix/X99

sleep 1

echo "Starting Xvfb..."
Xvfb :99 -screen 0 1280x1024x24 &
export DISPLAY=:99
sleep 1

echo "Starting Fluxbox..."
fluxbox &
sleep 1

echo "Starting x11vnc Server on port 5900..."
x11vnc -display :99 -forever -shared -nopw -listen 0.0.0.0 -rfbport 5900 -bg

echo "Starting noVNC Proxy Server on port 6080..."
/usr/share/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 0.0.0.0:6080 &
sleep 1

echo "Launching Chrome with remote debugging..."
google-chrome \
  --no-sandbox \
  --disable-dev-shm-usage \
  --disable-gpu \
  --remote-debugging-address=0.0.0.0 \
  --remote-debugging-port=9222 \
  --user-data-dir=/tmp/chrome-debug-profile \
  --window-size=1280,1024 \
  about:blank &

sleep 2

echo "Launching Hermes Gateway..."
mkdir -p /tmp/hermes
touch /tmp/hermes/gateway.log
nohup hermes gateway run > /tmp/hermes/gateway.log 2>&1 &
sleep 3


echo "=================================================="
echo "GUI Chrome is active"
echo "noVNC: http://localhost:6080/vnc.html"
echo "Chrome DevTools endpoint: http://localhost:9222"
echo "=================================================="

tail -f /dev/null
