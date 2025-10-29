# Flrt - AI-Powered iOS Keyboard

An iOS keyboard extension that processes screenshots using AI, providing intelligent responses directly within your keyboard.

## Features

### 🎯 Current Implementation (v3)
- **Custom Keyboard Extension** with automatic photo library access
- **AI-Powered Analysis**: OpenAI GPT-4 Vision integration for intelligent screenshot analysis
- **Auto-Detection**: Automatically detects when you take a screenshot
- **Dynamic Height**: 
  - **Compact mode** (120pt) when waiting - minimal screen space
  - **Expanded mode** (380pt) when showing results - full interactive UI
- **iMessage-Style UI**: Familiar conversation interface with response bubbles
- **Three-State Flow**:
  - **Prompt View**: "take a screen shot to analyze"
  - **Processing View**: "processing" with AI analysis
  - **Output View**: Scrollable results with screenshot and AI suggestions
- **Smart Screenshot Cropping**: Automatically removes keyboard area from screenshots
- **Seamless Communication**: App Groups enable data sharing between keyboard and main app
- **Non-Intrusive**: Smooth animated transitions, keyboard stays open

### 🚀 Coming Soon
- Custom prompt templates
- Response history
- Multiple AI model support (Claude, Gemini)
- Contextual awareness

## How It Works

1. **Grant Photo Access**: Open the main app and grant photo library access
2. **Open Keyboard**: Switch to the Flrt keyboard in any app
3. **Take a Screenshot**: Use standard iOS screenshot (Side + Volume button)
4. **Auto-Detection**: Keyboard automatically detects the new screenshot
5. **AI Processing**: GPT-4 Vision analyzes the screenshot in the background
6. **Smart Display**: Keyboard expands to show cropped screenshot + AI suggestions
7. **Interactive Results**: Three response bubbles in iMessage style
8. **Continue**: Tap × to analyze another screenshot or keep typing

## Architecture

### Main App
- Monitors for screenshot notifications
- AI processing with OpenAI GPT-4 Vision
- Response formatting and parsing
- Built with SwiftUI

### Keyboard Extension
- UIKit-based custom keyboard
- Photo library observer for auto-detection
- State machine architecture with dynamic height
- iMessage-style conversation UI with scrolling
- Smart screenshot cropping
- Dynamic height: 120pt (compact) → 380pt (expanded)

### Communication
- **App Groups**: `group.com.flrt.shared`
- **Shared Container**: Images stored temporarily
- **UserDefaults**: Response data passed back to keyboard
- **Polling**: Keyboard checks for responses every 0.5 seconds

## Project Structure

```
flrt/
├── flrt/                          # Main iOS App
│   ├── flrtApp.swift             # App entry point
│   ├── ContentView.swift         # Main UI with photo permissions & AI integration
│   ├── PhotoLibraryManager.swift # Photo library access
│   ├── SharedDataManager.swift   # Communication layer
│   ├── Models/
│   │   └── AIModels.swift       # Data models for AI requests/responses
│   ├── Services/
│   │   ├── AIService.swift      # AI service protocol
│   │   ├── OpenAIService.swift  # OpenAI GPT-4 Vision implementation
│   │   └── ResponseParser.swift # Parse AI responses
│   ├── Config/
│   │   └── APIConfiguration.swift # API key management
│   ├── Networking/
│   │   └── NetworkManager.swift # HTTP request handling
│   ├── flrt.entitlements        # App Groups config
│   └── Info.plist               # App configuration & API keys
│
└── flirtKeyboard/                # Keyboard Extension
    ├── KeyboardViewController.swift  # Main keyboard logic with dynamic height
    ├── PhotoLibraryManager.swift     # Photo library access & auto-detection
    ├── SharedDataManager.swift       # Communication layer
    ├── flirtKeyboard.entitlements   # App Groups config
    └── Info.plist                   # Extension config & permissions
```

## Setup

### Requirements
- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/kaiiwugo/flrt.git
cd flrt
```

2. Add your OpenAI API key:
   - Open `flrt/Info.plist`
   - Find `OPENAI_API_KEY`
   - Replace `YOUR_API_KEY_HERE` with your actual OpenAI API key
   - Get a key at: https://platform.openai.com/api-keys

3. Open in Xcode:
```bash
open flrt.xcodeproj
```

4. Build and run on device (keyboard extensions require a physical device)

5. Enable the keyboard:
   - Settings → General → Keyboard → Keyboards
   - Add New Keyboard → Flrt
   - Enable "Allow Full Access" (required for App Groups and Photo Library)

6. Grant photo library access:
   - Open the Flrt app
   - Tap "Grant Photo Access" button
   - Select "Allow Access to All Photos" or "Select Photos"

## Current Status

✅ **Completed**:
- App Groups communication setup
- Photo library integration with auto-detection
- OpenAI GPT-4 Vision integration
- Three-state UI architecture
- iMessage-style conversation interface
- Dynamic keyboard height (compact ↔ expanded)
- Smart screenshot cropping
- Photo permissions management
- AI response parsing and formatting
- Error handling and fallback responses

🚧 **In Progress**:
- Enhanced AI prompts
- Response history
- Multi-model support

## Development Notes

### Key Implementation Details

**Dynamic Height**: 
- Compact mode: 120pt (prompt & processing)
- Expanded mode: 380pt (output with full UI)
- Smooth 0.3s animated transitions

**Auto-Detection**: 
- Main app: `UIApplication.userDidTakeScreenshotNotification`
- Keyboard: `PHPhotoLibraryChangeObserver` for photo library changes

**AI Integration**:
- OpenAI GPT-4 Vision API
- Modular architecture with protocol-based services
- JSON response parsing into structured suggestions
- Fallback responses for errors

**State Management**: Clean enum-based state machine:
```swift
enum KeyboardState {
    case prompt      // Compact, awaiting screenshot
    case processing  // Compact, AI analyzing
    case output      // Expanded, showing results
}
```

**Screenshot Filtering**: Uses `PHAssetMediaSubtype.photoScreenshot` to fetch only screenshots, not regular photos

**Smart Cropping**: Automatically removes bottom 42% of screenshot (keyboard area)

**Why No Auto-Open App**: Using `extensionContext?.open()` would dismiss the keyboard. Instead, the main app monitors in the background.

## Contributing

Contributions welcome! This is an early-stage project with lots of room for improvement.

## License

TBD

## Author

Built by [@kaiiwugo](https://github.com/kaiiwugo)

---

**Note**: This is a work in progress. The current implementation demonstrates the core communication flow between keyboard and app. LLM integration coming soon!

