#!/bin/sh
# Make sure we have a writable directory for isolate
mkdir -p /tmp/isolate
chmod 777 /tmp/isolate
export PISTON_TEMPDIR=/tmp/isolate

# Start the regular entrypoint
exec /piston_api/src/docker-entrypoint.sh
