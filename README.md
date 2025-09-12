# RisingWave Multi-Source Streaming Pipeline

This directory contains a comprehensive RisingWave streaming analytics setup with a multi-source pipeline that processes CloudEvents data through NATS JetStream and Kafka (Redpanda).

## 🚀 Quick Start

1. **Start all services:**
   ```bash
   make up
   ```

2. **Deploy the complete pipeline:**
   ```bash
   make deploy
   ```
3. **Check the pipeline:**
    ```bash
    make check-pipeline
    ```
4. **Run the full test cycle:**
   ```bash
   make test
   ```

## 🛠️ Available Commands

```bash
make help          # Show all available commands
make up            # Start all services
make down          # Stop and clean up services
make restart       # Restart all services
make deploy        # Deploy the complete pipeline
make test          # Run full test cycle (start + deploy + check + stop)
make check-pipeline # Check pipeline status and data flow
make clean         # Clean up test data
make logs          # View service logs
make status        # Check service status
make monitor       # Show monitoring endpoints
```

## 📁 File Structure

### Pipeline SQL Files
- **`datagen2nats.sql`**: Creates CloudEvents generator, analytics view, and NATS sink
- **`nats2kafka.sql`**: Creates NATS JetStream source connector and Kafka sink

### Configuration Files
- **`docker-compose.yml`**: Complete service orchestration
- **`Makefile`**: Pipeline management commands
- **`risingwave.toml`**: RisingWave configuration
- **`prometheus.yaml`**: Prometheus monitoring configuration

### Monitoring & Dashboards
- **`grafana.ini`**: Grafana configuration
- **`grafana-risedev-datasource.yml`**: Prometheus data source setup
- **`grafana-risedev-dashboard.yml`**: Dashboard provisioning
- **`dashboards/`**: Custom Grafana dashboards
  - `risingwave-dev-dashboard.json`
  - `risingwave-user-dashboard.json`

## 🔍 Pipeline Details

### CloudEvents Data Structure
```sql
CREATE SOURCE cloudevents_generator (
    specversion VARCHAR,      -- CloudEvents spec version
    id VARCHAR,               -- Unique event ID
    time TIMESTAMP,           -- Event timestamp
    type VARCHAR,             -- Event type
    source VARCHAR,           -- Event source
    userAgentHeader VARCHAR,  -- User agent information
    actorType VARCHAR,        -- Actor type
    actorId VARCHAR,          -- Actor identifier
    actorRole VARCHAR,        -- Actor role
    eventSpecificData VARCHAR -- Event-specific payload
)
```

### Data Generation
- **Rate**: 10 CloudEvents per second
- **Format**: JSON with realistic event data
- **Distribution**: Random data with seeded randomness for reproducibility

### Streaming Jobs
1. **CloudEvents Analytics**: Basic event counting
2. **NATS Sink**: Sends events to NATS JetStream
3. **Kafka Sink**: Forwards events from NATS to Kafka

## 🌐 Service Endpoints

| Service | Port | URL | Credentials |
|---------|------|-----|-------------|
| RisingWave | 4566 | `psql -h localhost -p 4566 -d dev -U root` | No password |
| RisingWave UI| 5691 |  http://localhost:5691 | no password |
| Grafana | 3001 | http://localhost:3001 | admin/admin |
| Prometheus | 9500 | http://localhost:9500 | - |
| MinIO Console | 9400 | http://localhost:9400 | hummockadmin/hummockadmin |
| NATS Server | 4222 | localhost:4222 | - |
| NATS Monitor | 8222 | http://localhost:8222 | - |
| Redpanda Console | 8081 | http://localhost:8081 | - |
| Kafka | 9092 | localhost:9092 | - |

## 📈 Monitoring & Observability

### Grafana Dashboards
- **RisingWave Development Dashboard**: Comprehensive metrics and performance monitoring
- **RisingWave User Dashboard**: User-focused analytics and insights

### Prometheus Metrics
- RisingWave standalone metrics
- Redpanda/Kafka metrics
- MinIO storage metrics
- System performance metrics

## 🔧 Configuration

### Memory Allocation
- **RisingWave Container**: 8GB total memory
- **Compute Node**: 2.5GB (2.4GB target)
- **Frontend**: 512MB
- **Compactor**: 1GB
- **Redpanda**: 1GB

### Parallelism
- **RisingWave**: 4 parallel workers
- **Optimized for**: Docker Desktop environments

## 🎯 Key Features

1. **Multi-Source Pipeline**: NATS → RisingWave → Kafka
2. **CloudEvents Processing**: Standard event format with realistic data
3. **Real-time Analytics**: Streaming aggregations and transformations
4. **Message Persistence**: NATS JetStream with stream retention
5. **Monitoring Stack**: Complete observability with Grafana and Prometheus
6. **Automated Testing**: One-command test cycle with validation




## 🚨 Troubleshooting

### Common Issues

**Memory Issues**
- Reduce memory allocation in `docker-compose.yml` if running on limited resources
- Monitor memory usage in Grafana dashboard

**Port Conflicts**
- Check if ports 4566, 3001, 9500, 4222, 9092 are available
- Modify port mappings in `docker-compose.yml` if needed

**Pipeline Not Working**
- Run `make check-pipeline` to diagnose issues
- Check service logs with `make logs`
- Verify all services are healthy with `make status`

### Cleanup
```bash
# Complete cleanup
make down
make clean

# Remove all data volumes
docker compose down -v
```


## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Third-Party Licenses

This project incorporates code and configurations derived from RisingWave (Apache License 2.0) and other open-source components. See the [NOTICE](NOTICE) file for complete attribution details.

---

*This setup demonstrates a production-ready streaming pipeline with RisingWave, NATS JetStream, and Kafka integration for real-time event processing.*
