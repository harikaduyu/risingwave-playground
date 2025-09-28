-- RisingWave Native CDC Demo
-- This script demonstrates native CDC connectors for PostgreSQL and MongoDB

-- ==============================================
-- PostgreSQL CDC Source
-- ==============================================

-- Create PostgreSQL CDC source
CREATE SOURCE IF NOT EXISTS postgres_cdc_source WITH (
    connector = 'postgres-cdc',
    hostname = 'postgres-cdc',
    port = '5432',
    username = 'postgres',
    password = '',
    database.name = 'cdc_demo'
);



-- ==============================================
-- PostgreSQL CDC Tables
-- ==============================================

-- Create PostgreSQL CDC table for users
CREATE TABLE IF NOT EXISTS postgres_users_cdc (
    id INT PRIMARY KEY,
    username VARCHAR,
    email VARCHAR,
    first_name VARCHAR,
    last_name VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) FROM postgres_cdc_source TABLE 'public.users';
CREATE MATERIALIZED VIEW IF NOT EXISTS postgres_users_changelog as  WITH c AS CHANGELOG FROM postgres_users_cdc SELECT * FROM c;

-- Create PostgreSQL CDC table for posts
CREATE TABLE IF NOT EXISTS postgres_posts_cdc (
    id INT PRIMARY KEY,
    user_id INT,
    title VARCHAR,
    content TEXT,
    status VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) FROM postgres_cdc_source TABLE 'public.posts';
CREATE MATERIALIZED VIEW IF NOT EXISTS postgres_posts_changelog as  WITH c AS CHANGELOG FROM postgres_posts_cdc SELECT * FROM c;

-- Create PostgreSQL CDC table for orders
CREATE TABLE IF NOT EXISTS postgres_orders_cdc (
    id INT PRIMARY KEY,
    user_id INT,
    product_name VARCHAR,
    quantity INT,
    price DECIMAL,
    status VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) FROM postgres_cdc_source TABLE 'public.orders';
CREATE MATERIALIZED VIEW IF NOT EXISTS postgres_orders_changelog as  WITH c AS CHANGELOG FROM postgres_orders_cdc SELECT * FROM c;


-- ==============================================
-- MongoDB CDC Tables
-- ==============================================

-- Create MongoDB CDC table for users
CREATE TABLE IF NOT EXISTS mongo_users_cdc (
    _id JSONB PRIMARY KEY,
    payload JSONB
) INCLUDE TIMESTAMP as commit_ts 
INCLUDE DATABASE_NAME as database_name 
INCLUDE COLLECTION_NAME as collection_name
WITH (
    connector = 'mongodb-cdc',
    mongodb.url = 'mongodb://mongodb-cdc:27017/cdc_demo?replicaSet=rs0',
    collection.name = 'cdc_demo.users'
);

CREATE MATERIALIZED VIEW IF NOT EXISTS mongo_users_changelog as  WITH c AS CHANGELOG FROM mongo_users_cdc SELECT * FROM c;

-- Create MongoDB CDC table for posts
CREATE TABLE  IF NOT EXISTS mongo_posts_cdc (
    _id JSONB PRIMARY KEY,
    payload JSONB
) INCLUDE TIMESTAMP as commit_ts 
INCLUDE DATABASE_NAME as database_name 
INCLUDE COLLECTION_NAME as collection_name
WITH (
    connector = 'mongodb-cdc',
    mongodb.url = 'mongodb://mongodb-cdc:27017/cdc_demo?replicaSet=rs0',
    collection.name = 'cdc_demo.posts'
);

CREATE MATERIALIZED VIEW IF NOT EXISTS mongo_posts_changelog as  WITH c AS CHANGELOG FROM mongo_posts_cdc SELECT * FROM c;

-- Create MongoDB CDC table for orders
CREATE TABLE IF NOT EXISTS mongo_orders_cdc (
    _id JSONB PRIMARY KEY,
    payload JSONB
) INCLUDE TIMESTAMP as commit_ts 
INCLUDE DATABASE_NAME as database_name 
INCLUDE COLLECTION_NAME as collection_name
WITH (
    connector = 'mongodb-cdc',
    mongodb.url = 'mongodb://mongodb-cdc:27017/cdc_demo?replicaSet=rs0',
    collection.name = 'cdc_demo.orders'
);

CREATE MATERIALIZED VIEW IF NOT EXISTS mongo_orders_changelog as  WITH c AS CHANGELOG FROM mongo_orders_cdc SELECT * FROM c;


-- ==============================================
-- Materialized Views for Processing CDC Data
-- ==============================================

-- PostgreSQL Users Analytics
CREATE MATERIALIZED VIEW IF NOT EXISTS postgres_users_analytics AS
SELECT
    id,
    username,
    email,
    first_name,
    last_name,
    created_at,
    updated_at
FROM postgres_users_cdc;

-- MongoDB Posts Analytics (extract fields from JSONB payload)
CREATE MATERIALIZED VIEW IF NOT EXISTS mongo_posts_analytics AS
SELECT
    (_id->>'$oid')::VARCHAR as document_id,
    payload->>'title' as title,
    payload->>'content' as content,
    payload->>'status' as status,
    payload->>'username' as username,
    commit_ts,
    database_name,
    collection_name
FROM mongo_posts_cdc
WHERE payload IS NOT NULL;
