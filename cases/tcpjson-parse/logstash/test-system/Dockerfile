ARG TAG=latest
FROM docker.elastic.co/logstash/logstash:${TAG}

RUN rm -f /usr/share/logstash/pipeline/logstash.conf
ADD pipeline/ /usr/share/logstash/pipeline/

