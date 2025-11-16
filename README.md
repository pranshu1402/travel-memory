# Travel Memory

A MERN stack application for managing and storing travel experiences, built with Infrastructure as Code (IaC) using Terraform and Ansible, with comprehensive monitoring using Prometheus and Grafana.

## Table of Contents

- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Infrastructure Setup (Terraform)](#infrastructure-setup-terraform)
- [Application Deployment (Ansible)](#application-deployment-ansible)
- [Monitoring Setup](#monitoring-setup)
- [Manual Deployment (Without IaC)](#manual-deployment-without-iac)
- [Configuration](#configuration)
- [API Documentation](#api-documentation)
- [Screenshots](#screenshots)

## Architecture

### Infrastructure Components

- **Web Server (EC2)**: Hosts Node.js backend, React frontend, Nginx, Prometheus, and Grafana
- **Database Server (EC2)**: MongoDB instance with MongoDB Exporter for metrics
- **Networking**: Default VPC with public subnets, security groups configured
- **Monitoring**: Prometheus for metrics collection, Grafana for visualization
- **Security**: IAM roles for CloudWatch monitoring, SSH key-based access, UFW firewall

### Application Stack

- **Frontend**: React.js with React Router
- **Backend**: Node.js with Express.js
- **Database**: MongoDB 7.0
- **Process Manager**: PM2
- **Web Server**: Nginx
- **Monitoring**: Prometheus + Grafana + prom-client

## Prerequisites

### Local Setup
- **AWS CLI** configured with credentials
- **Terraform** (v1.0+)
- **Ansible** (v2.9+)
- **SSH Key Pair** for EC2 access

### AWS Resources
- AWS Account with appropriate permissions
- Default VPC in your region
- EC2 key pair created in AWS Console

## Infrastructure Setup (Terraform)

### Step 1: Configure Terraform Variables

Update `infra/terraform/terraform.tfvars`:

```hcl
instance_type = "t2.micro"
key_name      = "your-key-pair-name"
aws_region    = "us-west-2"
```

### Step 2: Initialize Terraform

```bash
cd infra/terraform
terraform init
```

### Step 3: Review Infrastructure Plan

```bash
terraform plan
```

### Step 4: Provision Infrastructure

```bash
terraform apply
```

### Step 5: Get Output Values

```bash
terraform output
```

Save the output values (public IPs, private IPs) for Ansible configuration.

### Terraform Modules

- **VPC Module**: Default VPC configuration, Internet Gateway, Route Tables
- **EC2 Module**: Web server and database server instances with security groups
- **IAM Module**: IAM roles and instance profiles for CloudWatch monitoring

### Infrastructure Outputs

- Web Server Public/Private IP
- Database Server Public/Private IP
- Security Group IDs
- IAM Role ARNs

## Application Deployment (Ansible)

### Step 1: Update Ansible Configuration

Update `infra/ansible/ansible.cfg`:

```ini
private_key_file = ~/.ssh/your-key.pem
```

### Step 2: Update Inventory

Update `infra/ansible/inventory.yml` with Terraform outputs:

```yaml
web_server:
  ansible_host: "WEB_SERVER_PUBLIC_IP"  # From terraform output
  
db_server:
  ansible_host: "DB_SERVER_PUBLIC_IP"   # From terraform output
```

### Step 3: Update Variables (Optional)

Update `infra/ansible/group_vars/all.yml` or use extra-vars:

```bash
# Get private IPs from Terraform
terraform output db_server_private_ip
terraform output web_server_private_ip
```

### Step 4: Run Complete Deployment

```bash
cd infra/ansible
ansible-playbook -i inventory.yml site.yml \
  --extra-vars "mongo_uri=mongodb://DB_SERVER_PRIVATE_IP:27017/travelmemory \
                web_server_private_ip=WEB_SERVER_PRIVATE_IP \
                db_server_private_ip=DB_SERVER_PRIVATE_IP \
                mongo_db_password=SecurePassword123!"
```

### Ansible Playbooks

1. **security-hardening.yml**: SSH hardening, firewall rules
2. **db-server.yml**: MongoDB installation and configuration
3. **web-server.yml**: Node.js, React, Nginx, PM2 setup
4. **monitoring/site.yml**: Prometheus, Grafana, MongoDB Exporter

### Individual Playbook Execution

**Security Hardening:**
```bash
ansible-playbook -i inventory.yml security-hardening.yml
```

**Database Server:**
```bash
ansible-playbook -i inventory.yml db-server.yml \
  --extra-vars "db_server_ip=DB_SERVER_IP mongo_db_password=password"
```

**Web Server:**
```bash
ansible-playbook -i inventory.yml web-server.yml \
  --extra-vars "web_server_ip=WEB_SERVER_IP \
                mongo_uri=mongodb://DB_SERVER_PRIVATE_IP:27017/travelmemory"
```

## Monitoring Setup

### Access URLs

After deployment, access monitoring services:

- **Prometheus**: `http://WEB_SERVER_PUBLIC_IP:9090`
- **Grafana**: `http://WEB_SERVER_PUBLIC_IP:3000`
  - Default credentials: `admin/admin` (change immediately!)
- **Backend Metrics**: `http://WEB_SERVER_PUBLIC_IP:3001/metrics`
- **MongoDB Exporter**: `http://DB_SERVER_PRIVATE_IP:9216/metrics`

### Metrics Collected

**Backend (Node.js):**
- Request rate (requests/second)
- API latency (95th percentile)
- Error rate
- Total request count
- Default Node.js metrics (CPU, memory, event loop)

**MongoDB:**
- Connection metrics
- Operation counters
- Memory usage
- Network I/O
- Query performance

### Pre-configured Dashboards

- **Node.js Backend Metrics**: API latency, error rate, request count
- **MongoDB Performance Metrics**: Connections, operations, memory, network I/O

### Alert Rules

Configured alerts for:
- High error rates (> 0.05 errors/sec)
- Slow API responses (> 2s latency)
- MongoDB connection issues (> 80% usage)
- Service downtime

### Setup Monitoring (if not included in site.yml)

```bash
cd infra/ansible
ansible-playbook -i inventory.yml monitoring/site.yml
ansible-playbook -i inventory.yml monitoring/firewall-rules.yml
ansible-playbook -i inventory.yml monitoring/update-prometheus-config.yml
ansible-playbook -i inventory.yml monitoring/setup-dashboards.yml
```

For detailed monitoring setup, see `infra/ansible/monitoring/README.md`.

## Manual Deployment (Without IaC)

For manual deployment steps without Infrastructure as Code, refer to:

- `infra/deployment_with_no_iaac/complete_step_to_deploy.txt`
- Legacy deployment guide with step-by-step instructions

## Configuration

### Backend Environment Variables

Create `backend/.env`:

```env
MONGO_URI=mongodb://DB_SERVER_PRIVATE_IP:27017/travelmemory
PORT=3001
```

Or for MongoDB Atlas:

```env
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/travelmemory
PORT=3001
```

### Frontend Environment Variables

Create `frontend/.env`:

```env
REACT_APP_BACKEND_URL=http://WEB_SERVER_PUBLIC_IP:3001
```

Or for production with domain:

```env
REACT_APP_BACKEND_URL=https://yourdomain.com/api
```

### Security Groups

**Web Server:**
- Port 22 (SSH)
- Port 80 (HTTP)
- Port 443 (HTTPS)
- Port 3000 (Grafana)
- Port 9090 (Prometheus)

**Database Server:**
- Port 22 (SSH)
- Port 27017 (MongoDB) - Only from web server security group
- Port 9216 (MongoDB Exporter) - Only from web server security group

## API Documentation

### Base URL

```
http://WEB_SERVER_PUBLIC_IP:3001
```

### Endpoints

#### Health Check
```http
GET /hello
```
**Response:** `Hello World!`

#### Get All Trips
```http
GET /trip
```
**Response:** Array of trip objects

#### Get Trip by ID
```http
GET /trip/:id
```
**Response:** Single trip object

#### Create Trip
```http
POST /trip
Content-Type: application/json
```

**Request Body:**
```json
{
  "tripName": "Incredible India",
  "startDateOfJourney": "19-03-2022",
  "endDateOfJourney": "27-03-2022",
  "nameOfHotels": "Hotel Namaste, Backpackers Club",
  "placesVisited": "Delhi, Kolkata, Chennai, Mumbai",
  "totalCost": 800000,
  "tripType": "leisure",
  "experience": "Lorem Ipsum...",
  "image": "https://example.com/image.jpg",
  "shortDescription": "India is a wonderful country...",
  "featured": true
}
```

**Response:** `Trip added Successfully`

#### Metrics Endpoint
```http
GET /metrics
```
**Response:** Prometheus metrics in Prometheus format

## Post-Deployment Verification

### Backend Health Check
```bash
curl http://WEB_SERVER_PUBLIC_IP:3001/hello
```

### Frontend Check
```bash
curl http://WEB_SERVER_PUBLIC_IP
```

### Nginx Status
```bash
ssh ubuntu@WEB_SERVER_PUBLIC_IP "sudo systemctl status nginx"
```

### PM2 Status
```bash
ssh ubuntu@WEB_SERVER_PUBLIC_IP "pm2 list"
ssh ubuntu@WEB_SERVER_PUBLIC_IP "pm2 logs backend-app"
```

### MongoDB Status
```bash
ssh ubuntu@DB_SERVER_PUBLIC_IP "sudo systemctl status mongod"
```

### Prometheus Targets
```bash
# Open in browser: http://WEB_SERVER_PUBLIC_IP:9090/targets
```

### Grafana Dashboards
```bash
# Open in browser: http://WEB_SERVER_PUBLIC_IP:3000
```

## Troubleshooting

### SSH Connection Issues
- Verify SSH key permissions: `chmod 400 ~/.ssh/your-key.pem`
- Check security groups - port 22 should be open
- Test SSH manually: `ssh -i ~/.ssh/your-key.pem ubuntu@PUBLIC_IP`

### Backend Not Starting
- Check PM2 logs: `pm2 logs backend-app`
- Verify .env file: `cat /home/ubuntu/TravelMemory/backend/.env`
- Check MongoDB connection: `curl http://localhost:3001/hello`
- Verify backend dependencies: `cd backend && npm list`

### Frontend Build Issues
- Check Node.js version: `node --version` (should be 18+)
- Verify dependencies: `cd frontend && npm install`
- Check .env file: `cat /home/ubuntu/TravelMemory/frontend/.env`
- Review build errors in Ansible output

### MongoDB Connection Issues
- Verify MongoDB running: `sudo systemctl status mongod`
- Check firewall rules: `sudo ufw status verbose`
- Test from web server: `telnet DB_SERVER_PRIVATE_IP 27017`
- Verify MongoDB user: `mongosh travelmemory -u traveluser -p`

### Monitoring Issues
- Check Prometheus targets: http://WEB_SERVER_IP:9090/targets
- Verify backend metrics: `curl http://WEB_SERVER_IP:3001/metrics`
- Check Prometheus logs: `sudo journalctl -u prometheus -f`
- Verify Grafana datasource configuration in UI

## Project Structure

```
TravelMemory/
├── backend/                 # Node.js backend application
│   ├── controllers/        # Route controllers
│   ├── models/             # MongoDB models
│   ├── routes/             # Express routes
│   ├── middleware/         # Express middleware (Prometheus metrics)
│   ├── index.js            # Main server file
│   └── package.json        # Backend dependencies
├── frontend/               # React frontend application
│   ├── src/               # Source files
│   ├── public/            # Static files
│   └── package.json       # Frontend dependencies
├── infra/                 # Infrastructure as Code
│   ├── terraform/         # Terraform configurations
│   │   ├── modules/       # Terraform modules (VPC, EC2, IAM)
│   │   ├── main.tf        # Main Terraform configuration
│   │   └── outputs.tf     # Terraform outputs
│   ├── ansible/           # Ansible playbooks
│   │   ├── monitoring/    # Monitoring setup playbooks
│   │   ├── site.yml       # Main Ansible playbook
│   │   ├── web-server.yml # Web server setup
│   │   └── db-server.yml  # Database server setup
│   └── monitoring/        # Monitoring configurations
│       ├── grafana-dashboards/  # Grafana dashboard JSON files
│       └── prometheus-rules/    # Prometheus alert rules
└── README.md              # This file
```

## Screenshots

Refer to `./screenshots` folder for deployment screenshots and monitoring dashboards.

## Additional Resources

- **Terraform Documentation**: See `infra/terraform/` directory
- **Ansible Documentation**: See `infra/ansible/README.md`
- **Monitoring Documentation**: See `infra/ansible/monitoring/README.md`
- **Manual Deployment**: See `infra/deployment_with_no_iaac/complete_step_to_deploy.txt`

