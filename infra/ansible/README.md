# Ansible Configuration for TravelMemory Infrastructure

These Ansible playbooks are used to deploy and configure the TravelMemory MERN application.

## Structure

```
infra/ansible/
├── ansible.cfg          # Ansible configuration
├── inventory.yml        # Inventory file with server definitions
├── site.yml            # Main playbook - orchestrates everything
├── web-server.yml      # Web server setup (Node.js, React, Nginx, PM2)
├── db-server.yml       # MongoDB database server setup
├── security-hardening.yml  # SSH hardening and firewall configuration
└── README.md           # Documentation
```

## Prerequisites

1. **Ansible installed** (version 2.9+)
   ```bash
   pip install ansible
   # or
   brew install ansible  # macOS
   ```

2. **Terraform outputs** - Public IPs after EC2 instances are provisioned
   ```bash
   cd infra/terraform
   terraform output
   ```

3. **SSH Key Pair** - Private key must be available for EC2 instances

## Configuration Steps

### 1. Update ansible.cfg

Update your SSH key path in `ansible.cfg`:
```ini
private_key_file = ~/.ssh/your-key.pem
```

### 2. Update inventory.yml

Get public IPs from Terraform outputs and update `inventory.yml`:

**Option A: Direct IPs**
```yaml
web_server:
  ansible_host: "1.2.3.4"  # Web server public IP from Terraform output
  
db_server:
  ansible_host: "5.6.7.8"  # DB server public IP from Terraform output
```

**Option B: With Variables**
```bash
ansible-playbook -i inventory.yml site.yml \
  --extra-vars "web_server_ip=1.2.3.4 db_server_ip=5.6.7.8"
```

### 3. Update Variables

**Web Server Playbook (web-server.yml):**
- `mongo_uri`: Database server connection string
  - Format: `mongodb://DB_SERVER_PRIVATE_IP:27017/travelmemory`
  - Or MongoDB Atlas URI if using cloud MongoDB
- `frontend_backend_url`: Backend URL for frontend
  - Format: `http://WEB_SERVER_PUBLIC_IP:3001`

**Database Server Playbook (db-server.yml):**
- `mongo_db_password`: MongoDB database user password (default: `ChangeMe123!`)
- `web_server_private_ip`: Web server private IP (for firewall rules)

## Usage

### Complete Setup (Everything Together)

```bash
cd infra/ansible
ansible-playbook -i inventory.yml site.yml \
  --extra-vars "web_server_ip=1.2.3.4 db_server_ip=5.6.7.8 \
                mongo_uri=mongodb://10.0.1.5:27017/travelmemory \
                web_server_private_ip=10.0.1.4"
```

### Individual Playbooks

**Security Hardening:**
```bash
ansible-playbook -i inventory.yml security-hardening.yml \
  --extra-vars "web_server_ip=1.2.3.4 db_server_ip=5.6.7.8"
```

**Database Server Setup:**
```bash
ansible-playbook -i inventory.yml db-server.yml \
  --extra-vars "db_server_ip=5.6.7.8 web_server_private_ip=10.0.1.4 \
                mongo_db_password=SecurePassword123!"
```

**Web Server Setup:**
```bash
ansible-playbook -i inventory.yml web-server.yml \
  --extra-vars "web_server_ip=1.2.3.4 \
                mongo_uri=mongodb://10.0.1.5:27017/travelmemory \
                frontend_backend_url=http://1.2.3.4:3001"
```

## What Each Playbook Does

### 1. security-hardening.yml
- SSH root login disable
- Password authentication disable (SSH keys only)
- UFW firewall enable
- HTTP/HTTPS ports allow (for web servers)
- Automatic security updates enable

### 2. db-server.yml
- MongoDB 7.0 installation
- MongoDB configured for remote access
- Database and user created
- UFW firewall rules - MongoDB port only allowed from web server

### 3. web-server.yml
- Node.js v18 and NPM installation
- Nginx installation
- PM2 installation (process manager)
- TravelMemory repository clone
- Backend setup:
  - Dependencies install
  - .env file create
  - PM2 ecosystem config
  - Backend start with PM2
- Frontend setup:
  - Dependencies install
  - .env file create
  - Production build
  - Deploy to Nginx directory
- Nginx configuration:
  - API proxy (/api/* → backend:3001)
  - React app serving (SPA routing support)

## Post-Deployment Verification

### Web Server
```bash
# Backend health check
curl http://WEB_SERVER_PUBLIC_IP:3001/hello

# Frontend check
curl http://WEB_SERVER_PUBLIC_IP

# Nginx status
ssh ubuntu@WEB_SERVER_PUBLIC_IP "sudo systemctl status nginx"

# PM2 status
ssh ubuntu@WEB_SERVER_PUBLIC_IP "pm2 list"
```

### Database Server
```bash
# MongoDB status
ssh ubuntu@DB_SERVER_PUBLIC_IP "sudo systemctl status mongod"

# MongoDB connection test
ssh ubuntu@DB_SERVER_PUBLIC_IP "mongosh travelmemory -u traveluser -p"
```

## Troubleshooting

### SSH Connection Issues
- Verify SSH key permissions: `chmod 400 ~/.ssh/your-key.pem`
- Check security groups - port 22 should be open
- Test SSH manually: `ssh -i ~/.ssh/your-key.pem ubuntu@PUBLIC_IP`

### MongoDB Connection Issues
- Verify MongoDB running: `sudo systemctl status mongod`
- Check firewall rules: `sudo ufw status verbose`
- Test from web server: `telnet DB_SERVER_PRIVATE_IP 27017`

### Backend Not Starting
- Check PM2 logs: `pm2 logs backend-app`
- Verify .env file: `cat /home/ubuntu/TravelMemory/backend/.env`
- Check MongoDB connection: `curl http://localhost:3001/hello`

### Frontend Build Issues
- Check Node.js version: `node --version` (should be 18+)
- Verify dependencies: `cd frontend && npm install`
- Check .env file: `cat /home/ubuntu/TravelMemory/frontend/.env`

## Notes

- Default MongoDB password is `ChangeMe123!` - must change in production
- PM2 process manager sets up automatic restart and startup script
- Nginx is configured for React app with SPA routing support
- Security hardening makes SSH keys mandatory - password authentication disabled

