# Render Deployment - Quick Start Guide

## ❌ WRONG: You are on "New Static Site" page
The screenshot shows you clicked "New Static Site" which is for static websites (HTML/CSS/JS only).

## ✅ CORRECT: Select "Web Service" Instead

### Action Now:
1. Click the **back button** or **Render logo**
2. From dashboard, click **"New +"** 
3. Select **"Web Service"** from dropdown (NOT "New Static Site")

---

## Deploy Backend Service

**After selecting "Web Service":**

### Configuration Fields:
| Field | Value |
|-------|-------|
| Repository | Select `todo-app` |
| Branch | `main` |
| Environment | `Docker` |
| Name | `todo-backend` |
| Region | `Oregon` |
| Dockerfile path | `backend/Dockerfile` |
| Port | `8000` |

### Environment Variables:
Add these in "Environment Variables" section:
```
DATABASE_URL=sqlite:///./todo.db
SECRET_KEY=tdZBNliEGoHgUIqQMG_D4jzcU1To9KoFYkf9WyZ6gAQ
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7
```

### Deploy:
Click **"Deploy"** button. Wait 2-3 minutes.

**Status Check:** Should show ✅ "Live" (green)

---

## Deploy Frontend Service

**After backend is Live:**

### Configuration Fields:
| Field | Value |
|-------|-------|
| Repository | Select `todo-app` |
| Branch | `main` |
| Environment | `Docker` |
| Name | `todo-frontend` |
| Region | `Oregon` |
| Dockerfile path | `frontend/Dockerfile` |
| Port | `3000` |

### Environment Variables:
Add this in "Environment Variables" section:

**Copy your backend URL from step 1** (looks like: `https://todo-backend-xxxxx.onrender.com`)

Then add:
```
REACT_APP_API_URL=https://todo-backend-xxxxx.onrender.com
```

### Deploy:
Click **"Deploy"** button. Wait 2-3 minutes.

**Status Check:** Should show ✅ "Live" (green)

---

## 🎉 You're Live!

Once both services show "Live":

| Service | URL |
|---------|-----|
| Frontend | `https://todo-frontend-xxxxx.onrender.com` |
| Backend | `https://todo-backend-xxxxx.onrender.com` |
| API Docs | `https://todo-backend-xxxxx.onrender.com/docs` |

**Share the frontend URL with anyone!** They can register and use your TODO app.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Backend won't build | Check `backend/requirements.txt` exists and is valid |
| Frontend blank page | Verify `REACT_APP_API_URL` points to correct backend URL |
| Can't register users | Check `SECRET_KEY` environment variable is set |
| Services stuck "Deploying" | Check build logs (click service → Logs tab) |

---

## Key Differences from Screenshot

✅ **This Guide Uses:** Web Service + Docker (Multi-container app)  
❌ **Screenshot Shows:** Static Site (Single static HTML page only)

**Web Service = Docker deployment (what you need)**  
**Static Site = HTML/CSS/JS files only (not what you need)**
