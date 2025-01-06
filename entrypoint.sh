#!/bin/bash

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

# Run rtl_sdr, sox, and darkice
rtl_sdr -d rtl_tcp=${RTL_TCP_SERVER:-localhost}:1234 -g ${GAIN} -f ${FREQUENCY} -s ${SAMPLE_RATE} | \
sox -t raw -r ${SAMPLE_RATE} -e signed -b 16 -c 2 -V1 - -t wav - rate ${SAMPLE_RATE_AUDIO} | \
darkice -c /etc/darkice.cfg
