FROM alpine:3.19 AS build

WORKDIR /build

COPY . .

RUN \
  apk --no-cache add \
    linux-headers \
    git \
    g++ \
    make \
    pkgconfig \
    libtool \
    ca-certificates \
    libressl-dev \
    zlib-dev \
    lmdb-dev \
    flatbuffers-dev \
    libsecp256k1-dev \
    zstd-dev \
  && rm -rf /var/cache/apk/* \
  && git submodule update --init \
  && make setup-golpe \
  && make clean \
  && make -j4

FROM alpine:3.19

WORKDIR /app

RUN \
  apk --no-cache add \
    lmdb \
    flatbuffers \
    libsecp256k1 \
    libb2 \
    zstd \
    libressl \
    bash \
    curl \
    python3 \
  && rm -rf /var/cache/apk/*

HEALTHCHECK --interval=60s --retries=2 --timeout=10s CMD curl -ILfSs http://localhost:7777/ > /dev/null || exit 1

COPY strfry.sh /app/strfry.sh
COPY strfry.conf /etc/strfry.conf.default
COPY write-policy.py /app/write-policy.py
COPY strfry-router.conf /etc/strfry-router.conf

RUN chmod +x /app/strfry.sh
RUN chmod +x /app/write-policy.py

COPY --from=build /build/strfry strfry

EXPOSE 7777

CMD ["/app/strfry.sh"]
