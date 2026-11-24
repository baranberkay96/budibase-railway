# Budibase proxy 4.1.0 (official nginx image, pinned by digest) with a resolver hook for Railway:
# upstream defaults the nginx resolver to Docker's 127.0.0.11, which does not exist on Railway.
ARG BUDIBASE_PROXY_IMAGE=budibase/proxy:v4.1.0@sha256:ab4d98d9e5ab4b9e1a4144b66f9827dd28bb19d4e36f90eaf98412118af80f30
FROM ${BUDIBASE_PROXY_IMAGE}
COPY --chmod=0755 05-railway-resolver.envsh /docker-entrypoint.d/05-railway-resolver.envsh
ENV PORT=10000
