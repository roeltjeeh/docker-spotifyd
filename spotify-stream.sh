#!/usr/bin/env bash
#
# needs: Pulseaudio, VLC

# Load null sink module if not already loaded
pacmd list-sinks | grep steam 2>&1 >/dev/null
if [[ $? == 1 ]]; then
  pactl load-module module-null-sink sink_name=steam;
fi

# Get index of running Spotify sink.
# Move over if existing.
INDEX=`pacmd list-sink-inputs | grep index: | awk -F': ' '{ print $2 }'`
if [[ $INDEX != '' ]]; then
  echo "Spotify output found, moving to steam sink"
  pactl move-sink-input $INDEX steam
else
  echo "ERROR: No Spotify input found! Please change the output in the Pulseaudio mixer manually."
fi

# Get current IP address
IP=`/sbin/ifconfig  | grep 'inet '| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
tput setaf 2
echo "Serving output stream on: http://$IP:8080/pc.mp3"
echo "Stop with CTRL-C"
tput sgr0

# Start VLC, serving the sink output as MP3 stream
cvlc -q pulse://steam.monitor --sout "#transcode{acodec=mpga,ab=320,channels=2}:standard{access=http,dst=$IP:8080/pc.mp3}"
