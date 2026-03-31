# Render Deployment for TODO Project

This guide uses Render.com (Docker deployment) and avoids Railway.

## 1. Prerequisites

- GitHub account
- Render account
- `git` installed
- `docker` build works locally (confirmed)

## 2. Ensure code is pushed to GitHub
```powershell
cd "c:\Users\HP\TODO Project"
git init
git add .
git commit -m "TODO app full Docker deployment"
git branch -M main
git remote add origin https://github.com/ANSHUL232005/todo-app.git
git push -u origin main
```

## 3. Render project setup

1. Login to [Render dashboard](https://dashboard.render.com)
2. Click **New +** → **Web Service**
3. Select GitHub repo `todo-app` -> branch `main`
4. Select **Docker** as environment
5. For backend:
   - Name: `todo-backend`
   - Dockerfile path: `backend/Dockerfile`
   - Port: `8000`
6. For frontend:
   - Name: `todo-frontend`
   - Dockerfile path: `frontend/Dockerfile`
   - Port: `3000`

## 4. Environment variables on Render

Add for `todo-backend` service:
- DATABASE_URL=sqlite:///./todo.db
- `SECRET_KEY=<your-secret>`
- ALGORITHM=HS256
- ACCESS_TOKEN_EXPIRE_MINUTES=30
- REFRESH_TOKEN_EXPIRE_DAYS=7

Add for `todo-frontend` service:
- REACT_APP_API_URL=[https://todo-backend.onrender.com](https://todo-backend.onrender.com) or `http://todo-backend:8000`

## 5. Health check (optional)

- Backend: `http://localhost:8000/api/health`
- Frontend: `http://localhost:3000`

## 6. Deployment via Render CLI (optional)

Install CLI: `curl -fsSL https://cdn.render.com/docs/install.sh | bash`

Authenticate:
`render login`

Trigger deploy:
`render deploy --service todo-backend`
`render deploy --service todo-frontend`

## 7. Verifying live status

- `curl https://todo-backend.onrender.com/api/health`
- `curl https://todo-frontend.onrender.com`

---

> Notes:
>
> - Ensure `render.yaml` is in repo root for automatic render.yml-based devops.
> - If backend/DB needs persistence, switch to PostgreSQL on Render and update DATABASE_URL.
