# --- Build stage ---
FROM registry.access.redhat.com/ubi9/ubi@sha256:1e9f0ed9fceafb40878bc1705ff124aa150e3fed873f18c42cdc2dded319e0a8 AS build
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
 && dnf install -y python3-scons gcc make \
 && dnf clean all
COPY fsp-code/ /fsp-code/
# -std=gnu17 avoids C23 pointer-type errors that break old FSP sources on gcc >= 14
RUN cd /fsp-code \
 && scons install CFLAGS="-std=gnu17" without-clients=yes without-fspscan=yes prefix=/usr sysconfdir=/etc

# --- Runtime stage ---
FROM registry.access.redhat.com/ubi9/ubi-micro@sha256:dbd325b96bcd432dd42816d31412bdf1dc0fb973b79ed310344bc23c76c068db
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
