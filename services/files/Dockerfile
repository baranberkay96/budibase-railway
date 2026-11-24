# SeaweedFS 4.53 (single-node server + S3 gateway), pinned by digest.
# Budibase forces path-style S3 requests (it was built for MinIO), which new Railway Buckets
# reject, so files live on this volume; SeaweedFS replaces the discontinued MinIO images.
ARG SEAWEEDFS_IMAGE=chrislusf/seaweedfs:4.53@sha256:ccad23e18639c8b98cee17e7100b95830a06077b56d8e5b006d6dcf8ec5e94a0
FROM ${SEAWEEDFS_IMAGE}
COPY --chmod=0755 railway-files.sh /usr/local/bin/railway-files.sh
ENTRYPOINT ["/usr/local/bin/railway-files.sh"]
