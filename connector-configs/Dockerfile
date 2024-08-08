FROM curlimages/curl:7.73.0

WORKDIR /app
COPY apply-connector.sh /app/apply-connector.sh
COPY *.json /app/

ENTRYPOINT [ "apply-connector.sh" ]