# 🔐 Ceylon Explorer - Setup Guide for Team Members

## ⚠️ IMPORTANT: Secret Files

This project uses **Firebase** and **Google APIs**. Before you can run the project, you need to obtain the secret configuration files.

### Files You Need to Create:

1. **`dart_defines.json`** - Gemini API configuration
   - Copy from: `dart_defines.example.json`
   - Ask your team lead for the actual API keys
2. **`android/app/google-services.json`** - Firebase Android configuration
   - Download from Firebase Console (Project Settings → google-services.json)
   - Ask your team lead if you don't have access

3. **`ios/Runner/GoogleService-Info.plist`** (if building for iOS)
   - Download from Firebase Console
   - Ask your team lead if you don't have access

### Setup Steps:

```bash
# 1. Clone the repository
git clone <repo-url>
cd ceylon_explorer

# 2. Copy example files and fill in your credentials
cp dart_defines.example.json dart_defines.json
cp android/app/google-services.example.json android/app/google-services.json

# 3. Ask your team lead for the actual API keys and paste them into the files
#    DO NOT commit these files (they're in .gitignore)

# 4. Install dependencies
flutter pub get

# 5. Run the app
flutter run
```

### 🔒 Security Guidelines:

- ✅ **DO:** Keep API keys in the local files (dart_defines.json, google-services.json)
- ❌ **DON'T:** Commit these files to git (they're in .gitignore)
- ❌ **DON'T:** Share API keys in messages, emails, or Slack
- ✅ **DO:** Share them securely (in-person, secure password manager, or through your company's secret management system)
- ❌ **DON'T:** Share your Firebase project directly unless necessary
- ✅ **DO:** Use service accounts with limited permissions when possible

### Need Help?

Contact your team lead to get the configuration files.
