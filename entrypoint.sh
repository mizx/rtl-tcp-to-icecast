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

# Create a FIFO (named pipe) for audio data
AUDIO_PIPE="/tmp/audio_pipe"
if [ ! -p "$AUDIO_PIPE" ]; then
  mkfifo "$AUDIO_PIPE"
fi

# Generate Ezstream XML configuration
cat <<EOF > /etc/ezstream.xml
<ezstream>
  <url>http://${ICECAST_SERVER}:${ICECAST_PORT}/radio.mp3</url>
  <sourcepassword>${ICECAST_PASSWORD}</sourcepassword>
  <format>MP3</format>
  <filename>${AUDIO_PIPE}</filename>
  <bitrate>${BITRATE}</bitrate>
  <samplerate>${SAMPLE_RATE_AUDIO}</samplerate>
  <channels>${CHANNEL}</channels>
  <metadata>
    <name>${STREAM_NAME}</name>
    <description>Streaming with Ezstream</description>
    <genre>Local Radio</genre>
  </metadata>
</ezstream>
EOF

echo "Generated Ezstream configuration:"
cat /etc/ezstream.xml

# Start netcat and rtl_fm to process the audio stream and write to the pipe
nc ${RTL_TCP_HOSTNAME} ${RTL_TCP_PORT} | \
rtl_fm -M fm -s ${SAMPLE_RATE} -f ${FREQUENCY} -g ${GAIN} | \
sox -t raw -r ${SAMPLE_RATE} -e signed -b 16 -c 1 -V1 - -t mp3 - > "$AUDIO_PIPE" &

# Start Ezstream to read from the named pipe and stream to Icecast
ezstream -c /etc/ezstream.xml
