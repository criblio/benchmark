ARG TAG=latest
FROM timberio/vector:${TAG}-debian

RUN rm -f /etc/vector/vector.yaml
COPY vector.yaml /etc/vector/vector.yaml
COPY vector.toml /etc/vector/vector.toml
