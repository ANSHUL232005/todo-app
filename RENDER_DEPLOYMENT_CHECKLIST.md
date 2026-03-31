# 🎯 RENDER DEPLOYMENT - EXACT CHECKLIST

## STEP 1: CREATE BACKEND SERVICE

### What to Select:
- **Service Type:** Web Service
- **Environment:** Docker
- **Repository:** todo-app
- **Branch:** main
- **Service Name:** `todo-backend`
- **Region:** Oregon
- **Dockerfile Path:** `backend/Dockerfile`
- **Port:** `8000`

### Environment Variables to Add:

Copy each line exactly as shown:

```
DATABASE_URL = sqlite:///./todo.db
SECRET_KEY = tdZBNliEGoHgUIqQMG_D4jzcU1To9KoFYkf9WyZ6gAQ
ALGORITHM = HS256
ACCESS_TOKEN_EXPIRE_MINUTES = 30
REFRESH_TOKEN_EXPIRE_DAYS = 7
```

### Click: `Deploy`

**Wait for backend to show "Live" (green status)**

---

## STEP 2: COPY YOUR BACKEND URL

After backend deploys, copy the URL shown (looks like):
```
https://todo-backend-abc123def456.onrender.com
```

You'll need this for the frontend configuration.

---

## STEP 3: CREATE FRONTEND SERVICE

### What to Select:
- **Service Type:** Web Service
- **Environment:** Docker
- **Repository:** todo-app
- **Branch:** main
- **Service Name:** `todo-frontend`
- **Region:** Oregon
- **Dockerfile Path:** `frontend/Dockerfile`
- **Port:** `3000`

### Environment Variables to Add:

```
REACT_APP_API_URL = https://todo-backend-abc123def456.onrender.com
```

(Replace with your actual backend URL from Step 2)

### Click: `Deploy`

---

## STEP 4: VERIFY DEPLOYMENT

When both services show **"Live"** (green):

✅ **Frontend Ready:**
```
https://todo-frontend-xyz789.onrender.com
```

✅ **Backend Ready:**
```
https://todo-backend-abc123def456.onrender.com
```

✅ **API Docs:**
```
https://todo-backend-abc123def456.onrender.com/docs
```

---

## ⚠️ WHAT NOT TO DO

- ❌ Do NOT select "Static Site" (wrong service type)
- ❌ Do NOT select "Web Service (Node)" (use Docker instead)
- ❌ Do NOT change port numbers (8000 for backend, 3000 for frontend)
- ❌ Do NOT modify Dockerfile paths
- ❌ Do NOT skip environment variables
- ❌ Do NOT forget to copy backend URL to frontend REACT_APP_API_URL

---

## 🧪 TEST YOUR DEPLOYMENT

1. Open: `https://todo-frontend-xyz789.onrender.com`
2. Click "Register"
3. Create account with any username/password
4. Create a TODO item
5. Verify it appears in the list

✅ If this works, **you're done!** Your app is live! 🎉

---

## 🆘 TROUBLESHOOTING

| Problem | Solution |
|---------|----------|
| Backend says "Build Failed" | Check `requirements.txt` has all packages |
| Frontend is blank page | Ensure `REACT_APP_API_URL` points to correct backend |
| Can't register users | Verify `SECRET_KEY` environment variable is set |
| "Cannot reach API" error | Check that both services show "Live" status |
| Database appears empty after redeploy | SQLite resets; use PostgreSQL for persistence |

---

## ✨ SUCCESS INDICATORS

When you see these, deployment is complete:

- ✅ Both services show "Live" (green checkmark)
- ✅ Frontend loads in browser without errors
- ✅ Can register new user
- ✅ Can create and view TODOs
- ✅ API Docs page works at `/docs`

**Congratulations! Your TODO app is live on the internet!** 🚀
