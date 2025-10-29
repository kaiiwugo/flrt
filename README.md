# Flrt - AI-Powered iOS Keyboard

An iOS keyboard extension that processes screenshots using AI, providing intelligent responses directly within your keyboard.

## Features

### 🎯 Current Implementation (v2)
- **Custom Keyboard Extension** with automatic photo library access
- **Three-State UI Flow**:
  - **Prompt View**: Fetch latest screenshot with a single tap
  - **Loading View**: Visual feedback while processing
  - **Output View**: Display results with option to process another
- **Seamless Communication**: App Groups enable data sharing between keyboard and main app
- **Photo Library Integration**: Automatically fetches the most recent screenshot
- **Non-Intrusive**: Keyboard stays open throughout the entire flow

### 🚀 Coming Soon
- LLM integration for intelligent image analysis
- Custom prompt templates
- Response history
- Multiple AI model support

## How It Works

1. **Grant Photo Access**: Open the main app and grant photo library access
2. **Take a Screenshot**: Use standard iOS screenshot (Side + Volume button)
3. **Open Keyboard**: Switch to the Flrt keyboard in any app
4. **Fetch Screenshot**: Tap the "Fetch Latest Screenshot" button
5. **Processing**: The main app processes the image in the background
6. **Results**: Response appears directly in the keyboard
7. **Continue**: Process another screenshot or keep typing

## Architecture

### Main App
- Monitors shared container for new screenshots
- Processes images and returns responses
- Built with SwiftUI

### Keyboard Extension
- UIKit-based custom keyboard
- Photo library integration for automatic screenshot fetching
- State machine architecture for clean UI transitions
- Screenshot preview thumbnail
- Height matches standard iOS keyboard (~300pt)

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
│   ├── ContentView.swift         # Main UI with photo permissions
│   ├── PhotoLibraryManager.swift # Photo library access
│   ├── SharedDataManager.swift   # Communication layer
│   ├── flrt.entitlements        # App Groups config
│   └── Info.plist               # App configuration & permissions
│
└── flirtKeyboard/                # Keyboard Extension
    ├── KeyboardViewController.swift  # Main keyboard logic
    ├── PhotoLibraryManager.swift     # Photo library access
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

2. Open in Xcode:
```bash
open flrt.xcodeproj
```

3. Build and run on device (keyboard extensions require a physical device)

4. Enable the keyboard:
   - Settings → General → Keyboard → Keyboards
   - Add New Keyboard → Flrt
   - Enable "Allow Full Access" (required for App Groups and Photo Library)

5. Grant photo library access:
   - Open the Flrt app
   - Tap "Grant Photo Access" button
   - Select "Allow Access to All Photos" or "Select Photos"

## Current Status

✅ **Completed**:
- App Groups communication setup
- Photo library integration
- Automatic screenshot fetching
- Three-state UI architecture with preview
- Photo permissions management
- Image transfer and processing
- Keyboard stays open during processing

🚧 **In Progress**:
- LLM integration for intelligent responses
- Enhanced UI/UX
- Additional features

## Development Notes

### Key Implementation Details

**Keyboard Height**: Set to 300pt to accommodate screenshot preview and buttons

**Photo Library Access**: Uses Photos framework to fetch the most recent screenshot automatically

**State Management**: Clean enum-based state machine:
```swift
enum KeyboardState {
    case prompt      // Awaiting screenshot fetch
    case processing  // Working on it
    case output      // Showing results
}
```

**Screenshot Filtering**: Uses `PHAssetMediaSubtype.photoScreenshot` to fetch only screenshots, not regular photos

**Why No Auto-Open App**: Using `extensionContext?.open()` would dismiss the keyboard. Instead, the main app monitors in the background.

## Contributing

Contributions welcome! This is an early-stage project with lots of room for improvement.

## License

TBD

## Author

Built by [@kaiiwugo](https://github.com/kaiiwugo)

---

**Note**: This is a work in progress. The current implementation demonstrates the core communication flow between keyboard and app. LLM integration coming soon!

