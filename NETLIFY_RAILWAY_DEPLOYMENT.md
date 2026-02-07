# Deploy to Netlify + Railway (Free Tier)

**Total Cost:** $0/month (with Railway free tier)  
**Deploy Time:** ~15 minutes  
**Uptime:** 99.9%+ with global CDN

## Architecture

```
┌─────────────────────────┐
│   Your Custom Domain    │
│   (or provided)         │
└────────────┬────────────┘
             │
        ┌────┴────┐
        │
    ┌───────────┐              ┌──────────────┐
    │  Netlify  │              │    Railway   │
    │ Frontend  │──────────→   │   Backend +  │
    │ (React)   │              │  PostgreSQL  │
    └───────────┘              └──────────────┘
    - Static hosting           - Python API
    - CDN x170 cities          - PostgreSQL DB
    - Auto HTTPS               - 5GB/month free
```

---

## Prerequisites

- GitHub account (for version control)
- Netlify account (free at https://netlify.com)
- Railway account (free at https://railway.app)
- Git CLI installed

---

## Step 1: Prepare Repository

### 1.1 Initialize Git (if not already done)

```bash
cd "c:\Users\HP\TODO Project"
git init
git add .
git commit -m "Initial TODO app commit"
```

### 1.2 Push to GitHub

1. Go to https://github.com/new
2. Create a new repository named `todo-app`
3. Run these commands:

```bash
git remote add origin https://github.com/YOUR-USERNAME/todo-app.git
git branch -M main
git push -u origin main
```

---

## Step 2: Deploy Backend to Railway

### 2.1 Sign Up on Railway

1. Go to https://railway.app
2. Click "Create New Project"
3. Click "Deploy from GitHub repo"
4. Select your `todo-app` repository
5. Click "Deploy"

### 2.2 Configure Backend Service

On the Railway dashboard:

1. **Add PostgreSQL Database**
   - Click "Add" → Select "PostgreSQL"
   - Wait for it to provision (1-2 minutes)

2. **Configure FastAPI Service**
   - Click on your deployed service
   - Go to "Settings"
   - Set environment variables:

```
DATABASE_URL=<from PostgreSQL plugin>
SECRET_KEY=<generate with: python -c "import secrets; print(secrets.token_urlsafe(32))">
ENVIRONMENT=production
DEBUG=false
CORS_ORIGINS=https://your-netlify-site.netlify.app
```

3. **Get Backend URL**
   - In Railway dashboard, your service will have a URL like:
   - `https://todo-backend-production.railway.app`
   - Save this URL — you'll need it for frontend

### 2.3 Verify Backend is Running

```bash
curl https://todo-backend-production.railway.app/api/health
# Should return: {"status":"ok"}
```

---

## Step 3: Deploy Frontend to Netlify

### 3.1 Connect Netlify to GitHub

1. Go to https://netlify.com
2. Click "New site from Git"
3. Choose GitHub and select your `todo-app` repository
4. **Netlify will auto-detect:**
   - Build command: `npm install --legacy-peer-deps --force && npm run build`
   - Publish directory: `dist`

### 3.2 Set Environment Variables in Netlify

1. In Netlify dashboard, go to **Site settings** → **Environment**
2. Click **Edit variables**
3. Add:

```
VITE_API_URL=https://todo-backend-production.railway.app/api
NODE_VERSION=18
```

### 3.3 Trigger Deploy

1. Go to **Deploys**
2. Click "Trigger deploy" → "Deploy site"
3. Wait ~2-3 minutes for build to complete
4. Your site is live! 🎉

**Frontend URL:** `https://your-site-name.netlify.app`

---

## Step 4: Link Your Domain (Optional)

### With Custom Domain

1. In Netlify: **Domain settings** → **Add domain**
2. Point your domain's nameservers (or DNS) to Netlify
3. Netlify provides free SSL certificate automatically

### Update Backend CORS

In Railway, update `CORS_ORIGINS`:

```
https://yourdomain.com,https://www.yourdomain.com,https://your-site-name.netlify.app
```

---

## Test Deployment

1. Open your frontend: `https://your-site-name.netlify.app`
2. **Register** a new account
3. **Login** with your credentials
4. **Create a TODO** item
5. **Mark as done**

If you get CORS errors:
- Check `CORS_ORIGINS` in Railway environment
- Verify `VITE_API_URL` is correct in Netlify environment
- Run backend health check: `curl https://your-backend.railway.app/api/health`

---

## Monitoring & Logs

### Netlify Logs

- Dashboard → **Deploys** → click any deploy → **Deploy log**

### Railway Logs

- Dashboard → select service → click **Logs** tab
- View real-time logs, error traces

### Database Logs

- Railway → PostgreSQL service → **Logs**

---

## Cost Breakdown

| Service | Free Tier | Paid Plans |
|---------|-----------|-----------|
| **Netlify** | 300 build min/mo | $19+/mo |
| **Railway** | $5 credit/mo | $0.10/hr per vCPU |
| **PostgreSQL** (Railway) | $5 credit covers ~20GB | Included in Railway |
| **Total** | **$0/month** | ~$10-30/mo |

---

## Common Issues & Fixes

### Frontend shows "Cannot reach backend"

**Fix:**
1. Verify backend URL in Netlify environment: `VITE_API_URL`
2. Check Railway logs for errors
3. Ensure CORS_ORIGINS includes your Netlify domain
4. Clear browser cache: `Ctrl+Shift+Delete`

### Login/Register not working

**Fix:**
1. Check PostgreSQL is running: `SELECT 1` in Railway
2. Check backend logs: `curl https://your-backend.railway.app/api/health`
3. Verify `SECRET_KEY` and `DATABASE_URL` set in Railway

### Slow initial load

**Fix:**
- Railway free tier has "idle timeout" — after 15 min of no activity, service sleeps
- First request after sleep takes 4-5 seconds (cold start)
- Solution: Upgrade to Railway paid plan (~$7/mo) for "Always On"

### Build fails on Netlify

**Fix:**
1. Check build logs: Dashboard → Deploys → click failed deploy
2. Common: missing `.env.production` file or wrong `VITE_API_URL`
3. Rebuild: **Deploys** → **Trigger deploy**

---

## Upgrade to Always-On (Optional)

To eliminate cold starts after 15 minutes:

1. In Railway: Go to your project → **Settings**
2. Upgrade to **Railway Plus** (~$7/month minimum)
3. Your backend will stay warm 24/7

---

## Rollback Recent Deployment

**If something breaks:**

### Netlify
- **Deploys** → click a previous successful deploy → **Restore**

### Railway
- **Deployments** → click previous version → **Redeploy**

---

## Next Steps After Deployment

1. **Monitor**: Set up error alerts in Railway & Netlify
2. **Backup**: Enable PostgreSQL backups in Railway
3. **Scale**: As traffic grows, upgrade Railway plan
4. **Domain**: Connect your custom domain through Netlify
5. **Analytics**: Enable Netlify Analytics (free)

---

## Support & Useful Links

- **Netlify Docs**: https://docs.netlify.com
- **Railway Docs**: https://docs.railway.app
- **FastAPI Deployment**: https://fastapi.tiangolo.com/deployment/
- **Railway Community**: https://railway.app/support

---

**Questions?** Check logs first:
- Netlify: **Deploys** tab
- Railway: **Logs** tab in each service
- Browser console: Press `F12`
