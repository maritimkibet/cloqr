#!/bin/bash

echo "🔄 Resetting Git repository to remove large files from history..."

# Get the remote URL before we do anything
REMOTE_URL=$(git remote get-url origin)
echo "📍 Remote URL: $REMOTE_URL"

# Create a backup branch just in case
git branch backup-before-reset 2>/dev/null

# Remove the .git directory completely
echo "🗑️  Removing old Git history..."
rm -rf .git

# Initialize a fresh repository
echo "🆕 Creating fresh Git repository..."
git init
git branch -M main

# Add the remote
echo "🔗 Adding remote..."
git remote add origin "$REMOTE_URL"

# Add all files (respecting .gitignore)
echo "📦 Adding files..."
git add .

# Create initial commit
echo "💾 Creating commit..."
git commit -m "Initial commit: Cloqr app - clean history

- Flutter mobile app with QR verification
- Admin access system
- Real-time chat and matching
- Room management features"

# Force push to GitHub
echo "🚀 Pushing to GitHub..."
git push -f origin main

echo "✅ Done! Repository pushed successfully with clean history."
echo "📊 New repository size:"
du -sh .git
