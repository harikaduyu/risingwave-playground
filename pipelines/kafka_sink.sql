-- Kafka Sinks for NATS to Kafka Pipeline
-- Simple pass-through: sends all NATS events directly to Kafka

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
