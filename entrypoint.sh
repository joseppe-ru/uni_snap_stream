#!/bin/bash

# Start mopidy in the background
/usr/bin/mopidy --config /config/mopidy.conf &

# Start snacast-server
snacast-server-start-command

# Keep the container running
wait
