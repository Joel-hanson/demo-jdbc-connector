#!/usr/bin/env sh

set +x
KAFKA_CONNECT_URL="http://connect:8083/connectors"

# Wait for Kafka Connect to be ready
while ! curl -s $KAFKA_CONNECT_URL; do
    echo "Waiting for Kafka Connect to be ready..."
    sleep 5
done

apply_connector() {
    connector_name=$1
    connector_config_file=$2

    # Check if the connector already exists
    connector_status=$(curl -s -o /dev/null -w "%{http_code}" $KAFKA_CONNECT_URL/"$connector_name")

    if [ "$connector_status" -eq 200 ]; then
        echo "Connector $connector_name already exists, updating..."
        curl -X PUT -H "Content-Type: application/json" --data @"$connector_config_file" $KAFKA_CONNECT_URL/"$connector_name"/config
    else
        echo "Creating connector $connector_name..."
        curl -X POST -H "Content-Type: application/json" --data @"$connector_config_file" $KAFKA_CONNECT_URL
    fi
}

# Apply or update connectors
apply_connector "source-connector" "connector-source.json"
apply_connector "source-connector" "connector-source-debezium.json"
apply_connector "sink-connector" "connector-sink.json"

echo "Connector configuration applied."
