FROM jcrugzz/base-alpine:3.10.3

ARG NODE_VERSION=14.15.0
ARG NPM_VERSION=6
ARG NATIVE=false
ENV NATIVE=${NATIVE}
ARG INTL

# ENV VERSION=v0.10.48 CFLAGS="-D__USE_MISC" NPM_VERSION=2
# ENV VERSION=v0.12.14 NPM_VERSION=2
# ENV VERSION=v4.7.0 NPM_VERSION=3
# ENV VERSION=v5.11.1 NPM_VERSION=3
# ENV VERSION=v8.12.0 NPM_VERSION=6
# ENV VERSION=v12.18.4  NPM_VERSION=6 YARN_VERSION=latest
ENV VERSION=v${NODE_VERSION} NPM_VERSION=${NPM_VERSION} YARN_VERSION=latest

# For base builds
# ENV CONFIG_FLAGS="--without-npm" RM_DIRS=/usr/include
# ENV CONFIG_FLAGS="--fully-static --without-npm" DEL_PKGS="libgcc libstdc++" RM_DIRS=/usr/include
ENV INTL_CONFIG_FLAGS="--with-intl=full-icu --download=all"
ENV CONFIG_FLAGS=${INTL:+$INTL_CONFIG_FLAGS}

# TEMPORARY!
RUN echo "version: $VERSION, npm_version: $NPM_VERSION, config: $CONFIG_FLAGS, native: $NATIVE"

RUN apk add --no-cache curl make gcc g++ python linux-headers binutils-gold gnupg libstdc++ && \
  for server in hkps://keys.openpgp.org keyserver.ubuntu.com; do \
    gpg --keyserver $server --recv-keys \
      4ED778F539E3634C779C87C6D7062848A1AB005C \
      94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
      74F12602B6F1C4E913FAA37AD3A89613643B6201 \
      71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
      8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
      C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
      C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
      DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
      A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
      108F52B48DB57BB0CC439B2997B01419BD92F80A \
      B9E2F5981AA6E0CD28160D9FF13993A75599653C && break; \
  done && \
  curl -sfSLO https://nodejs.org/dist/${VERSION}/node-${VERSION}.tar.xz && \
  curl -sfSL https://nodejs.org/dist/${VERSION}/SHASUMS256.txt.asc | gpg -d -o SHASUMS256.txt && \
  grep " node-${VERSION}.tar.xz\$" SHASUMS256.txt | sha256sum -c | grep ': OK$' && \
  tar -xf node-${VERSION}.tar.xz && \
  cd node-${VERSION} && \
  ./configure --prefix=/usr ${CONFIG_FLAGS} && \
  make -j$(getconf _NPROCESSORS_ONLN) && \
  make install && \
  cd / && \
  if [ -z "$CONFIG_FLAGS" ]; then \
    if [ -n "$NPM_VERSION" ]; then \
      npm install -g npm@${NPM_VERSION}; \
    fi; \
    find /usr/lib/node_modules/npm -type d \( -name test -o -name .bin \) | xargs rm -rf; \
    if [ -n "$YARN_VERSION" ]; then \
      for server in hkps://keys.openpgp.org keyserver.ubuntu.com; do \
        gpg --keyserver $server --recv-keys \
          6A010C5166006599AA17F08146C2130DFD2497F5 && break; \
      done && \
      curl -sfSL -O https://yarnpkg.com/${YARN_VERSION}.tar.gz -O https://yarnpkg.com/${YARN_VERSION}.tar.gz.asc && \
      gpg --batch --verify ${YARN_VERSION}.tar.gz.asc ${YARN_VERSION}.tar.gz && \
      mkdir /usr/local/share/yarn && \
      tar -xf ${YARN_VERSION}.tar.gz -C /usr/local/share/yarn --strip 1 && \
      ln -s /usr/local/share/yarn/bin/yarn /usr/local/bin/ && \
      ln -s /usr/local/share/yarn/bin/yarnpkg /usr/local/bin/ && \
      rm ${YARN_VERSION}.tar.gz*; \
    fi; \
  fi && \
  if [ "$NATIVE" != "true" ]; then \
    apk del curl make gcc g++ python linux-headers binutils-gold gnupg ${DEL_PKGS}; \
  fi && \
  rm -rf ${RM_DIRS} /node-${VERSION}* /SHASUMS256.txt /tmp/* /var/cache/apk/* \
    /usr/share/man/* /usr/share/doc /root/.npm /root/.node-gyp /root/.config \
    /usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/docs \
    /usr/lib/node_modules/npm/html /usr/lib/node_modules/npm/scripts && \
  { rm -rf /root/.gnupg || true; }
