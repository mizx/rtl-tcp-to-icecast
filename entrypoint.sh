#!/bin/bash

# List of required environment variables
required_vars=("ICECAST_SERVER" "ICECAST_PASSWORD" ""RTL_TCP_HOSTNAME"")

# Check if required environment variables are set
for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo "Error: Required environment variable '$var' is not set."
    exit 1
  fi
done

# Start Pulseaudio in the background
pulseaudio --start --exit-idle-time=-1

# Create a Pulseaudio null sink (virtual audio device)
pactl load-module module-null-sink sink_name=VirtualSink

# Generate DarkIce configuration
cat <<EOF > /etc/darkice.cfg
[general]
duration        = ${DURATION}
bufferSecs      = ${BUFFER_SECS}
reconnect       = yes

[input]
device          = default
sampleRate      = ${SAMPLE_RATE_AUDIO}
bitsPerSample   = ${BITS_PER_SAMPLE}
channel         = ${CHANNEL}

[icecast2-0]
bitrateMode     = cbr
format          = ${FORMAT}
bitrate         = ${BITRATE}
server          = ${ICECAST_SERVER}
port            = ${ICECAST_PORT}
password        = ${ICECAST_PASSWORD}
mountPoint      = ${MOUNT_POINT}
name            = "${STREAM_NAME}"
EOF

echo "Generated DarkIce configuration:"
cat /etc/darkice.cfg

# Start netcat and rtl_fm to process the audio stream and write to the Pulseaudio sink
nc ${RTL_TCP_HOSTNAME} ${RTL_TCP_PORT} | \
rtl_fm -M fm -s ${SAMPLE_RATE} -f ${FREQUENCY} -g ${GAIN} | \
sox -t raw -r ${SAMPLE_RATE} -e signed -b 16 -c 1 -V1 - -t alsa default rate ${SAMPLE_RATE_AUDIO} &

# Start DarkIce to read from the Pulseaudio virtual sink
darkice -c /etc/darkice.cfg
