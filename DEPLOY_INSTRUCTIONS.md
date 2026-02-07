# Deploy to Netlify + Railway - Step-by-Step Instructions

**Status:** ✓ All code is ready to deploy  
**Time Required:** 20 minutes  
**Cost:** $0/month (free tier)

---

## Quick Summary

Your repo is now ready. You need to:
1. **Create GitHub repo** and push code (5 min)
2. **Deploy backend to Railway** with PostgreSQL (5 min)
3. **Deploy frontend to Netlify** (5 min)
4. **Test** (5 min)

---

## Phase 1: Create GitHub Repository & Push Code

### Step 1.1: Create GitHub Repo

1. Go to https://github.com/new
2. Fill in:
   - **Repository name:** `todo-app`
   - **Description:** "Advanced TODO app with React + FastAPI"
   - **Public** or **Private** (your choice)
3. **Do NOT** initialize with README/license (we already have files)
4. Click **Create repository**

### Step 1.2: Get GitHub Personal Access Token

1. Go to https://github.com/settings/tokens/new
2. Fill in:
   - **Token name:** `todo-deploy`
   - **Expiration:** 90 days
   - **Scopes:** Check `repo` (all)
3. Click **Generate token**
4. **Copy the token immediately** (you won't see it again)

### Step 1.3: Push Code to GitHub

In PowerShell, run:

```powershell
cd "c:\Users\HP\TODO Project"

# Set your GitHub username
$GITHUB_USER = "YOUR-GITHUB-USERNAME"
$GITHUB_TOKEN = "YOUR-GENERATED-TOKEN"

# Add remote and push
git remote add origin "https://github.com/$GITHUB_USER/todo-app.git"
git branch -M main
git push -u origin main
```

**If prompted for credentials:**
- Username: your GitHub username
- Password: paste the token (not your actual password)

---

## Phase 2: Deploy Backend to Railway

### Step 2.1: Sign Up on Railway

1. Go to https://railway.app
2. Click **Login** → **Deploy** (or **Sign up** if new)
3. Authenticate with **GitHub** (or email)

### Step 2.2: Create New Project

1. Click **New Project**
2. Select **Deploy from GitHub repo**
3. **Authorize Railway** to access your GitHub
4. Select repository: `YOUR-USERNAME/todo-app`
5. Select **main** branch
6. Click **Deploy**

**Railway will now:**
- Build your backend image
- Deploy to production
- Show a service URL

### Step 2.3: Add PostgreSQL Database

1. In Railway dashboard, click **New** (or + icon)
2. Select **PostgreSQL**
3. Wait 1-2 minutes for it to provision
4. Click on the PostgreSQL service
5. Find the **DATABASE_URL** in **Variables**
6. Copy it (looks like: `postgresql://user:pass@host:5432/db`)

### Step 2.4: Configure Backend Environment Variables

1. Click on the **FastAPI** service (labeled "todo-app")
2. Go to **Variables** tab
3. Add these variables:

```
DATABASE_URL=<paste from PostgreSQL>
SECRET_KEY=<generate below>
ENVIRONMENT=production
DEBUG=false
CORS_ORIGINS=https://your-netlify-site.netlify.app
```

**To generate SECRET_KEY**, open PowerShell and run:

```powershell
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

Copy the output and paste it as `SECRET_KEY` value.

### Step 2.5: Get Backend URL

1. In Railway, click your **FastAPI service**
2. Go to **Deployments** tab
3. Find the deployment URL (looks like: `https://todo-backend-production.railway.app`)
4. **Save this URL** — you'll need it for Netlify

### Step 2.6: Verify Backend is Running

In PowerShell:

```powershell
$BACKEND_URL = "https://your-railway-url"
Invoke-WebRequest -Uri "$BACKEND_URL/api/health" | Select-Object StatusCode, Content
# Should show: StatusCode 200, Content {"status":"ok"}
```

---

## Phase 3: Deploy Frontend to Netlify

### Step 3.1: Sign Up on Netlify

1. Go to https://netlify.com
2. Click **Sign up** (or **Log in** if existing)
3. Choose **GitHub** as auth method
4. Authorize Netlify to access your repos

### Step 3.2: Create New Site

1. Click **Add new site** → **Import an existing project**
2. Choose **GitHub**
3. Select your `todo-app` repository
4. Netlify will auto-detect:
   - **Build command:** `npm install --legacy-peer-deps --force && npm run build`
   - **Publish directory:** `dist`
5. Click **Deploy site**

**Netlify will now:**
- Install dependencies (~1 min)
- Build your frontend (~2 min)
- Deploy to CDN

### Step 3.3: Add Environment Variables

While Netlify is building:

1. Go to **Site settings** (top menu)
2. → **Environment** (left sidebar)
3. Click **Edit variables** (or scroll down if shown)
4. Add:

```
VITE_API_URL=<paste your Railway backend URL>/api
NODE_VERSION=18
```

Example:
```
VITE_API_URL=https://todo-backend-production.railway.app/api
NODE_VERSION=18
```

### Step 3.4: Trigger Deploy with New Variables

1. Go to **Deploys** tab
2. Click **Trigger deploy** → **Deploy site**
3. Wait 2-3 minutes for build to complete
4. You'll see a URL like: `https://your-site-name.netlify.app`

**Save this URL!**

### Step 3.5: Update Backend CORS

Now that you have your Netlify URL, update the backend:

1. Go back to **Railway dashboard**
2. Click your **FastAPI service**
3. Go to **Variables**
4. Update `CORS_ORIGINS`:
   ```
   https://your-netlify-site.netlify.app,https://your-netlify-site.netlify.app
   ```
5. Click save and wait for redeployment

---

## Phase 4: Test Your Deployment

### Step 4.1: Open Your App

Open browser to: `https://your-netlify-site.netlify.app`

You should see the TODO app login page.

### Step 4.2: Test Registration

1. Click **Register**
2. Fill in:
   - Username: `testuser`
   - Email: `test@example.com`
   - Password: `SecurePass123!`
3. Click **Sign Up**

**Expected:** New account created, redirected to login

### Step 4.3: Test Login

1. Enter credentials from registration
2. Click **Login**

**Expected:** Logged in, see Dashboard with empty TODO list

### Step 4.4: Test TODO Operations

1. **Create:** Type "Learn React" → click **Add**
   - **Expected:** TODO appears in list
2. **Complete:** Click checkbox
   - **Expected:** TODO marked as done (strikethrough)
3. **Delete:** Click delete icon
   - **Expected:** TODO removed
4. **Update:** Click edit → change text → save
   - **Expected:** TODO text updated

### Step 4.5: Check API Health

In PowerShell:

```powershell
$BACKEND_URL = "https://your-railway-url"
Invoke-WebRequest -Uri "$BACKEND_URL/api/health" | Select-Object StatusCode, Content
```

**Expected:** `{"status":"ok"}`

---

## Troubleshooting

### "Cannot reach backend" / CORS Error

**Fix:**
1. Check `VITE_API_URL` in Netlify environment — must end with `/api`
2. Check `CORS_ORIGINS` in Railway — must include exact Netlify URL
3. Hard refresh browser: `Ctrl+Shift+Delete` → clear cache → reload
4. Check Railway logs: click service → **Logs** tab

### Login/Register Not Working

**Fix:**
1. Railway → **Logs** → check for errors
2. Verify PostgreSQL is running: Railway → PostgreSQL service → check status
3. Verify `DATABASE_URL` is set correctly
4. Browser console: press `F12` → look for network errors

### Slow First Load

**Reason:** Railway free tier sleeps after 15 minutes of inactivity  
**Fix:**
- First request after sleep takes 4-5 seconds (normal)
- To eliminate this: upgrade Railway to **Plus** tier (~$7/month)

### Build Failed on Netlify

**Fix:**
1. Check build logs: **Deploys** → click failed deploy → **Deploy log**
2. Common issue: `VITE_API_URL` not set
3. Rebuild: **Deploys** → **Trigger deploy**

### Can't Push to GitHub

**Common issues:**
- Token expired or wrong scope — create new token
- Wrong branch — use `git branch -M main` first
- Already exists — use `git remote set-url origin <new-url>`

---

## Success Checklist

- [ ] GitHub repo created and code pushed
- [ ] Railway backend deployed and running
- [ ] PostgreSQL database created
- [ ] Netlify frontend deployed
- [ ] Health check passes: `/api/health` returns 200
- [ ] Can register new account
- [ ] Can log in
- [ ] Can create/complete/delete TODOs
- [ ] No CORS errors in browser console

---

## Next Steps (Optional Improvements)

1. **Custom Domain:**
   - Netlify: **Site settings** → **Domain** → add custom domain
   - Railway: Update `CORS_ORIGINS`

2. **Automatic Deploys:**
   - Both platforms auto-deploy on `git push` to main

3. **Monitor:**
   - Railway: **Logs** tab for errors
   - Netlify: **Deploys** tab for build status
   - Check health regularly: `curl https://backend-url/api/health`

4. **Backup:**
   - Railway PostgreSQL → enable backups in settings

5. **Scale Up:**
   - Railway free tier is limited; upgrade as traffic grows
   - Netlify free tier sufficient for most needs

---

## Need Help?

- **Railway Docs:** https://docs.railway.app
- **Netlify Docs:** https://docs.netlify.com
- **Check Logs First:** Always review service logs before asking for help
- **Clear Cache:** Many issues solved by `Ctrl+Shift+Delete`

---

**Questions? Run from your repo root:**

```powershell
# Check git status
git status

# View git log
git log --oneline

# Verify files are committed
git ls-files
```

Good luck! 🚀
