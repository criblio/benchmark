ARG TAG=latest
FROM docker.elastic.co/logstash/logstash:${TAG}

RUN rm -f /usr/share/logstash/pipeline/logstash.conf
RUN rm -f /usr/share/logstash/config/logstash.conf
COPY pipeline/ /usr/share/logstash/pipeline/
COPY config/ /usr/share/logstash/config/
