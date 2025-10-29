# 🔑 API Key Setup Instructions

## For Developers

### 1. Get Your OpenAI API Key
- Go to: https://platform.openai.com/api-keys
- Create a new secret key
- Copy the key (starts with `sk-`)

### 2. Add to Info.plist
Open `flrt/Info.plist` and replace `YOUR_API_KEY_HERE`:

```xml
<key>OPENAI_API_KEY</key>
<string>YOUR_ACTUAL_KEY_HERE</string>
```

### 3. Keep It Private!
- ⚠️ **NEVER commit your real API key to git**
- The Info.plist file has a placeholder
- Add your real key locally only

### Alternative: Use Keychain
For production apps, use the keychain instead:

```swift
// In your app startup
APIConfiguration.shared.setOpenAIKey("your-actual-key")
```

## Security Notes
- API keys are sensitive credentials
- Each developer should use their own key
- Never share keys in public repositories
- Rotate keys if accidentally exposed

