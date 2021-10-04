FROM ubuntu:18.04
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        netcat curl \
        jq \
        ca-certificates \
        git \
    && apt-get autoremove && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ADD https://api.gogen.io/linux/gogen /opt/gogen/
RUN chmod +x /opt/gogen/gogen

ADD configs /opt/gogen/configs
ADD entrypoint.sh /sbin/entrypoint.sh
ENTRYPOINT ["/sbin/entrypoint.sh"]

