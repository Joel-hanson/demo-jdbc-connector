FROM alpine as builder

RUN apk update
RUN apk --no-cache add curl

RUN curl -L "https://downloads.apache.org/kafka/3.8.0/kafka_2.12-3.8.0.tgz" -o kafka.tgz
RUN mkdir /opt/kafka \
    && tar -xf kafka.tgz -C /opt/kafka --strip-components=1

COPY build.sh .
RUN sh build.sh

FROM openjdk:11-slim-bullseye

RUN apt update -y && apt install curl -y
COPY docker-entrypoint.sh /
RUN addgroup --gid 5000 --system esgroup && \
    adduser --uid 5000 --ingroup esgroup --system esuser

COPY --chown=esuser:esgroup --from=builder /opt/kafka/bin/ /opt/kafka/bin/
COPY --chown=esuser:esgroup --from=builder /opt/kafka/libs/ /opt/kafka/libs/
COPY --chown=esuser:esgroup --from=builder /opt/kafka/config/ /opt/kafka/config/
RUN mkdir /opt/kafka/logs && chown esuser:esgroup /opt/kafka/logs
RUN mkdir /opt/kafka/plugins && chown esuser:esgroup /opt/kafka/plugins
COPY --chown=esuser:esgroup --from=builder /connectors /opt/kafka/plugins

WORKDIR /opt/kafka

EXPOSE 8083

USER esuser

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]