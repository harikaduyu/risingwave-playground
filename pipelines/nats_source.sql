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
