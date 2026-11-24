#!/bin/sh
# Railway start script for Budibase's object store (SeaweedFS S3 gateway, MinIO-compatible).
# One identity (the MINIO_ACCESS_KEY / MINIO_SECRET_KEY pair Budibase uses) with full access;
# no anonymous access. Budibase creates its buckets itself. S3 API on [::]:$PORT, private only.
set -u
log() { echo "[railway-files] $*"; }
MINIO_ACCESS_KEY="${MINIO_ACCESS_KEY:-}"
MINIO_SECRET_KEY="${MINIO_SECRET_KEY:-}"
case "${PORT:-}" in ''|*[!0-9]*) PORT=8333 ;; esac
if [ "${#MINIO_ACCESS_KEY}" -lt 8 ] || [ "${#MINIO_SECRET_KEY}" -lt 16 ]; then
  log "WARNING: MINIO_ACCESS_KEY (8+ chars) or MINIO_SECRET_KEY (16+ chars) missing or too short; storage is locked until both are set on Files"
  MINIO_ACCESS_KEY="locked$(head -c 12 /dev/urandom | od -An -tx1 | tr -d ' \n')"
  MINIO_SECRET_KEY="$(head -c 24 /dev/urandom | od -An -tx1 | tr -d ' \n')"
fi
mkdir -p /etc/seaweedfs /data
cat > /etc/seaweedfs/s3.json <<JSON
{
  "identities": [
    {
      "name": "budibase",
      "credentials": [{"accessKey": "${MINIO_ACCESS_KEY}", "secretKey": "${MINIO_SECRET_KEY}"}],
      "actions": ["Admin", "Read", "Write", "List", "Tagging"]
    }
  ]
}
JSON
chmod 0644 /etc/seaweedfs/s3.json
log "starting SeaweedFS S3 gateway on [::]:${PORT}"
exec /entrypoint.sh server -ip=127.0.0.1 -ip.bind=:: -master.volumeSizeLimitMB=256 \
  -s3 -s3.port="${PORT}" -s3.config=/etc/seaweedfs/s3.json
