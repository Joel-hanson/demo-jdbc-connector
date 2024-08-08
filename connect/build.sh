#!/usr/bin/env sh

# Builds the Connectors for the Dockerfile requires Maven, git and gradle
set -e

# Cleanup
rm -rf ./connectors/*
mkdir -p ./connectors

# Downloading jdbc connector
(
curl -L -o jdbc-connector-for-apache-kafka-6.10.0.zip https://github.com/Aiven-Open/jdbc-connector-for-apache-kafka/releases/download/v6.10.0/jdbc-connector-for-apache-kafka-6.10.0.zip
unzip -o jdbc-connector-for-apache-kafka-6.10.0.zip -d ./connectors
rm -rf jdbc-connector-for-apache-kafka-6.10.0.zip
)

# Downloading debezium connector
(
curl -L -o debezium-connector-postgres-2.7.0.Final-plugin.tar.gz https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/2.7.0.Final/debezium-connector-postgres-2.7.0.Final-plugin.tar.gz
tar -xzf debezium-connector-postgres-2.7.0.Final-plugin.tar.gz -C ./connectors
rm -rf debezium-connector-postgres-2.7.0.Final-plugin.tar.gz
)