#!/bin/bash
echo "Starting pulseaudio..."
su - user -c "pulseaudio -D --exit-idle-time=-1"
sleep 2

echo "Starting stream..."
bash spotify-stream.sh 
sleep 5

echo "Starting spotifyd..."
su - user -c "spotifyd --username $SPOTIFY_USERNAME --password $SPOTIFY_PASSWORD"
sleep 2
