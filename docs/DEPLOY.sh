#!/bin/bash

# Lakshami Contractors Landing Page Deployment Script
# This script helps you deploy your landing page to GitHub Pages

echo "🏗️  Lakshami Contractors Landing Page Deployment"
echo "========================================"
echo ""

# Check if git is initialized
if [ ! -d .git ]; then
    echo "📦 Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit: Lakshami Contractors landing page"
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository already initialized"
fi

# Ask for GitHub username
echo ""
read -p "Enter your GitHub username: " github_username

if [ -z "$github_username" ]; then
    echo "❌ GitHub username is required!"
    exit 1
fi

# Ask for repository name
echo ""
read -p "Enter repository name (default: macappyessir): " repo_name
repo_name=${repo_name:-macappyessir}

echo ""
echo "📋 Summary:"
echo "  Username: $github_username"
echo "  Repository: $repo_name"
echo "  URL: https://github.com/$github_username/$repo_name"
echo ""
read -p "Is this correct? (y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "❌ Cancelled"
    exit 1
fi

# Check if remote already exists
if git remote | grep -q "origin"; then
    echo ""
    echo "⚠️  Remote 'origin' already exists. Removing..."
    git remote remove origin
fi

# Add GitHub remote
echo ""
echo "🔗 Adding GitHub remote..."
git remote add origin "https://github.com/$github_username/$repo_name.git"

# Commit any changes
if [[ -n $(git status -s) ]]; then
    echo ""
    echo "📝 Committing latest changes..."
    git add .
    git commit -m "Update landing page"
fi

# Push to GitHub
echo ""
echo "🚀 Pushing to GitHub..."
git branch -M main
git push -u origin main

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📍 Next steps:"
echo "   1. Go to: https://github.com/$github_username/$repo_name/settings/pages"
echo "   2. Enable GitHub Pages:"
echo "      - Source: Deploy from a branch"
echo "      - Branch: main"
echo "      - Folder: /docs"
echo "   3. Click Save"
echo "   4. Wait 2-3 minutes"
echo ""
echo "🌐 Your site will be live at:"
echo "   https://$github_username.github.io/$repo_name/"
echo ""
echo "🎉 Happy launching!"
