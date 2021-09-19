FROM ubuntu:18.04
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        nmap \
        ca-certificates \
    && apt-get autoremove && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /sbin/entrypoint.sh
ENTRYPOINT ["/sbin/entrypoint.sh"]


