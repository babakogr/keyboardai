# ⌨️ KeyboardAI — AI-Powered iOS Keyboard

A modern, minimal, high-performance AI Keyboard for iOS. Translate, improve, fix grammar, and generate smart replies — all with a single tap.

---

## 📁 Project Structure

```
keyboardai/
├── backend/                          # Node.js API server
│   ├── .env                          # API keys (NEVER commit)
│   ├── .env.example                  # Template for env vars
│   ├── .gitignore
│   ├── package.json
│   └── src/
│       ├── server.js                 # Express server entry
│       ├── middleware/
│       │   ├── auth.js               # JWT authentication
│       │   └── usage.js              # Rate limiting & usage tracking
│       ├── routes/
│       │   ├── auth.js               # Device registration & token management
│       │   └── ai.js                 # AI endpoint routes
│       └── services/
│           ├── ai.js                 # DeepL + xAI integration
│           ├── cache.js              # LRU response caching
│           └── prompts.js            # AI prompt templates
│
├── iOS/
│   ├── KeyboardAI.xcodeproj/         # Xcode project (must be created in Xcode)
│   └── KeyboardAI/
│       ├── Shared/                   # Shared between app & extension
│       │   ├── Configuration.swift   # App config, constants, API URLs
│       │   ├── KeychainManager.swift # Secure token storage
│       │   ├── NetworkManager.swift  # HTTP client with auth
│       │   ├── AuthManager.swift     # Device auth & token management
│       │   ├── UsageTracker.swift    # Daily usage tracking
│       │   └── AIService.swift       # AI action methods
│       │
│       ├── App/                      # Main app target
│       │   ├── KeyboardAIApp.swift   # App entry point
│       │   ├── Theme.swift           # Colors, fonts, styles
│       │   ├── Info.plist
│       │   ├── Assets.xcassets/
│       │   └── Views/
│       │       ├── OnboardingView.swift
│       │       ├── MainView.swift
│       │       ├── SettingsView.swift
│       │       └── ProUpgradeView.swift
│       │
│       └── KeyboardExtension/        # Keyboard extension target
│           ├── KeyboardViewController.swift
│           ├── KeyboardViewModel.swift
│           ├── Info.plist
│           └── Views/
│               ├── KeyboardMainView.swift
│               ├── AIActionBar.swift
│               ├── SuggestionChipsBar.swift
│               ├── AIReplyBar.swift
│               ├── LanguagePickerOverlay.swift
│               ├── KeyButton.swift
│               ├── LetterKeyboard.swift
│               ├── NumberKeyboard.swift
│               └── SymbolKeyboard.swift
│
└── README.md
```

---

## 🚀 Quick Start

### 1. Backend Setup

```bash
cd backend
npm install
```

Create `.env` from `.env.example` and fill in your API keys:

```env
DEEPL_API_KEY=your_deepl_key
XAI_API_KEY=your_xai_key
JWT_SECRET=your_random_64_char_secret
```

Start the server:

```bash
npm start        # Production
npm run dev      # Development (auto-reload)
```

The API runs on `http://localhost:3000`.

### 2. iOS Project Setup

> **Requires Xcode 15+ and macOS Sonoma+**

#### Create the Xcode Project:

1. Open Xcode → **File → New → Project → App**
2. Product Name: `KeyboardAI`
3. Bundle Identifier: `com.keyboardai.app`
4. Interface: **SwiftUI**, Language: **Swift**
5. Deployment Target: **iOS 17.0**

#### Add the Keyboard Extension Target:

1. **File → New → Target → Custom Keyboard Extension**
2. Product Name: `KeyboardExtension`
3. Bundle ID will auto-set to `com.keyboardai.app.KeyboardExtension`
   - Change it to: `com.keyboardai.app.keyboard`

#### Configure App Groups:

1. Select the **KeyboardAI** target → **Signing & Capabilities**
2. Click **+ Capability → App Groups**
3. Add: `group.com.keyboardai.app`
4. **Repeat for the KeyboardExtension target**

#### Add Source Files:

1. Delete the auto-generated files from both targets
2. Drag the `Shared/` folder into Xcode → **Check BOTH targets** in membership
3. Drag the `App/` folder → **Check only KeyboardAI target**
4. Drag the `KeyboardExtension/` folder → **Check only KeyboardExtension target**

#### Update Backend URL:

In `Shared/Configuration.swift`, update:
```swift
static let apiBaseURL = "https://your-deployed-backend.com/api"
```

#### Build & Run:

1. Select the **KeyboardAI** scheme → Run on device/simulator
2. Go to **Settings → General → Keyboard → Keyboards → Add New Keyboard**
3. Select **KeyboardAI**
4. Enable **Allow Full Access**

---

## 🔒 Security Architecture

### API Key Protection
- **API keys are ONLY on the backend** — never in the iOS app
- The iOS app communicates with your backend, which proxies requests to DeepL and xAI
- All keys are loaded from environment variables

### Authentication Flow
1. App generates a unique device ID (UUID stored in Keychain)
2. Device registers with backend → receives JWT token
3. All API requests include the JWT + device ID
4. Backend verifies token + device ID match before processing

### Rate Limiting (designed for 10,000+ users)
| Layer | Limit | Purpose |
|-------|-------|---------|
| Global | 1000 req/min | Server protection |
| Per-IP | 60 req/min | Abuse prevention |
| Free tier | 3 req/day per device | Monetization |
| Pro tier | 30 req/min per device | Fair usage |

### Additional Security
- Helmet.js for HTTP security headers
- 5KB request body limit
- Input sanitization (500 char max, alphanumeric device IDs)
- Bundle ID verification
- HTTPS enforced (disable ATS exceptions in production)

---

## ⚡ AI Features

### Translate
- **Primary**: DeepL API (highest quality machine translation)
- **Fallback**: xAI Grok (if DeepL fails)
- **Languages**: EN, TR, DE, FR, ES, IT, PT, RU, JA, KO, ZH, AR, NL, PL

### Improve (Rewrite)
- Makes text more natural, clear, and fluent
- Preserves meaning and length

### Grammar Fix
- Fixes only grammar, spelling, and punctuation
- Does NOT change meaning or style

### Smart Reply
- Generates 3 reply options (casual, professional, friendly)
- Each under 15 words

### Quick Suggestions
- 5 contextual reply chips (2-4 words each)
- Mix of casual/professional with emojis

---

## 💰 Monetization

| Feature | Free | Pro |
|---------|------|-----|
| AI Actions/day | 3 | Unlimited |
| All languages | ✅ | ✅ |
| Smart replies | ✅ | ✅ |
| Priority speed | ❌ | ✅ |
| Price | Free | $2.99/week or $7.99/month |

### StoreKit Integration
The `ProUpgradeView.swift` includes the UI. For production:
1. Configure products in App Store Connect
2. Replace the simulated purchase flow with StoreKit 2
3. Add server-side receipt validation in `backend/src/routes/auth.js`

---

## ⚡ Performance Optimizations

1. **Response caching** — Server-side LRU cache (10K entries, 1hr TTL)
2. **Session caching** — Client-side cache in keyboard session
3. **Minimal tokens** — Prompts optimized for <20 word responses
4. **Max tokens capped** — 100-200 tokens per request
5. **Connection reuse** — URLSession with connection keep-alive
6. **Lazy loading** — Suggestions loaded asynchronously
7. **Input limits** — 500 chars max to prevent excessive API usage

---

## 🔐 Privacy

- Text is **only sent to AI** when the user taps an action button
- **No text is permanently stored** on the server
- Responses are cached temporarily (1 hour) for performance only
- All communication is encrypted via **HTTPS**
- No analytics or tracking
- Clear privacy explanation in app Settings

---

## 🚢 Deployment

### Backend
Recommended: **Railway**, **Render**, **Fly.io**, or **AWS Lambda**

```bash
# Example with Railway
railway init
railway up
```

### iOS
1. Configure signing in Xcode
2. Archive → Upload to App Store Connect
3. Submit for review

### Pre-launch Checklist
- [ ] Update `Configuration.apiBaseURL` to production backend URL
- [ ] Set strong `JWT_SECRET` (64+ random chars)
- [ ] Configure StoreKit products in App Store Connect
- [ ] Add server-side receipt validation
- [ ] Enable HTTPS on backend
- [ ] Test on physical device
- [ ] Test with "Allow Full Access" enabled
- [ ] Verify rate limits under load
- [ ] Add privacy policy URL
- [ ] Submit App Store screenshots

---

## 📄 License

MIT License. Build something amazing. ✨
