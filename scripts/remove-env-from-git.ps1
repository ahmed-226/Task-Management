# PowerShell script to remove .env from Git history

Write-Host "==========================================" -ForegroundColor Blue
Write-Host "Removing .env from Git History" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Blue
Write-Host ""

Write-Host "⚠️  WARNING: This will rewrite Git history!" -ForegroundColor Yellow
Write-Host "⚠️  All collaborators will need to re-clone the repo!" -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "Continue? (yes/no)"

if ($confirm -ne "yes") {
    Write-Host "Aborted." -ForegroundColor Red
    exit 0
}

# Step 1: Remove .env from Git tracking (but keep local file)
Write-Host ""
Write-Host "Step 1: Removing .env from Git tracking..." -ForegroundColor Blue
git rm --cached server/.env

# Step 2: Commit the removal
Write-Host ""
Write-Host "Step 2: Committing .gitignore changes..." -ForegroundColor Blue
git add .gitignore server/.gitignore
git commit -m "chore: add .env to .gitignore and remove from tracking"

# Step 3: Remove from all history
Write-Host ""
Write-Host "Step 3: Removing .env from commit history..." -ForegroundColor Blue
Write-Host ""
Write-Host "Using git filter-branch (built-in method)..." -ForegroundColor Yellow

git filter-branch --force --index-filter `
    "git rm --cached --ignore-unmatch server/.env" `
    --prune-empty --tag-name-filter cat -- --all

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error removing from history" -ForegroundColor Red
    exit 1
}

# Step 4: Force push to GitHub
Write-Host ""
Write-Host "Step 4: Force pushing to GitHub..." -ForegroundColor Blue
Write-Host "⚠️  This will overwrite remote history!" -ForegroundColor Yellow
$pushConfirm = Read-Host "Continue with force push? (yes/no)"

if ($pushConfirm -eq "yes") {
    git push origin --force --all
    git push origin --force --tags
    Write-Host ""
    Write-Host "✅ Done! .env removed from Git history and GitHub" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "⚠️  Changes made locally but NOT pushed to GitHub" -ForegroundColor Yellow
    Write-Host "To push later, run:" -ForegroundColor Yellow
    Write-Host "  git push origin --force --all" -ForegroundColor Yellow
    Write-Host "  git push origin --force --tags" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Blue
Write-Host "IMPORTANT SECURITY STEPS:" -ForegroundColor Red
Write-Host "==========================================" -ForegroundColor Blue
Write-Host "1. ⚠️  ROTATE ALL SECRETS in server/.env" -ForegroundColor Yellow
Write-Host "   - Generate new JWT_SECRET" -ForegroundColor Yellow
Write-Host "   - Change MongoDB credentials" -ForegroundColor Yellow
Write-Host "2. Update secrets in k8s/server/secret.yaml" -ForegroundColor Yellow
Write-Host "3. Tell collaborators to re-clone the repo" -ForegroundColor Yellow
Write-Host ""
