FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# set version label
ARG BUILD_DATE
ARG VERSION
ARG NZBHYDRA2_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="nemchik"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV NZBHYDRA2_RELEASE_TYPE="Release"

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    curl \
    jq \
    openjdk-11-jre-headless \
    netcat \
    python3 \
    unzip && \
  echo "**** install nzbhydra2 ****" && \
  if [ -z ${NZBHYDRA2_RELEASE+x} ]; then \
  NZBHYDRA2_RELEASE=$(curl -sX GET "https://api.github.com/repos/theotherp/nzbhydra2/releases/latest" \
  | jq -r .tag_name); \
  fi && \
  NZBHYDRA2_VER=${NZBHYDRA2_RELEASE#v} && \
  curl -o \
    /tmp/nzbhydra2.zip -L \
    "https://github.com/theotherp/nzbhydra2/releases/download/v${NZBHYDRA2_VER}/nzbhydra2-${NZBHYDRA2_VER}-linux.zip" && \
  mkdir -p /app/nzbhydra2/bin && \
  unzip /tmp/nzbhydra2.zip -d /app/nzbhydra2/bin && \
  chmod +x /app/nzbhydra2/bin/nzbhydra2wrapperPy3.py && \
  echo "ReleaseType=${NZBHYDRA2_RELEASE_TYPE}\nPackageVersion=${VERSION}\nPackageAuthor=linuxserver.io" > /app/nzbhydra2/package_info && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 5076
VOLUME /config
