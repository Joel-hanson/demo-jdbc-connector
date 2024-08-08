# Kafka JDBC Sink Connector with Tombstone Records

This repository demonstrates how to use tombstone records to delete records/rows from a sink system using the Aiven JDBC Sink Connector for Kafka. Tombstone records are special records in Kafka that have a null value and are used to signify the deletion of a record.

## Table of Contents

- [Docker Setup](#docker-setup)
- [Initialization Script](#initialization-script)
- [Connector Configurations](#connector-configurations)
- [Usage](#usage)
- [Tombstone Records](#tombstone-records)
- [Configuring PostgreSQL for Delete Events](#configuring-postgresql-for-delete-events)
- [Testing a Delete Scenario](#testing-a-delete-scenario)
- [Benefits of Having Delete Feature](#benefits-of-having-delete-feature)
- [References](#references)

## Docker Setup

The `docker-compose.yml` file sets up the necessary services for the demonstration:

- **PostgreSQL**: The sink database, with logical replication enabled.
- **Kafka**: The Kafka broker.
- **Connect**: The Kafka Connect worker to run connectors.
- **Connectors**: Service to apply the connector configurations.

## Initialization Script

The `init.sql` script initializes the PostgreSQL database with a `user_profile` table and inserts sample data. It also sets the `REPLICA IDENTITY` to `FULL` to capture all changes, including deletes.

## Connector Configurations

### Source Connector

The `connector-source-debezium.json` configures the Debezium PostgreSQL Connector to:

- Connect to the PostgreSQL database.
- Stream changes from the `user_profile` table to `debezium.public.user_profile` topic.
- Emit tombstone records for deletions.

### Sink Connector

The `connector-sink.json` configures the Aiven JDBC Sink Connector to:

- Connect to the PostgreSQL database.
- Use the `debezium.public.user_profile` topic to apply changes to `debezium_public_user_profile` table.
- Enable deletion of records based on tombstone messages.

## Usage

1. **Clone the repository**:

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Start the services**:

   ```bash
   docker-compose up --build
   ```

3. **Verify**:
   - Ensure the connectors are running and syncing data.
   - Check that deletions in the source database result in tombstone records and corresponding deletions in the sink database.

## Tombstone Records

Tombstone records in Kafka are used to indicate the deletion of a record. They have a key but a null value. This is how a tombstone record looks in Kafka:

```shell
  key: 2
  value: null
```

In this example, the record with `id = 2` is marked for deletion. When the sink connector processes this tombstone record, it will delete the corresponding row in the PostgreSQL database.

## Configuring PostgreSQL for Delete Events

To ensure PostgreSQL emits delete events that can be captured and processed, you need to configure logical replication and set the replica identity to `FULL`. This ensures all changes, including deletions, are captured and can be emitted as tombstone records.

1. **Enable Logical Replication**: In the `docker-compose.yml` file, PostgreSQL is configured with logical replication by setting `wal_level=logical`, `max_replication_slots=4`, and `max_wal_senders=4`.

2. **Set Replica Identity**: In the `init.sql` script, the `REPLICA IDENTITY` is set to `FULL` for the `user_profile` table:

   ```sql
   ALTER TABLE user_profile REPLICA IDENTITY FULL;
   ```

## Testing a Delete Scenario

To test the delete scenario, follow these steps:

1. **Insert a record**:

   ```bash
   docker-compose exec postgres psql -U postgres -d postgres -c "INSERT INTO user_profile (name, email) VALUES ('Test User', 'testuser@example.com');"
   ```

2. **Verify the record is in the sink database**:

   ```bash
   docker-compose exec postgres psql -U postgres -d postgres -c "SELECT * FROM debezium_public_user_profile WHERE email='testuser@example.com';"
   ```

3. **Delete the record in the source database**:

   ```bash
   docker-compose exec postgres psql -U postgres -d postgres -c "DELETE FROM user_profile WHERE email='testuser@example.com';"
   ```

4. **Verify the record is deleted in the sink database**:

   ```bash
   docker-compose exec postgres psql -U postgres -d postgres -c "SELECT * FROM debezium_public_user_profile WHERE email='testuser@example.com';"
   ```

**Without Delete Feature:**

```sql
| id | name    | email             | created_at          |
|----|---------|-------------------|---------------------|
| 1  | Alice   | alice@example.com | 2024-01-01 12:00:00 |
| 2  | Bob     | bob@example.com   | 2024-01-02 12:00:00 |
| 3  | Charlie | charlie@example.com| 2024-01-03 12:00:00 |
```

**With Delete Feature:**

If a record is deleted in the source:

```sql
| id | name    | email             | created_at          |
|----|---------|-------------------|---------------------|
| 1  | Alice   | alice@example.com | 2024-01-01 12:00:00 |
| 3  | Charlie | charlie@example.com| 2024-01-03 12:00:00 |
```

## Benefits of Having Delete Feature

1. **Efficient Deletions**: Provides a standardized way to delete records from a sink system, leveraging Kafka's capabilities.
2. **Data Consistency**: Ensures consistent state between Kafka and the sink system.
3. **Simplified Data Management**: Simplifies deletion handling in data pipelines.
4. **Reduced Complexity**: Eliminates the need for custom deletion logic in the sink system.

## References

- [Aiven JDBC Sink Connector](https://github.com/aiven/jdbc-connector-for-apache-kafka)
- [Debezium PostgreSQL Connector](https://debezium.io/documentation/reference/connectors/postgresql.html)
