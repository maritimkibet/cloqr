#!/bin/bash

echo "🚀 Deploying Cloqr to Production"
echo "=================================="
echo ""

# Step 1: Push to GitHub (triggers Render deployment)
echo "📤 Step 1: Pushing to GitHub..."
git add .
git commit -m "Deploy: $(date '+%Y-%m-%d %H:%M:%S')" || echo "No changes to commit"
git push origin main

echo ""
echo "✅ Code pushed to GitHub"
echo "⏳ Render.com will auto-deploy in 2-3 minutes"
echo ""

# Step 2: Instructions for database migration
echo "📊 Step 2: Database Migration Required"
echo "======================================="
echo ""
echo "You need to run the SQL migration on your Render PostgreSQL database:"
echo ""
echo "Option A: Using Render Dashboard"
echo "  1. Go to https://dashboard.render.com"
echo "  2. Click on 'cloqr-db' database"
echo "  3. Click 'Connect' and copy the External Database URL"
echo "  4. Run: psql <DATABASE_URL> -f cloqr-backend/NEW_FEATURES_SCHEMA.sql"
echo ""
echo "Option B: Using Render Shell"
echo "  1. Go to https://dashboard.render.com"
echo "  2. Click on 'cloqr-backend' service"
echo "  3. Click 'Shell' tab"
echo "  4. Run: node migrate-new-features.js"
echo ""
echo "⚠️  Important: Run the migration AFTER the deployment completes!"
echo ""

# Step 3: Build Flutter APK
echo "📱 Step 3: Building Flutter APK..."
echo "==================================="
echo ""
echo "After migration completes, build the APK:"
echo "  cd mobile"
echo "  flutter build apk --release"
echo ""
echo "APK will be at: mobile/build/app/outputs/flutter-apk/app-release.apk"
echo ""

echo "🎉 Deployment initiated!"
echo ""
echo "Next steps:"
echo "  1. Wait for Render deployment (check https://dashboard.render.com)"
echo "  2. Run database migration (see instructions above)"
echo "  3. Build Flutter APK"
echo "  4. Share APK with users!"
