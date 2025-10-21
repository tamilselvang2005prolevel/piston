#!/bin/bash
# ---- Render-safe writable setup ----
mkdir -p /tmp/isolate /tmp/piston
chmod 777 /tmp/isolate /tmp/piston

# Piston still wants /piston → make a symlink
if [ ! -e /piston ]; then
  ln -s /tmp/piston /piston
fi

# Environment vars (optional but fine)
export PISTON_TEMPDIR=/tmp/isolate
export DATA_DIRECTORY=/tmp/piston
export data_directory=/tmp/piston
# ------------------------------------

CGROUP_FS="/sys/fs/cgroup"
if [ ! -e "$CGROUP_FS" ]; then
  echo "Warning: Cannot find $CGROUP_FS. Skipping cgroup setup (Render read-only)"
else
  echo "Cgroup filesystem found (read-only on Render, skipping setup)"
fi

echo "Initialized fake cgroup (Render-safe)"
chown -R piston:piston /tmp/piston || true

exec su -- piston -c 'ulimit -n 65536 && node /piston_api/src'
