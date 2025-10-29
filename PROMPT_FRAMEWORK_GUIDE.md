# Prompt Framework Guide

## Overview

The Flrt app uses a robust, expandable prompt framework that allows for dynamic AI responses based on user preferences. This framework is designed to grow over time with more variables, prompt templates, and customization options.

---

## Architecture

### Core Components

1. **PromptModels.swift** - Data structures for prompt customization
2. **UserPreferences.swift** - Manages user settings and configuration
3. **AIModels.swift** - Integration with AI request/response pipeline
4. **PromptTemplate** - Template system with variable injection

---

## Current Variables

### 1. Flirt Level
Controls the tone and directness of responses.

**Options:**
- `Respectful` - Polite, friendly, subtle interest
- `Flirty` - Playful, charming, confidently flirtatious
- `Bold` - Direct, daring, unapologetically confident

**Implementation:**
```swift
enum FlirtLevel: String, CaseIterable {
    case respectful = "Respectful"
    case flirty = "Flirty"
    case bold = "Bold"
}
```

### 2. User Age
Adjusts language, cultural references, and communication style.

**Type:** `Int`
**Default:** 25
**Range:** Typically 18-60+

### 3. User Gender
Helps personalize responses appropriately.

**Options:**
- `Male`
- `Female`
- `Non-binary`
- `Prefer not to say`

### 4. Target Gender (Optional)
Who the user is talking to.

**Type:** `Gender?` (optional)
**Default:** `nil`

---

## Prompt Template System

### System Prompt
The core instructions that define the AI's role and behavior.

**Key Features:**
- Defines AI as a dating conversation assistant
- Emphasizes GPT Vision capabilities
- Sets response guidelines (3 options, natural tone, minimal emojis)
- Establishes tone requirements

**Static** - Does not change based on user preferences.

### User Prompt Template
The specific instructions for each request with variable injection.

**Variables Injected:**
- `{AGE}` → User's age
- `{GENDER}` → User's gender
- `{TARGET_GENDER}` → Who they're talking to
- `{FLIRT_LEVEL}` → Flirtiness setting
- `{FLIRT_DESCRIPTION}` → Description of flirt level
- `{TONE_GUIDANCE}` → Specific guidance for the chosen tone

**Example Output:**
```
Analyze the provided screenshot and generate three response options.

User Context:
- Age: 25
- Gender: male
- Conversation with: female
- Desired tone: Flirty - playful, charming, and confidently flirtatious

Tone Guidance:
Balance playfulness with charm. Use light teasing, playful banter, 
and subtle compliments that show confidence and interest.
```

---

## Usage

### Setting User Preferences (Hardcoded - Current)

In `ContentView.swift`:
```swift
userPreferences.setDefaults(
    flirtLevel: .flirty,
    age: 25,
    gender: .male,
    targetGender: .female
)
```

### Creating AI Requests

The framework automatically injects preferences:
```swift
// Get current configuration
let config = userPreferences.currentConfiguration()

// Create request - prompts are built automatically
let request = AIRequest(
    image: screenshot,
    configuration: config
)

// Process
let response = try await AIServiceManager.shared.processImage(request)
```

### Manual Prompt Building (Advanced)

```swift
let config = PromptConfiguration(
    flirtLevel: .bold,
    userAge: 28,
    userGender: .female,
    targetGender: .male
)

let prompts = PromptTemplate.build(with: config)
print(prompts.system)  // System prompt
print(prompts.user)    // User prompt with variables injected
```

---

## Customization Examples

### Example 1: Respectful Tone
```swift
let config = PromptConfiguration(
    flirtLevel: .respectful,
    userAge: 30,
    userGender: .male,
    targetGender: .female
)
```

**Tone Guidance:**
> Keep responses warm and engaging while maintaining clear boundaries. 
> Show interest through thoughtful questions and genuine compliments.

### Example 2: Bold Approach
```swift
let config = PromptConfiguration(
    flirtLevel: .bold,
    userAge: 24,
    userGender: .female,
    targetGender: .male
)
```

**Tone Guidance:**
> Be direct and confident. Show clear interest, use more forward language, 
> and don't shy away from playful innuendo when contextually appropriate.

### Example 3: Non-binary User
```swift
let config = PromptConfiguration(
    flirtLevel: .flirty,
    userAge: 26,
    userGender: .nonBinary,
    targetGender: nil  // Talking to anyone
)
```

---

## Future Expansion

The framework is designed to easily add more variables:

### Potential Variables (Not Yet Implemented)

#### Relationship Goal
```swift
enum RelationshipGoal {
    case casual
    case dating
    case relationship
    case friendship
    case networking
}
```

#### Communication Style
```swift
enum CommunicationStyle {
    case witty       // Clever and humorous
    case sincere     // Genuine and heartfelt
    case playful     // Fun and lighthearted
    case intellectual // Thoughtful and deep
}
```

#### Context Type
```swift
enum ContextType {
    case tinder
    case bumble
    case hinge
    case instagram
    case textMessage
    case other
}
```

#### Time of Day Awareness
```swift
struct TimeContext {
    let isNight: Bool
    let isWeekend: Bool
}
```

### Adding New Variables - Tutorial

1. **Add to PromptConfiguration:**
```swift
struct PromptConfiguration {
    let flirtLevel: FlirtLevel
    let userAge: Int
    let userGender: Gender
    let targetGender: Gender?
    let newVariable: YourNewType  // ← Add here
}
```

2. **Update PromptTemplate:**
```swift
private static func buildUserPromptTemplate() -> String {
    return """
    ...existing template...
    New Setting: {NEW_VARIABLE}
    """
}
```

3. **Add replacement in build():**
```swift
let customUserPrompt = template.userPromptTemplate
    // ...existing replacements...
    .replacingOccurrences(of: "{NEW_VARIABLE}", with: config.newVariable.description)
```

4. **Update UserPreferences:**
```swift
@Published var newVariable: YourNewType {
    didSet { saveNewVariable() }
}
```

---

## Prompt Best Practices

### What Makes a Good Prompt

✅ **DO:**
- Be specific about output format (JSON)
- Provide clear examples
- Set boundaries (emoji use, punctuation, length)
- Give context about the user
- Emphasize natural, authentic responses

❌ **DON'T:**
- Make prompts too long or complex
- Use vague instructions
- Forget to specify number of responses
- Leave output format ambiguous

### Response Quality Tips

1. **Specificity Wins**: The more context you give, the better the responses
2. **Examples Help**: Show the AI what good looks like
3. **Constraints Matter**: Limiting emoji/punctuation improves quality
4. **Age Awareness**: Younger users need different language than older
5. **Tone Consistency**: Clear tone guidance produces consistent results

---

## Testing Different Configurations

### Quick Test Script

```swift
let configs = [
    PromptConfiguration(flirtLevel: .respectful, userAge: 30, userGender: .male),
    PromptConfiguration(flirtLevel: .flirty, userAge: 25, userGender: .female),
    PromptConfiguration(flirtLevel: .bold, userAge: 22, userGender: .nonBinary)
]

for config in configs {
    let prompts = PromptTemplate.build(with: config)
    print("=== \(config.flirtLevel.rawValue) ===")
    print(prompts.user)
    print("\n")
}
```

---

## Response Format

### Expected JSON Output

```json
{
  "suggestions": [
    {
      "text": "First response option",
      "category": "playful"
    },
    {
      "text": "Second response option",
      "category": "thoughtful"
    },
    {
      "text": "Third response option",
      "category": "bold"
    }
  ],
  "context": "Brief analysis of what was noticed in the screenshot"
}
```

### Category Types

Responses are categorized by approach:
- `playful` - Fun, lighthearted
- `thoughtful` - Genuine, deeper
- `bold` - Direct, confident
- `witty` - Clever, humorous
- `casual` - Relaxed, friendly

---

## Debugging

### Viewing Current Configuration

```swift
print("📋 Current Config:")
print("   Flirt: \(userPreferences.flirtLevel.rawValue)")
print("   Age: \(userPreferences.userAge)")
print("   Gender: \(userPreferences.userGender.rawValue)")

let config = userPreferences.currentConfiguration()
let prompts = PromptTemplate.build(with: config)
print("\n📝 User Prompt:")
print(prompts.user)
```

### Testing Prompts Without API Calls

```swift
// Just build and inspect prompts
let config = PromptConfiguration(
    flirtLevel: .bold,
    userAge: 26,
    userGender: .female
)

let prompts = PromptTemplate.build(with: config)
// Copy and test in ChatGPT playground
```

---

## Migration Path

### Phase 1: Hardcoded Defaults ✅ (Current)
- Variables defined in code
- Easy testing and iteration

### Phase 2: User Settings UI (Next)
- Add settings screen
- Let users customize preferences
- Persist with UserDefaults

### Phase 3: Context-Aware (Future)
- Auto-detect app type from screenshot
- Smart defaults based on image analysis
- Learning from user feedback

### Phase 4: Advanced Personalization (Future)
- Multiple saved profiles
- Conversation history learning
- A/B testing different prompts
- Success rate tracking

---

## Files Reference

```
flrt/
├── Models/
│   ├── PromptModels.swift      # Prompt data structures
│   └── AIModels.swift          # AI request/response integration
├── Config/
│   ├── UserPreferences.swift   # User settings management
│   └── APIConfiguration.swift  # API keys
└── Services/
    ├── OpenAIService.swift     # Uses prompts for API calls
    └── ResponseParser.swift    # Parses AI responses
```

---

## Quick Reference

### Change Flirt Level
```swift
userPreferences.flirtLevel = .bold
```

### Change Age
```swift
userPreferences.userAge = 28
```

### Change Gender
```swift
userPreferences.userGender = .female
```

### Reset to Defaults
```swift
userPreferences.resetToDefaults()
```

---

## Contributing

When adding new prompt features:

1. Update `PromptModels.swift` with new enums/structs
2. Add variables to `PromptConfiguration`
3. Update `PromptTemplate.build()` with replacements
4. Add to `UserPreferences` for persistence
5. Document in this guide
6. Test with various configurations

---

**Last Updated:** v3.2 - Advanced Prompt Framework

