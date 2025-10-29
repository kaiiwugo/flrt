# Changelog

All notable changes to the Flrt keyboard project.

## [v3.0] - 2025-10-29

### Added - Dynamic Keyboard Height
- **Compact Mode (120pt)**: Minimal footprint when waiting for screenshots
  - Shown during prompt state ("take a screen shot to analyze")
  - Shown during processing state ("processing")
  - Reduces screen real estate usage by ~68%
- **Expanded Mode (380pt)**: Full UI when showing results
  - Scrollable output view
  - Screenshot display with smart cropping
  - iMessage-style response bubbles
  - Interactive toolbar
- **Smooth Animations**: 0.3s ease-in-out transitions between heights
- **Better UX**: Less intrusive when idle, more space when needed

### Technical Details
- Added `compactHeight` and `expandedHeight` constants
- Implemented `setKeyboardHeight(_:animated:)` method
- Integrated height changes into state transitions
- Adjusted font sizes for better compact mode appearance

### Documentation
- Added `DYNAMIC_HEIGHT_IMPLEMENTATION.md` with technical details
- Updated README.md to reflect new v3 features
- Included visual flow diagram

---

## [v2.5] - 2025-10-29

### Added - AI Integration
- OpenAI GPT-4 Vision API integration
- Modular AI service architecture
- Response parsing and formatting
- Error handling with fallback responses
- API key management via Info.plist
- Enhanced debugging and logging

### Added - UI Redesign
- iMessage-style conversation interface
- Scrollable output view
- Custom toolbar with action buttons
- Smart screenshot cropping (removes keyboard area)
- Response bubbles for AI suggestions

### Added - Auto-Detection
- Screenshot auto-detection in main app
- Photo library observer in keyboard extension
- No manual "fetch" button needed

### Documentation
- `AI_FRAMEWORK_SUMMARY.md`
- `AI_SETUP_GUIDE.md`
- `API_KEY_INSTRUCTIONS.md`
- `FINAL_UI_IMPROVEMENTS.md`
- `AUTO_DETECTION_SUMMARY.md`

---

## [v2.0] - 2025-10-28

### Added - Photo Library Access
- Automatic photo library integration
- Photo permissions management
- Screenshot filtering
- App Groups communication

### Changed
- Removed drag & drop interface
- Three-state UI flow (prompt → processing → output)

### Documentation
- `IMPLEMENTATION_SUMMARY.md`

---

## [v1.0] - Initial Release

### Added
- Basic keyboard extension
- Drag & drop image support
- Simple UI

---

## Version Comparison

| Feature | v1.0 | v2.0 | v2.5 | v3.0 |
|---------|------|------|------|------|
| Image Input | Drag & Drop | Photo Library | Auto-Detect | Auto-Detect |
| AI Processing | ❌ | ❌ | ✅ GPT-4V | ✅ GPT-4V |
| UI Style | Basic | Simple | iMessage | iMessage |
| Keyboard Height | Fixed (300pt) | Fixed (300pt) | Fixed (300pt) | Dynamic (120-380pt) |
| Screenshot Cropping | ❌ | ❌ | ✅ | ✅ |
| Response Format | Text | Text | Bubbles | Bubbles |
| Animation | ❌ | ❌ | ❌ | ✅ Smooth |

---

## Upcoming

### v3.1 (Planned)
- Custom AI prompts
- Response history
- Improved error handling
- Settings panel in keyboard

### v4.0 (Future)
- Multi-model support (Claude, Gemini)
- Contextual awareness
- Response templates
- Offline mode

