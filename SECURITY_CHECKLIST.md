# 🔐 Security Checklist - Before Sharing on GitHub

## ✅ What We've Done:

1. **Updated `.gitignore`** to exclude:
   - `dart_defines.json` (Gemini API Key)
   - `google-services.json` (Firebase secrets)
   - `firebase.json`, `firestore.rules`, `firestore.indexes.json`
   - `key.properties` (Android keystore)
   - `.env` files
   - Other sensitive files

2. **Created example files** for your team:
   - `dart_defines.example.json` - Template for Dart configuration
   - `android/app/google-services.example.json` - Template for Firebase (Android)
   - This guide (`SECURITY_CHECKLIST.md`)

3. **Documentation** created:
   - `SETUP_GUIDE.md` - Instructions for team members to set up locally

---

## ⚠️ CRITICAL: Check Git History

**BEFORE pushing to GitHub**, you MUST verify that sensitive files haven't been committed yet:

```powershell
# Check if secret files are in git history
git log --all --full-history -- dart_defines.json
git log --all --full-history -- android/app/google-services.json
```

### If files are already committed (they show up in the output above):

You NEED to remove them from history using:

```powershell
# Remove from git history (use BFG or git-filter-branch)
# Option 1: Using BFG Repo-Cleaner (recommended, easier)
bfg --delete-files dart_defines.json

# Option 2: Using git filter-branch (more manual)
git filter-branch --tree-filter 'rm -f dart_defines.json' HEAD
```

Then run:

```powershell
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

---

## 📋 Pre-GitHub Checklist:

- [ ] Run: `git status` and verify secret files are NOT listed (they should be ignored)
- [ ] Run: `git log --all --full-history -- dart_defines.json` and ensure it's empty
- [ ] Run: `git log --all --full-history -- android/app/google-services.json` and ensure it's empty
- [ ] Verify all example files exist:
  - [ ] `dart_defines.example.json`
  - [ ] `android/app/google-services.example.json`
- [ ] Check `SETUP_GUIDE.md` exists with team setup instructions
- [ ] All team members know HOW to get the actual secret files

---

## 🚀 When Sharing with Team Members:

### Step 1: Invite them to GitHub

- Go to GitHub repo → Settings → Collaborators
- Add their GitHub username

### Step 2: Send them SETUP_GUIDE.md

- Don't share API keys directly in messages
- Point them to the `SETUP_GUIDE.md` in the repo

### Step 3: Share secrets SECURELY

- Use your company's secret management system, OR
- Share API keys in-person / via secure password manager, OR
- Have them login to Firebase/Google Cloud Console themselves

### Step 4: Verify setup

- Ask them to clone the repo
- Ask them to create the config files from examples
- Paste in the secrets
- Run `flutter pub get` and test

---

## 🔒 Future Best Practices:

1. **Use Environment Variables**: For CI/CD pipelines, use GitHub Secrets instead of committing files
2. **Firebase Service Accounts**: For backend services, use service accounts with limited permissions
3. **Rotate Keys**: If a secret is ever exposed, rotate it immediately
4. **Code Review**: Before any push to GitHub, check with: `git diff --staged` to ensure no secrets are included

---

## 📞 Questions?

Contact your team lead or check the repo's README for more security guidelines.
