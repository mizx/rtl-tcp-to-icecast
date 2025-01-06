# RTL-TCP to Icecast Streamer

A lightweight Docker container for streaming public safety radio (or other RF signals) using an RTL-SDR dongle, RTL-TCP, and Icecast.

## Features

- Stream any RF signal to an Icecast server.
- Fully configurable via environment variables.
- Supports Narrowband FM (NFM) for public safety radio channels.
- Low-latency real-time streaming.

## Requirements

1. An RTL-SDR dongle.
2. An RTL-TCP server running (can be on the same or a different machine).
3. An Icecast server for streaming audio.

## Usage

### Running with Docker

```bash
docker run --rm \
  -e FREQUENCY=155430000 \
  -e GAIN=35 \
  -e SAMPLE_RATE=2400000 \
  -e BUFFER_SECS=3 \
  -e BITRATE=64 \
  -e FORMAT=mp3 \
  -e MOUNT_POINT=sheriff.mp3 \
  -e STREAM_NAME="Sheriff Dispatch Channel" \
  -e ICECAST_SERVER=192.168.1.100 \
  -e ICECAST_PORT=8000 \
  -e ICECAST_PASSWORD=hackme \
  mizx/rtl-tcp-to-icecast
```

## Environment Variables

| Variable            | Required | Default                     | Description                                            |
|---------------------|----------|-----------------------------|--------------------------------------------------------|
| `FREQUENCY`         | Yes      | None                        | Frequency to tune to (in Hz).                          |
| `GAIN`              | No       | `30`                        | Signal gain (in dB).                                   |
| `SAMPLE_RATE`       | No       | `2400000`                   | RTL-SDR sample rate (in Hz).                           |
| `BUFFER_SECS`       | No       | `5`                         | Audio buffer size (in seconds).                        |
| `BITRATE`           | No       | `32`                        | Audio bitrate for Icecast (in kbps).                   |
| `FORMAT`            | No       | `mp3`                       | Audio format (`mp3`, `ogg`, etc.).                     |
| `MOUNT_POINT`       | No       | `radio.mp3`                 | Mount point (stream URL path) on Icecast.              |
| `STREAM_NAME`       | No       | "My ${FREQUENCY} Hz Stream" | Name of the stream displayed on Icecast.               |
| `DURATION`          | No       | `0`                         | Stream duration in seconds (`0` = unlimited).          |
| `SAMPLE_RATE_AUDIO` | No       | `24000`                     | Audio sample rate for output (in Hz).                  |
| `BITS_PER_SAMPLE`   | No       | `16`                        | Bits per sample for audio output.                      |
| `CHANNEL`           | No       | `1`                         | Number of audio channels (`1` = mono, `2` = stereo).   |
| `ICECAST_SERVER`    | Yes      | None                        | Icecast server address.                                |
| `ICECAST_PORT`      | No       | `8000`                      | Icecast server port.                                   |
| `ICECAST_PASSWORD`  | Yes      | None                        | Password for Icecast server.                           |

## Building the Image

```bash
docker build -t mizx/rtl-tcp-to-icecast .
```

## License

This project is licensed under the MIT License.

