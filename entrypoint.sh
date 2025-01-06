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
  <!-- Icecast server details -->
  <url>http://${ICECAST_SERVER}:${ICECAST_PORT}/${MOUNT_POINT}</url>
  <sourcepassword>${ICECAST_PASSWORD}</sourcepassword>

  <!-- Stream format and input -->
  <format>${FORMAT}</format>
  <filename>-</filename> <!-- Read from stdin -->
  <encoding>raw</encoding>
  <bitrate>${BITRATE}</bitrate>

  <!-- Stream metadata -->
  <svrinfoname>${STREAM_NAME}</svrinfoname>
  <svrinfourl>http://${ICECAST_SERVER}</svrinfourl>
  <svrinfogenre>Kitsap Radio</svrinfogenre>
  <svrinfodescription>Live stream at ${FREQUENCY} Hz</svrinfodescription>
  <svrinfobitrate>${BITRATE}</svrinfobitrate>
  <svrinfochannels>${CHANNEL}</svrinfochannels>
  <svrinfosamplerate>${SAMPLE_RATE_AUDIO}</svrinfosamplerate>
  <svrinfopublic>1</svrinfopublic>
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
