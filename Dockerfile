ARG debian_tag=bookworm-20240701-slim
FROM docker.io/library/debian:${debian_tag} AS build

ARG siege_version=c9271c80cb097cd45e61f8a13d5b8a51b339f857

RUN set -ex \
  && apt-get update \
  && apt-get install -y \
    libssl-dev \
    autoconf \
    automake \
    libtool \
    make \
    zlib1g \
    zlib1g-dev \
    curl \
  && siege_tmp=$(mktemp -d) \
  && cd ${tempDir} \
  && curl -L "https://github.com/JoeDog/siege/archive/${siege_version}.tar.gz" --output siege.tar.gz \
  && tar xzvf siege.tar.gz \
  && cd siege-$siege_version \
  && utils/bootstrap \
  && ./configure --with-ssl=/usr/bin/openssl --bindir=/usr/local/bin \
  && make \
  && make install

FROM gcr.io/distroless/static-debian12:nonroot AS final

LABEL maintainer="zt-sv"
USER nonroot:nonroot

ENV HOME=/siege
WORKDIR $HOME

COPY --from=build --chown=nonroot:nonroot --chmod=0550 /usr/local/bin/siege /usr/local/bin/siege
COPY --from=build --chown=nonroot:nonroot --chmod=0440 /usr/local/etc/siegerc /usr/local/etc/siegerc
COPY --from=build --chown=nonroot:nonroot --chmod=0440 /usr/local/etc/urls.txt /usr/local/etc/urls.txt

COPY --from=build --chown=nonroot:nonroot /lib/x86_64-linux-gnu/libssl.so.3 /lib/x86_64-linux-gnu/libssl.so.3
COPY --from=build --chown=nonroot:nonroot /lib/x86_64-linux-gnu/libcrypto.so.3 /lib/x86_64-linux-gnu/libcrypto.so.3
COPY --from=build --chown=nonroot:nonroot /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/libz.so.1
COPY --from=build --chown=nonroot:nonroot /lib/x86_64-linux-gnu/libc.so.6 /lib/x86_64-linux-gnu/libc.so.6
COPY --from=build --chown=nonroot:nonroot /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/x86_64-linux-gnu/libgcc_s.so.1
COPY --from=build --chown=nonroot:nonroot /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2

ENTRYPOINT ["/usr/local/bin/siege"]
CMD ["--help"]
