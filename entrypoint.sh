#!/bin/bash

# List of required environment variables
required_vars=("ICECAST_SERVER" "ICECAST_PASSWORD" "RTL_TCP_SERVER")

# Check if required environment variables are set
for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo "Error: Required environment variable '$var' is not set."
    exit 1
  fi
done

# Create a FIFO (named pipe) for audio data
AUDIO_PIPE="/tmp/audio_pipe"
if [ ! -p "$AUDIO_PIPE" ]; then
  mkfifo "$AUDIO_PIPE"
fi

# Generate DarkIce configuration
cat <<EOF > /etc/darkice.cfg
[general]
duration        = ${DURATION}
bufferSecs      = ${BUFFER_SECS}
reconnect       = yes

[input]
device          = $AUDIO_PIPE
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

# Start rtl_sdr and sox in the background to write audio to the pipe
rtl_sdr -d rtl_tcp=${RTL_TCP_SERVER} -g ${GAIN} -f ${FREQUENCY} -s ${SAMPLE_RATE} | \
sox -t raw -r ${SAMPLE_RATE} -e signed -b 16 -c 2 -V1 - -t wav - rate ${SAMPLE_RATE_AUDIO} > "$AUDIO_PIPE" &

# Start DarkIce to read from the pipe
darkice -c /etc/darkice.cfg
