# Monitoring Infrastructure Setup

This directory contains Ansible playbooks for setting up Prometheus, Grafana, and MongoDB Exporter for monitoring the TravelMemory application.

## Overview

The monitoring stack consists of:
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **MongoDB Exporter**: MongoDB metrics collection
- **Node.js Backend Metrics**: Custom metrics exposed via prom-client

## Structure

```
monitoring/
├── site.yml                      # Main monitoring playbook
├── prometheus.yml               # Prometheus installation
├── mongodb-exporter.yml         # MongoDB Exporter installation
├── grafana.yml                  # Grafana installation
├── firewall-rules.yml           # Firewall rules for monitoring ports
├── update-prometheus-config.yml # Prometheus alert rules setup
├── setup-dashboards.yml         # Grafana dashboards setup
└── README.md                    # This file
```

## Metrics Exposed

### Node.js Backend (via `/metrics` endpoint)
- `http_request_duration_seconds`: Request latency (histogram)
- `http_requests_total`: Total request count (counter)
- `http_errors_total`: Error count (counter)
- Default Node.js metrics (CPU, memory, event loop, etc.)

### MongoDB (via MongoDB Exporter)
- Connection metrics
- Operation counters
- Memory usage
- Network I/O
- Query performance

## Prerequisites

- Ansible installed
- Web server and database server provisioned via Terraform
- SSH access to servers
- Backend application deployed (for metrics endpoint)

## Usage

### Complete Monitoring Setup

```bash
cd infra/ansible
ansible-playbook -i inventory.yml monitoring/site.yml \
  --extra-vars "db_server_ip=5.6.7.8 \
                web_server_ip=1.2.3.4 \
                db_server_private_ip=10.0.1.5 \
                mongo_db_user=traveluser \
                mongo_db_password=traveluser"
```

### Individual Components

**Prometheus only:**
```bash
ansible-playbook -i inventory.yml monitoring/prometheus.yml \
  --extra-vars "web_server_ip=1.2.3.4"
```

**MongoDB Exporter only:**
```bash
ansible-playbook -i inventory.yml monitoring/mongodb-exporter.yml \
  --extra-vars "db_server_ip=5.6.7.8 \
                mongo_db_user=traveluser \
                mongo_db_password=traveluser"
```

**Grafana only:**
```bash
ansible-playbook -i inventory.yml monitoring/grafana.yml \
  --extra-vars "web_server_ip=1.2.3.4 \
                grafana_admin_password=SecurePassword123!"
```

**Update Prometheus alerts:**
```bash
ansible-playbook -i inventory.yml monitoring/update-prometheus-config.yml \
  --extra-vars "web_server_ip=1.2.3.4"
```

**Setup Grafana dashboards:**
```bash
ansible-playbook -i inventory.yml monitoring/setup-dashboards.yml \
  --extra-vars "web_server_ip=1.2.3.4 \
                grafana_admin_password=SecurePassword123!"
```

## Access URLs

After setup, access monitoring services at:

- **Prometheus**: `http://WEB_SERVER_PUBLIC_IP:9090`
- **Grafana**: `http://WEB_SERVER_PUBLIC_IP:3000`
  - Default credentials: `admin/admin` (change in production!)
- **Backend Metrics**: `http://WEB_SERVER_PUBLIC_IP:3001/metrics`
- **MongoDB Exporter**: `http://DB_SERVER_PRIVATE_IP:9216/metrics`

## Dashboards

Pre-configured dashboards:
- **Node.js Backend Metrics**: API latency, error rate, request count
- **MongoDB Performance Metrics**: Connections, operations, memory, network I/O

Dashboards are automatically provisioned in Grafana.

## Alert Rules

Configured alert rules:

### Backend Alerts
- **HighErrorRate**: Triggered when error rate > 0.05 errors/sec for 5 minutes
- **SlowAPIResponse**: Triggered when 95th percentile latency > 2s for 5 minutes
- **HighRequestRate**: Info alert when request rate > 100 req/sec

### MongoDB Alerts
- **MongoDBHighConnections**: Triggered when connection usage > 80% for 5 minutes
- **MongoDBSlowOperations**: Triggered when command operations > 1000 ops/sec
- **MongoDBHighMemoryUsage**: Triggered when resident memory > 2GB for 10 minutes

### Infrastructure Alerts
- **PrometheusTargetDown**: Triggered when a Prometheus target is down for 5 minutes

## Ports

Firewall rules automatically configured:
- **9090**: Prometheus (web server)
- **3000**: Grafana (web server)
- **9216**: MongoDB Exporter (database server, accessible from web server only)
- **3001**: Backend metrics endpoint (web server)

## Troubleshooting

### Prometheus not scraping metrics
1. Check if backend is running: `curl http://localhost:3001/metrics`
2. Verify Prometheus targets: `http://WEB_SERVER_IP:9090/targets`
3. Check Prometheus logs: `sudo journalctl -u prometheus -f`

### MongoDB Exporter not working
1. Verify MongoDB is running: `sudo systemctl status mongod`
2. Check exporter logs: `sudo journalctl -u mongodb_exporter -f`
3. Test exporter endpoint: `curl http://localhost:9216/metrics`
4. Verify MongoDB credentials in exporter service file

### Grafana dashboards not loading
1. Verify Prometheus datasource is configured correctly
2. Check Grafana logs: `sudo journalctl -u grafana-server -f`
3. Verify dashboard JSON files are in `/var/lib/grafana/dashboards`
4. Check Grafana provisioning status in UI

### Backend metrics not appearing
1. Verify prom-client is installed: `npm list prom-client`
2. Check backend logs for errors
3. Test metrics endpoint: `curl http://localhost:3001/metrics`
4. Verify middleware is applied in `backend/index.js`

## Configuration Files

- Prometheus config: `/etc/prometheus/prometheus.yml`
- Prometheus alert rules: `/etc/prometheus/rules/alerts.yml`
- Grafana datasources: `/etc/grafana/provisioning/datasources/prometheus.yml`
- Grafana dashboards: `/var/lib/grafana/dashboards/`

## Next Steps

1. Change Grafana admin password after first login
2. Configure alert notification channels (email, Slack, etc.)
3. Customize dashboard panels for your needs
4. Adjust alert thresholds based on your baseline metrics
5. Set up Grafana users and permissions for team access

