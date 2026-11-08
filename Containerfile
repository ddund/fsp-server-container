# --- Build stage ---
FROM registry.access.redhat.com/ubi9/ubi@sha256:1963e00991088221a3405be7eb315a3dbc0be0f1f7440f0bd537d481cf33c83e AS build
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
 && dnf install -y python3-scons gcc make \
 && dnf clean all
COPY fsp-code/ /fsp-code/
# -std=gnu17 avoids C23 pointer-type errors that break old FSP sources on gcc >= 14
RUN cd /fsp-code \
 && scons install CFLAGS="-std=gnu17" without-clients=yes without-fspscan=yes prefix=/usr sysconfdir=/etc

# --- Runtime stage ---
FROM registry.access.redhat.com/ubi9/ubi-micro@sha256:6d9eff186ce3ccf399c1835265e7fd3f83bd112cc3422da2d39fd44e234aab59
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
