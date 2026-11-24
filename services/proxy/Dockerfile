# Budibase proxy 4.1.0 (official nginx image, pinned by digest) with two Railway adjustments:
# - a resolver hook: upstream defaults the nginx resolver to Docker's 127.0.0.11, absent on Railway
# - signed file URLs: Railway's edge adds X-Forwarded-Host/Port, which the S3 gateway would use for
#   SigV4 host verification; clear them on /files/signed/ so the signed host 'minio-service' matches
ARG BUDIBASE_PROXY_IMAGE=budibase/proxy:v4.1.0@sha256:ab4d98d9e5ab4b9e1a4144b66f9827dd28bb19d4e36f90eaf98412118af80f30
FROM ${BUDIBASE_PROXY_IMAGE}
RUN sed -i 's#^\(\s*\)proxy_set_header Host minio-service;#&\n\1proxy_set_header X-Forwarded-Host "";\n\1proxy_set_header X-Forwarded-Port "";#' /etc/nginx/templates/nginx.conf.template \
    && grep -q 'X-Forwarded-Port ""' /etc/nginx/templates/nginx.conf.template
COPY --chmod=0755 05-railway-resolver.envsh /docker-entrypoint.d/05-railway-resolver.envsh
ENV PORT=10000
