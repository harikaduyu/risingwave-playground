-- NATS Source for CloudEvents
-- Reads CloudEvents from NATS JetStream

-- Create NATS JetStream source for CloudEvents
CREATE SOURCE cloudevents_nats_source (
    specversion VARCHAR,
    id VARCHAR,
    time TIMESTAMP,
    type VARCHAR,
    source VARCHAR,
    userAgentHeader VARCHAR,
    actorType VARCHAR,
    actorId VARCHAR,
    actorRole VARCHAR,
    eventSpecificData VARCHAR
) WITH (
    connector = 'nats',
    server_url = 'nats-server:4222',
    subject = 'cloudevents',
    stream = 'cloudevents-stream',
    connect_mode = 'plain',
    consumer.durable_name = 'risingwave-cloudevents-consumer'
) FORMAT PLAIN ENCODE JSON;


-- Create Kafka sink for all CloudEvents from NATS
CREATE SINK cloudevents_kafka_sink AS
SELECT
    specversion,
    id,
    time,
    type,
    source,
    userAgentHeader,
    actorType,
    actorId,
    actorRole,
    eventSpecificData
FROM cloudevents_nats_source
WITH (
    connector = 'kafka',
    properties.bootstrap.server = 'message_queue:29092',
    topic = 'cloudevents'
)
FORMAT PLAIN ENCODE JSON;
