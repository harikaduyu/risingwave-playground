-- Simple CloudEvents Pipeline with Single NATS Subject
-- Generates CloudEvents data and sinks it to one NATS subject

-- Create CloudEvents data generator (only if it doesn't exist)
CREATE SOURCE IF NOT EXISTS cloudevents_generator (
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
    connector = 'datagen',
    
    -- specversion: Always "1.0"
    fields.specversion.kind = 'random',
    fields.specversion.length = 3,
    fields.specversion.seed = 1,
    
    -- id: UUID-like identifier (36 chars)
    fields.id.kind = 'random',
    fields.id.length = 36,
    fields.id.seed = 2,
    
    -- time: Recent timestamps
    fields.time.kind = 'random',
    fields.time.max_past = '1h',
    fields.time.max_past_mode = 'relative',
    fields.time.seed = 3,
    
    -- type: More realistic event types
    fields.type.kind = 'random',
    fields.type.length = 60,
    fields.type.seed = 4,
    
    -- source: Event source
    fields.source.kind = 'random',
    fields.source.length = 40,
    fields.source.seed = 5,
    
    fields.userAgentHeader.kind = 'random',
    fields.userAgentHeader.length = 80,
    fields.userAgentHeader.seed = 8,
    
    fields.actorType.kind = 'random',
    fields.actorType.length = 15,
    fields.actorType.seed = 9,
    
    fields.actorId.kind = 'random',
    fields.actorId.length = 24,
    fields.actorId.seed = 10,
    
    fields.actorRole.kind = 'random',
    fields.actorRole.length = 20,
    fields.actorRole.seed = 11,
    
    -- eventSpecificData: JSON-like string
    fields.eventSpecificData.kind = 'random',
    fields.eventSpecificData.length = 150,
    fields.eventSpecificData.seed = 12,
    
    datagen.rows.per.second = '10'
);

CREATE MATERIALIZED VIEW cloudevents_analytics AS
SELECT COUNT(*) as total_records FROM cloudevents_generator;

-- Create single NATS JetStream sink for all CloudEvents
CREATE SINK cloudevents_nats_sink AS
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
FROM cloudevents_generator
WITH (
    connector = 'nats',
    server_url = 'nats-server:4222',
    subject = 'cloudevents',
    connect_mode = 'plain',
    type = 'append-only'
);
