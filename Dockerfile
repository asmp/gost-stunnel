FROM debian:11-slim
WORKDIR /etc/stunnel/

EXPOSE 8080/tcp

ENV PATH="/opt/cprocsp/bin/amd64:/opt/cprocsp/sbin/amd64:${PATH}"

# dependencies
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow
RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends -y ca-certificates opensc openssl procps tzdata tar gzip curl wget lsb-base socat \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

# install cryptopro csp
COPY cprocsp/linux-amd64_deb.tgz /tmp/linux-amd64_deb.tgz
RUN set -x \
    && tar -xzvf /tmp/linux-amd64_deb.tgz -C /tmp \
    && /tmp/linux-amd64_deb/install.sh cprocsp-stunnel \
    && rm -rf /tmp/*

COPY bin/entrypoint.sh /entrypoint.sh
COPY bin/stunnel-socat.sh /stunnel-socat.sh

RUN chmod +x /entrypoint.sh
RUN chmod +x /stunnel-socat.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["stunnel_thread", "/etc/stunnel/stunnel.conf"]
