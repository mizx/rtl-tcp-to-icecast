# Use a lightweight Debian base image
FROM debian:bullseye-slim

# Update package lists
RUN apt-get update

# Install required packages
RUN apt-get install -y \
    rtl-sdr \
    sox \
    darkice \
    netcat-openbsd \
    pulseaudio \
    alsa-utils \
    kmod

# Clean up to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose port for Icecast streaming
EXPOSE 8000

# Default environment variables (optional ones)
ENV GAIN=30
ENV SAMPLE_RATE=2400000
ENV BUFFER_SECS=5
ENV BITRATE=32
ENV FORMAT=mp3
ENV FREQUENCY=155835000
ENV MOUNT_POINT=radio.mp3
ENV STREAM_NAME="My ${FREQUENCY} Hz Stream"
ENV DURATION=0
ENV SAMPLE_RATE_AUDIO=24000
ENV BITS_PER_SAMPLE=16
ENV CHANNEL=1
ENV ICECAST_PORT=8000
ENV RTL_TCP_PORT=1234

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
