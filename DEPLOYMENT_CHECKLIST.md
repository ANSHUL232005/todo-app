# Production Deployment Checklist

Complete this checklist before deploying your TODO application to production.

## Pre-Deployment Security

- [ ] **Generate Strong SECRET_KEY**
  ```bash
  openssl rand -base64 32
  ```
  - Store securely in `.env.production.secure`
  - Never commit to version control

- [ ] **Update CORS_ORIGINS**
  - [ ] Replace placeholder with your actual domain
  - [ ] Format: `https://yourdomain.com,https://www.yourdomain.com`
  - [ ] Test CORS restrictions are working

- [ ] **Set Strong PostgreSQL Password**
  - [ ] Generate random password (min 16 chars)
  - [ ] Include uppercase, lowercase, numbers, symbols
  - [ ] Do NOT use default passwords

- [ ] **Configure Database User Permissions**
  - [ ] Create separate user for app (avoid using admin)
  - [ ] Grant minimal required permissions
  - [ ] Enable connection encryption

- [ ] **Review Backend Code**
  - [ ] Verify DEBUG=false in production
  - [ ] Check no hardcoded secrets remain
  - [ ] Review API rate limiting settings
  - [ ] Ensure error messages don't leak sensitive info

- [ ] **Configure Frontend**
  - [ ] Update API_DOMAIN in environment variables
  - [ ] Test API calls from production domain
  - [ ] Verify HTTPS redirect works
  - [ ] Test CORS headers are correct

## Infrastructure Setup

- [ ] **Azure Account**
  - [ ] Create Azure subscription
  - [ ] Enable billing alerts
  - [ ] Set budget limits
  - [ ] Enable cost analysis

- [ ] **Create Azure Resources**
  - [ ] Run `azure-deploy.bat` or `azure-deploy.sh`
  - [ ] Create Resource Group
  - [ ] Create Azure Container Registry
  - [ ] Create PostgreSQL Database
  - [ ] Create App Service Plan (B2 or higher)
  - [ ] Create Web App

- [ ] **Domain Registration**
  - [ ] Purchase domain (Namecheap, GoDaddy, etc.)
  - [ ] Update DNS nameservers (if required)
  - [ ] Note: DNS propagation can take 24-48 hours

- [ ] **SSL/TLS Certificate**
  - [ ] Obtain Let's Encrypt certificate
  - [ ] Verify certificate validity
  - [ ] Configure auto-renewal (90-day expiration)
  - [ ] Test HTTPS access

## Docker Image Preparation

- [ ] **Build Production Images**
  ```bash
  # Backend
  docker build -t <registry>/todo-backend:latest ./backend -f Dockerfile.prod
  
  # Frontend
  docker build -t <registry>/todo-frontend:latest ./frontend -f Dockerfile.prod
  ```

- [ ] **Test Images Locally**
  ```bash
  docker run -p 8000:8000 <registry>/todo-backend:latest
  docker run -p 3000:3000 <registry>/todo-frontend:latest
  ```
  - [ ] Backend health check responds
  - [ ] Frontend loads without errors
  - [ ] API endpoints respond correctly

- [ ] **Push to Azure Container Registry**
  ```bash
  az acr login --name <registry-name>
  docker push <registry>/todo-backend:latest
  docker push <registry>/todo-frontend:latest
  ```

- [ ] **Verify Images in Registry**
  ```bash
  az acr repository list --name <registry-name>
  ```

## Database Migration

- [ ] **Migrate from SQLite to PostgreSQL**
  - [ ] Export data from SQLite (if needed)
  - [ ] Import to PostgreSQL
  - [ ] Verify data integrity
  - [ ] Test application with PostgreSQL

- [ ] **Database Backup Strategy**
  - [ ] Enable automated backups in Azure
  - [ ] Configure backup retention (minimum 7 days)
  - [ ] Test backup restoration
  - [ ] Document backup procedures

- [ ] **Database Security**
  - [ ] Enable SSL/TLS for connections
  - [ ] Configure firewall rules if needed
  - [ ] Enable audit logging
  - [ ] Set up connection monitoring

## Application Configuration

- [ ] **Environment Variables**
  - [ ] All critical variables set
  - [ ] No secrets in Docker images
  - [ ] Use Azure Key Vault for sensitive data
  - [ ] Document all required variables

- [ ] **App Service Settings**
  ```bash
  az webapp config appsettings set \
    --resource-group <rg> \
    --name <app-name> \
    --settings <variables>
  ```

- [ ] **Container Configuration**
  - [ ] Docker image URI correct
  - [ ] Registry credentials valid
  - [ ] Startup command correct
  - [ ] Health checks configured

- [ ] **Networking**
  - [ ] CORS origins configured
  - [ ] API endpoints accessible
  - [ ] Rate limiting enabled
  - [ ] DDoS protection enabled

## Testing & Validation

### Functional Testing

- [ ] **User Registration**
  - [ ] Can create new account
  - [ ] Email validation works
  - [ ] Password hashing verified

- [ ] **Authentication**
  - [ ] Login works with correct credentials
  - [ ] JWT tokens issued correctly
  - [ ] Token expiration enforced
  - [ ] Logout clears session

- [ ] **TODO Operations**
  - [ ] Create TODO item
  - [ ] Read TODO items
  - [ ] Update TODO item
  - [ ] Delete TODO item
  - [ ] Mark as completed/incomplete

- [ ] **API Endpoints**
  - [ ] All endpoints respond with correct status codes
  - [ ] Error messages are appropriate
  - [ ] Pagination works if implemented
  - [ ] Filtering works if implemented

### Security Testing

- [ ] **HTTPS/SSL**
  - [ ] HTTPS enforced (HTTP redirects)
  - [ ] Certificate is valid (not self-signed)
  - [ ] Certificate not expired
  - [ ] Mixed content warnings absent

- [ ] **Authentication**
  - [ ] Unauthorized access denied
  - [ ] Token tampering detected
  - [ ] Session hijacking prevented
  - [ ] CSRF protection enabled

- [ ] **Data Security**
  - [ ] Passwords properly hashed (bcrypt)
  - [ ] No sensitive data in logs
  - [ ] Sensitive fields masked in responses
  - [ ] SQL injection prevented

- [ ] **CORS & Headers**
  - [ ] CORS origins restricted
  - [ ] Security headers present:
    - [ ] X-Content-Type-Options: nosniff
    - [ ] X-Frame-Options: SAMEORIGIN
    - [ ] X-XSS-Protection: 1; mode=block
    - [ ] Strict-Transport-Security: max-age=...

### Performance Testing

- [ ] **Load Testing**
  - [ ] Test with 50+ concurrent users
  - [ ] Response times acceptable (<500ms)
  - [ ] No memory leaks
  - [ ] Database queries optimized

- [ ] **Database Performance**
  - [ ] Indexes created for common queries
  - [ ] Query execution times acceptable
  - [ ] Database connections pooled
  - [ ] No N+1 queries

## Monitoring & Logging

- [ ] **Application Monitoring**
  - [ ] Enable Application Insights
  - [ ] Configure alerts for errors
  - [ ] Monitor response times
  - [ ] Track user analytics

- [ ] **Logging**
  - [ ] Application logs enabled
  - [ ] Log level set to INFO in production
  - [ ] Logs stored securely
  - [ ] Log retention policy set

- [ ] **Alerts & Monitoring**
  - [ ] Alert on high error rates
  - [ ] Alert on slow responses
  - [ ] Alert on database issues
  - [ ] Alert on security events

## Post-Deployment

- [ ] **Verify Deployment**
  ```bash
  curl https://yourdomain.com
  curl https://yourdomain.com/api/health
  ```

- [ ] **Monitor Initial Traffic**
  - [ ] Check logs for errors
  - [ ] Verify database connectivity
  - [ ] Monitor resource usage
  - [ ] Check API response times

- [ ] **User Communication**
  - [ ] Send deployment notification
  - [ ] Update any documentation
  - [ ] Provide feedback channel
  - [ ] Monitor support tickets

- [ ] **Documentation**
  - [ ] Update infrastructure docs
  - [ ] Document access procedures
  - [ ] Create runbooks for common issues
  - [ ] Document incident response

## Ongoing Maintenance

### Weekly

- [ ] Review error logs
- [ ] Check database disk usage
- [ ] Verify backup completion
- [ ] Monitor cost spending

### Monthly

- [ ] Update dependencies
- [ ] Review security logs
- [ ] Update SSL certificate if needed
- [ ] Performance optimization review

### Quarterly

- [ ] Security audit
- [ ] Disaster recovery test
- [ ] Capacity planning review
- [ ] Cost optimization review

## Rollback Procedure

If deployment fails:

1. **Immediate Actions**
   ```bash
   # Restart app service
   az webapp restart --resource-group <rg> --name <app-name>
   
   # Check logs
   az webapp log tail --resource-group <rg> --name <app-name>
   ```

2. **Rollback to Previous Version**
   ```bash
   # Get previous image version
   az acr repository show-tags --name <registry> --repository todo-app
   
   # Update app service to use previous version
   az webapp config container set \
     --resource-group <rg> \
     --name <app-name> \
     --docker-custom-image-name <registry>/todo-app:previous-tag
   
   # Restart
   az webapp restart --resource-group <rg> --name <app-name>
   ```

3. **Investigate Failure**
   - Review application logs
   - Check database connectivity
   - Verify environment variables
   - Review recent code changes

## Useful Commands

```bash
# View application logs
az webapp log tail --resource-group <rg> --name <app-name>

# Restart app
az webapp restart --resource-group <rg> --name <app-name>

# View configuration
az webapp config show --resource-group <rg> --name <app-name>

# Update container image
az webapp config container set \
  --resource-group <rg> \
  --name <app-name> \
  --docker-custom-image-name <image-uri>

# View deployment history
az webapp deployment list --resource-group <rg> --name <app-name>

# Generate access logs
az storage blob generate-sas --account-name <storage> --container-name logs --name <logfile>
```

## Support & Escalation

| Issue | Action |
|-------|--------|
| App not responding | Restart app service, check logs |
| Database connection error | Verify DATABASE_URL, check firewall rules |
| SSL certificate error | Verify certificate, check renewal |
| High error rate | Check recent deployments, review code changes |
| Performance degradation | Check database queries, monitor resource usage |

---

**Deployment Date**: _______________
**Deployed By**: _______________
**Version**: _______________
**Notes**: _______________
