# RisingWave Multi-Source Pipeline Management
# Reads from NATS JetStream and Kafka, writes to Iceberg

.PHONY: help up down restart deploy test check-pipeline clean logs status monitor deploy-cdc test-cdc test-postgres-cdc test-mongo-cdc check-cdc connect-rw

help:
	@echo "Available commands:"
	@echo "  make up                    - Start RisingWave services"
	@echo "  make down                  - Stop services"
	@echo "  make restart               - Restart services"
	@echo "  make deploy                - Deploy the multi-source pipeline"
	@echo "  make test                  - Run complete test (start + deploy + send events + check + stop)"
	@echo "  make check-pipeline        - Check pipeline status and data"
	@echo "  make clean                 - Clean up test data"
	@echo "  make deploy-cdc            - Deploy CDC demo pipeline"
	@echo "  make test-cdc              - Generate test CDC events"
	@echo "  make test-postgres-cdc     - Test PostgreSQL CDC only"
	@echo "  make test-mongo-cdc        - Test MongoDB CDC only"
	@echo "  make check-cdc             - Check CDC pipeline status and data"
	@echo "  make connect-rw            - Connect to RisingWave"

test: up  deploy check-pipeline down

up:
	docker compose up -d
	@sleep 5

down:
	docker compose down -v

restart:
	docker compose down -v
	docker compose up -d
	@sleep 10

deploy:
	@psql -h localhost -p 4566 -d dev -U root -f pipelines/datagen2nats.sql
	@psql -h localhost -p 4566 -d dev -U root -f pipelines/nats2kafka.sql

check-pipeline:
	@echo "📊 Streaming jobs:"
	@psql -h localhost -p 4566 -d dev -U root -c "SELECT name, status FROM rw_catalog.rw_streaming_jobs;" 2>/dev/null || echo "❌ Cannot connect to RisingWave"
	@echo ""
	@echo "📡 NATS messages (cloudevents subject):"
	@nats sub cloudevents --server localhost:4222 --count 5 2>/dev/null || echo "❌ No NATS messages found"
	@sleep 5
	@echo "📈 Kafka topics data:"
	@docker exec message_queue rpk topic consume cloudevents --num 5 --format json 2>/dev/null || echo "❌ No messages in cloudevents topic"

clean:
	@docker exec message_queue rpk topic delete cloudevents 2>/dev/null || true
	@nats stream rm cloudevents-stream --server localhost:4222 --force 2>/dev/null || true

logs:
	@docker compose logs --tail=20

status:
	@docker compose ps

monitor:
	@echo "📈 Monitoring endpoints:"
	@echo "  Grafana: http://localhost:3001 (admin/admin)"
	@echo "  Prometheus: http://localhost:9500"
	@echo "  MinIO Console: http://localhost:9400 (hummockadmin/hummockadmin)"
	@echo "  NATS: http://localhost:4222"
	@echo "  RisingWave UI: http://localhost:5691"
	@echo "  Redpanda Console: http://localhost:8081"
	@echo "  PostgreSQL CDC: localhost:5433"
	@echo "  MongoDB CDC: localhost:27017"

deploy-cdc:
	@echo "🚀 Deploying CDC demo pipeline..."
	@psql -h localhost -p 4566 -d dev -U root -f pipelines/cdc-demo.sql
	@echo "✅ CDC pipeline deployed!"

test-cdc: test-postgres-cdc test-mongo-cdc
	@echo "✅ All CDC test events generated!"

test-postgres-cdc:
	@echo "📝 Testing PostgreSQL CDC..."
	@echo "   Inserting new user..."
	@psql -h localhost -p 5433 -U postgres -d cdc_demo -c "INSERT INTO users (username, email, first_name, last_name) VALUES ('test_user_$$(date +%s)', 'test@example.com', 'Test', 'User');" || echo "❌ Failed to insert user"
	@echo "   Updating existing user..."
	@psql -h localhost -p 5433 -U postgres -d cdc_demo -c "UPDATE users SET email = 'updated_$$(date +%s)@example.com', updated_at = CURRENT_TIMESTAMP WHERE username = 'john_doe';" || echo "❌ Failed to update user"
	@echo "   Inserting new post..."
	@psql -h localhost -p 5433 -U postgres -d cdc_demo -c "INSERT INTO posts (user_id, title, content, status) VALUES (1, 'CDC Test Post $$(date +%s)', 'This is a test post for CDC', 'published');" || echo "❌ Failed to insert post"
	@echo "✅ PostgreSQL CDC tests completed!"

test-mongo-cdc:
	@echo "📝 Testing MongoDB CDC..."
	@echo "   Inserting new MongoDB user..."
	@mongosh mongodb://localhost:27017/cdc_demo --eval "db.users.insertOne({username: 'mongo_test_user_$$(date +%s)', email: 'mongo_test@example.com', firstName: 'Mongo', lastName: 'Test', createdAt: new Date(), updatedAt: new Date()});" || echo "❌ Failed to insert MongoDB user"
	@echo "   Updating existing MongoDB user..."
	@mongosh mongodb://localhost:27017/cdc_demo --eval "db.users.updateOne({username: 'john_doe'}, {\$$set: {email: 'mongo_updated_$$(date +%s)@example.com', updatedAt: new Date()}});" || echo "❌ Failed to update MongoDB user"
	@echo "   Inserting new MongoDB post..."
	@mongosh mongodb://localhost:27017/cdc_demo --eval "db.posts.insertOne({userId: db.users.findOne({username: 'john_doe'})._id, title: 'MongoDB CDC Test Post $$(date +%s)', content: 'This is a test post for MongoDB CDC', status: 'published', tags: ['cdc', 'test'], createdAt: new Date(), updatedAt: new Date()});" || echo "❌ Failed to insert MongoDB post"
	@echo "✅ MongoDB CDC tests completed!"

check-cdc:
	@echo "🔍 Checking CDC pipeline status..."
	@echo "📊 RisingWave CDC tables:"
	@psql -h localhost -p 4566 -d dev -U root -c "SELECT COUNT(*) as postgres_users FROM postgres_users_base;" 2>/dev/null || echo "❌ Cannot query postgres_users_base"
	@psql -h localhost -p 4566 -d dev -U root -c "SELECT COUNT(*) as mongo_users FROM mongo_users_base;" 2>/dev/null || echo "❌ Cannot query mongo_users_base"
	@echo ""
	@echo "📈 CDC Analytics:"
	@psql -h localhost -p 4566 -d dev -U root -c "SELECT * FROM scd1_analytics;" 2>/dev/null || echo "❌ Cannot query scd1_analytics"
	@echo ""
	@echo "📋 Useful RisingWave queries:"
	@echo "   psql -h localhost -p 4566 -d dev -U root"
	@echo "   SELECT COUNT(*) FROM postgres_users_base;"
	@echo "   SELECT COUNT(*) FROM mongo_users_base;"
	@echo "   SELECT * FROM scd2_analytics;"
	@echo "   SELECT * FROM change_frequency_analytics;"

connect-rw:
	@echo "🔗 Connecting to RisingWave..."
	@psql -h localhost -p 4566 -d dev -U root
