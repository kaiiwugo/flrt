# Flrt - AI-Powered iOS Keyboard

An iOS keyboard extension that processes screenshots using AI, providing intelligent responses directly within your keyboard.

## Features

### 🎯 Current Implementation (v1)
- **Custom Keyboard Extension** with drag & drop screenshot support
- **Three-State UI Flow**:
  - **Prompt View**: Drag screenshots directly from iOS screenshot thumbnails
  - **Loading View**: Visual feedback while processing
  - **Output View**: Display results with option to process another
- **Seamless Communication**: App Groups enable data sharing between keyboard and main app
- **Non-Intrusive**: Keyboard stays open throughout the entire flow

### 🚀 Coming Soon
- LLM integration for intelligent image analysis
- Custom prompt templates
- Response history
- Multiple AI model support

## How It Works

1. **Take a Screenshot**: Use standard iOS screenshot (Side + Volume button)
2. **Drag & Drop**: Drag the thumbnail that appears into the keyboard's drop zone
3. **Processing**: The main app processes the image in the background
4. **Results**: Response appears directly in the keyboard
5. **Continue**: Process another screenshot or keep typing

## Architecture

### Main App
- Monitors shared container for new screenshots
- Processes images and returns responses
- Built with SwiftUI

### Keyboard Extension
- UIKit-based custom keyboard
- Implements `UIDropInteraction` for drag & drop
- State machine architecture for clean UI transitions
- Height matches standard iOS keyboard (~270pt)

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
│   ├── ContentView.swift         # Main UI with monitoring
│   ├── SharedDataManager.swift   # Communication layer
│   ├── flrt.entitlements        # App Groups config
│   └── Info.plist               # App configuration
│
└── flirtKeyboard/                # Keyboard Extension
    ├── KeyboardViewController.swift  # Main keyboard logic
    ├── SharedDataManager.swift       # Communication layer
    ├── flirtKeyboard.entitlements   # App Groups config
    └── Info.plist                   # Extension config
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
   - Enable "Allow Full Access" (required for App Groups)

## Current Status

✅ **Completed**:
- App Groups communication setup
- Keyboard extension with drag & drop
- Three-state UI architecture
- Image transfer and filename response
- Keyboard stays open during processing

🚧 **In Progress**:
- LLM integration for intelligent responses
- Enhanced UI/UX
- Additional features

## Development Notes

### Key Implementation Details

**Keyboard Height**: Set to 270pt to match standard iOS keyboard height

**State Management**: Clean enum-based state machine:
```swift
enum KeyboardState {
    case prompt      // Awaiting screenshot
    case processing  // Working on it
    case output      // Showing results
}
```

**Why No Auto-Open App**: Using `extensionContext?.open()` would dismiss the keyboard. Instead, the main app monitors in the background.

## Contributing

Contributions welcome! This is an early-stage project with lots of room for improvement.

## License

TBD

## Author

Built by [@kaiiwugo](https://github.com/kaiiwugo)

---

**Note**: This is a work in progress. The current implementation demonstrates the core communication flow between keyboard and app. LLM integration coming soon!

