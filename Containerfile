# --- Build stage ---
FROM registry.access.redhat.com/ubi9/ubi@sha256:8b212f75a0e5a156ac28b1c5c030d2e8a07715254e19d522286118279399af81 AS build
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
 && dnf install -y python3-scons gcc make \
 && dnf clean all
COPY fsp-code/ /fsp-code/
# -std=gnu17 avoids C23 pointer-type errors that break old FSP sources on gcc >= 14
RUN cd /fsp-code \
 && scons install CFLAGS="-std=gnu17" without-clients=yes without-fspscan=yes prefix=/usr sysconfdir=/etc

# --- Runtime stage ---
FROM registry.access.redhat.com/ubi9/ubi-micro@sha256:b59ac4f291d86027c2681f7a7b1cbf7448972fc55a6cb8e25cab5aa5eef5ce5f
COPY --from=build /usr/bin/fspd /usr/bin/fspd
EXPOSE 21/udp
ENTRYPOINT ["/usr/bin/fspd"]

ARG FSP_VERSION
ARG FSP_REVISION
LABEL org.opencontainers.image.title="fsp-server" \
      org.opencontainers.image.description="FSP (File Service Protocol) server (fspd)" \
      org.opencontainers.image.source="https://github.com/ddund/fsp-server-container" \
      org.opencontainers.image.version="${FSP_VERSION}" \
      org.opencontainers.image.revision="${FSP_REVISION}"
