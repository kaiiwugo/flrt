# Dynamic Keyboard Height Implementation

## Overview
Implemented dynamic height adjustment for the keyboard extension to improve UX:
- **Compact mode** in prompt/processing states (120pt)
- **Expanded mode** when showing results (380pt)
- Smooth animated transitions between heights

## Implementation Details

### Height Constants
```swift
private let compactHeight: CGFloat = 120   // Small height for prompt state
private let expandedHeight: CGFloat = 380  // Full height for output state
```

### Height Management Function
```swift
private func setKeyboardHeight(_ height: CGFloat, animated: Bool = true) {
    guard let constraint = heightConstraint else { return }
    
    if animated {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            constraint.constant = height
            self.view.layoutIfNeeded()
        })
    } else {
        constraint.constant = height
        self.view.layoutIfNeeded()
    }
}
```

### State-Based Height Changes
The keyboard automatically adjusts its height when transitioning between states:

1. **Prompt State** → 120pt (compact)
   - Shows minimal UI: "take a screen shot to analyze"
   - Reduces screen real estate usage
   - User-friendly waiting state

2. **Processing State** → 120pt (compact)
   - Shows: "processing"
   - Maintains compact size during brief processing

3. **Output State** → 380pt (expanded)
   - Full UI with scrollable content
   - Screenshot display
   - iMessage-style conversation bubbles
   - Toolbar with action buttons

## Benefits

### User Experience
- ✅ **Less intrusive** when idle
- ✅ **More screen space** for the app being used
- ✅ **Smooth transitions** with animations
- ✅ **Expanded view** when user needs to interact with results

### Technical
- Uses standard Auto Layout constraints
- Respects iOS keyboard height limits
- Smooth 0.3s animation with ease-in-out curve
- Memory efficient (reuses views)

## Visual Flow

```
┌─────────────────────────┐
│                         │
│  take a screen shot     │  ← Compact (120pt)
│     to analyze          │
│                         │
└─────────────────────────┘
           ↓ (screenshot detected)
┌─────────────────────────┐
│                         │
│     processing          │  ← Compact (120pt)
│                         │
└─────────────────────────┘
           ↓ (processing complete)
┌─────────────────────────┐
│  [Screenshot Image]     │
│                         │
│  What do you think?     │
│                         │
│    Response 1      →    │  ← Expanded (380pt)
│    Response 2      →    │
│    Response 3      →    │
│                         │
│ [ + ]  [flrt]  [ × ]   │
└─────────────────────────┘
```

## Customization

You can adjust the heights in `KeyboardViewController.swift`:

```swift
private let compactHeight: CGFloat = 120  // Adjust for smaller/larger
private let expandedHeight: CGFloat = 380 // Adjust based on content needs
```

### Recommended Ranges
- **Compact**: 100-150pt (iOS minimum ~100pt)
- **Expanded**: 300-450pt (depends on content)

## Animation Timing

Default: 0.3 seconds with ease-in-out curve

To adjust:
```swift
UIView.animate(withDuration: 0.3, // Change duration
               delay: 0, 
               options: [.curveEaseInOut]) // Change curve
```

## Notes
- iOS keyboard extensions have minimum height constraints
- Heights below ~100pt may be clamped by the system
- Animated transitions provide better UX than instant changes
- Height is managed through a single NSLayoutConstraint for efficiency

