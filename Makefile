# RisingWave Multi-Source Pipeline Management
# Reads from NATS JetStream and Kafka, writes to Iceberg

.PHONY: help up down restart deploy test check-pipeline clean logs status monitor

help:
	@echo "Available commands:"
	@echo "  make up                    - Start RisingWave services"
	@echo "  make down                  - Stop services"
	@echo "  make restart               - Restart services"
	@echo "  make deploy                - Deploy the multi-source pipeline"
	@echo "  make test                  - Run complete test (start + deploy + send events + check + stop)"
	@echo "  make check-pipeline        - Check pipeline status and data"
	@echo "  make clean                 - Clean up test data"

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
	@psql -h localhost -p 4566 -d dev -U root -f pipelines/nats_source.sql
	@psql -h localhost -p 4566 -d dev -U root -f pipelines/kafka_sink.sql

check-pipeline:
	@echo "📊 Streaming jobs:"
	@psql -h localhost -p 4566 -d dev -U root -c "SELECT name, status FROM rw_catalog.rw_streaming_jobs;" 2>/dev/null || echo "❌ Cannot connect to RisingWave"
	@echo ""
	@echo "📡 NATS messages (cloudevents subject):"
	@nats sub cloudevents --server localhost:4222 --count 5 2>/dev/null || echo "❌ No NATS messages found"
	@echo "📈 Kafka topics data:"
	@docker exec message_queue rpk topic consume cloudevents --num 10 --format json 2>/dev/null || echo "❌ No messages in cloudevents topic"

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
	@echo "  NATS: localhost:4222"
	@echo "  RisingWave: localhost:4566"
	@echo "  Redpanda Console: http://localhost:8081"
