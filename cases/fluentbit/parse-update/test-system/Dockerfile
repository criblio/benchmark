ARG TAG=latest
FROM fluent/fluent-bit:${TAG}

COPY ./fluent-bit.conf /fluent-bit/etc/fluent-bit.conf
COPY ./test.lua        /fluent-bit/etc/test.lua
