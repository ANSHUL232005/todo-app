#!/bin/bash
# Auto-deploy verification script for Render
# Run this after deployment to verify all systems are healthy

set -e

BACKEND_URL="${BACKEND_URL:-https://todo-backend.onrender.com}"
FRONTEND_URL="${FRONTEND_URL:-https://todo-frontend.onrender.com}"

echo "🔍 Verifying TODO App Deployment..."
echo "=========================================="

# Test 1: Backend Health Check
echo -n "1. Backend Health Check... "
if HEALTH=$(curl -s "$BACKEND_URL/api/health"); then
    echo "✅ OK"
    echo "   Response: $HEALTH"
else
    echo "❌ FAILED"
    exit 1
fi

# Test 2: Frontend Accessibility
echo -n "2. Frontend Accessibility... "
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$FRONTEND_URL")
if [ "$FRONTEND_STATUS" = "200" ]; then
    echo "✅ OK (HTTP 200)"
else
    echo "⚠️  WARNING (HTTP $FRONTEND_STATUS)"
fi

# Test 3: Registration Endpoint
echo -n "3. Registration Endpoint... "
REGISTER_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"username":"test_'$(date +%s)'","email":"test@example.com","password":"TestPassword123"}' \
  -w "\n%{http_code}")

HTTP_CODE=$(echo "$REGISTER_RESPONSE" | tail -n1)
if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "200" ]; then
    echo "✅ OK"
else
    echo "❌ FAILED (HTTP $HTTP_CODE)"
fi

# Test 4: API Documentation
echo -n "4. API Docs (Swagger)... "
DOCS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BACKEND_URL/docs")
if [ "$DOCS_STATUS" = "200" ]; then
    echo "✅ OK"
else
    echo "⚠️  WARNING (HTTP $DOCS_STATUS)"
fi

echo "=========================================="
echo "✅ Deployment Verification Complete!"
echo ""
echo "📱 Access your app:"
echo "   Frontend: $FRONTEND_URL"
echo "   Backend:  $BACKEND_URL"
echo "   API Docs: $BACKEND_URL/docs"
