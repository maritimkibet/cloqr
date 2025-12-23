#!/bin/bash

# Script to create admin user on production (Render)
# Run this in Render's shell or locally with production DATABASE_URL

echo "🔧 Creating Admin User on Production..."
echo ""

# Check if environment variables are set
if [ -z "$ADMIN_EMAIL" ] || [ -z "$ADMIN_PASSWORD" ]; then
    echo "❌ Error: ADMIN_EMAIL and ADMIN_PASSWORD must be set"
    echo ""
    echo "Set them in Render dashboard:"
    echo "1. Go to your service settings"
    echo "2. Add Environment Variables:"
    echo "   ADMIN_EMAIL=brianvocalto@gmail.com"
    echo "   ADMIN_PASSWORD=your-secure-password"
    echo ""
    exit 1
fi

# Run the create-admin script
node create-admin.js

echo ""
echo "✅ Done!"
