#!/bin/bash

# Script to remove test.http from Git history and GitHub

echo "=========================================="
echo "Removing test.http from Git History"
echo "=========================================="
echo ""

echo "⚠️  WARNING: This will rewrite Git history!"
echo "⚠️  All collaborators will need to re-clone the repo!"
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 0
fi

# Step 1: Remove test.http from Git tracking (but keep local file)
echo ""
echo "Step 1: Removing test.http from Git tracking..."
git rm --cached server/test.http

# Step 2: Commit the removal
echo ""
echo "Step 2: Committing .gitignore changes..."
git add .gitignore server/.gitignore
git commit -m "chore: add test.http to .gitignore and remove from tracking"

# Step 3: Remove from all history using git filter-repo (recommended) or BFG
echo ""
echo "Step 3: Removing test.http from commit history..."
echo ""
echo "Choose method:"
echo "1) git filter-repo (recommended, requires installation)"
echo "2) git filter-branch (built-in, slower)"
echo "3) BFG Repo-Cleaner (requires installation)"
read -p "Enter choice (1-3): " method

case $method in
    1)
        # Check if git-filter-repo is installed
        if ! command -v git-filter-repo &> /dev/null; then
            echo ""
            echo "git-filter-repo not found. Install it:"
            echo "pip install git-filter-repo"
            echo ""
            echo "Or use method 2 (git filter-branch)"
            exit 1
        fi
        
        git filter-repo --path server/test.http --invert-paths --force
        ;;
    2)
        git filter-branch --force --index-filter \
            "git rm --cached --ignore-unmatch server/test.http" \
            --prune-empty --tag-name-filter cat -- --all
        ;;
    3)
        if [ ! -f bfg.jar ]; then
            echo "Downloading BFG Repo-Cleaner..."
            wget https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar -O bfg.jar
        fi
        
        java -jar bfg.jar --delete-files server/test.http
        git reflog expire --expire=now --all
        git gc --prune=now --aggressive
        ;;
    *)
        echo "Invalid choice. Aborted."
        exit 1
        ;;
esac

# Step 4: Force push to GitHub
echo ""
echo "Step 4: Force pushing to GitHub..."
echo "⚠️  This will overwrite remote history!"
read -p "Continue with force push? (yes/no): " push_confirm

if [ "$push_confirm" = "yes" ]; then
    git push origin --force --all
    git push origin --force --tags
    echo ""
    echo "✅ Done! test.http removed from Git history and GitHub"
else
    echo ""
    echo "⚠️  Changes made locally but NOT pushed to GitHub"
    echo "To push later, run:"
    echo "  git push origin --force --all"
    echo "  git push origin --force --tags"
fi

echo ""
echo "=========================================="
echo "IMPORTANT SECURITY STEPS:"
echo "=========================================="
echo "1. ⚠️  ROTATE ALL SECRETS in server/test.http"
echo "   - Generate new JWT_SECRET"
echo "   - Change MongoDB credentials"
echo "2. Update secrets in k8s/server/secret.yaml"
echo "3. Tell collaborators to re-clone the repo"
echo ""
