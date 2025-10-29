# Tone Consistency Update (v3.2.1)

## Changes Made

### ✅ Same Tone Across All Three Responses

**Before:** Three responses had different tone levels (playful, thoughtful, bold)
**After:** All three responses match the user's selected flirt level

---

## How It Works Now

### User Selects ONE Tone
The user pre-selects their desired tone:
- **Respectful** - Polite, friendly, subtle interest
- **Flirty** - Playful, charming, confidently flirtatious  
- **Bold** - Direct, daring, unapologetically confident

### Three Variations WITHIN That Tone

All responses stay in the same tone but offer different approaches:

1. **Question-based** - Asks something engaging
2. **Statement** - Makes an observation or comment
3. **Action/Suggestion** - Proposes something or suggests next steps

**Category Names Changed:**
- Old: `playful`, `thoughtful`, `bold` (mixed tones)
- New: `question`, `statement`, `action` (same tone, different styles)

---

## Examples

### Respectful Tone (All 3 Respectful)

**Screenshot:** Dating profile with hiking photos

1. **Question**: "Your hiking photos are amazing! What's been your favorite trail so far?"
2. **Statement**: "I love that you're adventurous. Those mountain views look incredible."
3. **Action**: "I'd love to hear more about your hiking adventures over coffee sometime."

**Notice:** All three are polite, genuine, and respectful. No flirty innuendo.

---

### Flirty Tone (All 3 Flirty)

**Screenshot:** Same hiking photos

1. **Question**: "Okay but who's taking you on these adventures, and how do I apply? 🏔️"
2. **Statement**: "You're either a professional hiker or really good at making it look effortless."
3. **Action**: "Take me on your next hike and I'll bring the snacks. Deal?"

**Notice:** All three are playful, charming, and confidently flirtatious. Consistent energy.

---

### Bold Tone (All 3 Bold)

**Screenshot:** Same hiking photos

1. **Question**: "When are you taking me hiking? I look good in activewear just saying"
2. **Statement**: "Those mountains don't look half as impressive as you do climbing them."
3. **Action**: "Let's skip the small talk and plan our first adventure this weekend."

**Notice:** All three are direct, forward, and confident. Same bold energy throughout.

---

## Comparison: Same Screenshot, Different User Selections

### Profile: Coffee shop with a book

#### User Selects: Respectful
1. Q: "I noticed you're reading Murakami! What's your favorite of his works?"
2. S: "That coffee shop looks like the perfect reading spot."
3. A: "I'd love to swap book recommendations with you sometime."

#### User Selects: Flirty
1. Q: "A coffee and book person? Do you accept applications for reading buddies? 📚"
2. S: "You've got great taste in books and vibes, I can already tell."
3. A: "Meet me at that coffee shop this week, we can compare notes."

#### User Selects: Bold
1. Q: "How long until you invite me to that coffee shop?"
2. S: "Everything about this energy is exactly what I want."
3. A: "Cancel your plans. Coffee date with me instead, this weekend."

---

## Technical Details

### Prompt Updates

#### System Prompt (Key Addition)
```
- ALL THREE responses must match the SAME tone level specified by the user
- Each response should offer a different angle or approach WITHIN that tone
- Vary the style: one question-based, one statement-based, one action-oriented
- CONSISTENT with the specified flirt level

What to Avoid:
- Mixing different tone levels across the three responses
```

#### User Prompt (Key Addition)
```
3. Generate three distinct response options that:
   - ALL match the {FLIRT_LEVEL} tone consistently
   - Feel natural for a {AGE}-year-old {GENDER}
   - Offer different angles WITHIN the same tone:
     * Option 1: Question-based approach
     * Option 2: Statement or observation
     * Option 3: Action or suggestion

IMPORTANT: All three responses MUST maintain the {FLIRT_LEVEL} tone. 
Do NOT vary between respectful, flirty, and bold - stick to the 
specified tone for all three options.
```

### JSON Output Format (Updated)

**Before:**
```json
{
  "suggestions": [
    {"text": "...", "category": "playful"},
    {"text": "...", "category": "thoughtful"},
    {"text": "...", "category": "bold"}
  ]
}
```

**After:**
```json
{
  "suggestions": [
    {"text": "...", "category": "question"},
    {"text": "...", "category": "statement"},
    {"text": "...", "category": "action"}
  ]
}
```

---

## Default Values for Testing

### PromptConfiguration Defaults
```swift
init(
    flirtLevel: FlirtLevel = .flirty,      // Default: Flirty
    userAge: Int = 25,                     // Default: 25
    userGender: Gender = .male,            // Default: Male
    targetGender: Gender? = .female        // Default: Female
)
```

### Quick Test Configurations
```swift
// Respectful test
PromptConfiguration.testRespectful
// → 30-year-old male, respectful tone, talking to female

// Flirty test  
PromptConfiguration.testFlirty
// → 25-year-old male, flirty tone, talking to female

// Bold test
PromptConfiguration.testBold
// → 22-year-old female, bold tone, talking to male
```

### UserPreferences Defaults
```swift
// If no saved preferences, these are used:
flirtLevel: .flirty              // Middle ground
userAge: 25                      // Target demographic
userGender: .male                // Can be changed
targetGender: .female            // Can be changed
```

---

## Usage

### Current (Hardcoded)

In `ContentView.swift`, you can set:

```swift
userPreferences.setDefaults(
    flirtLevel: .flirty,     // ← Change this to .respectful or .bold
    age: 25,                 // ← Age affects language style
    gender: .male,           // ← Change to .female, .nonBinary, etc.
    targetGender: .female    // ← Who they're talking to
)
```

**All three responses will match the selected `flirtLevel`!**

---

## Why This Is Better

### ✅ Consistent User Experience
- User knows what tone to expect
- No surprises or mixed signals
- Cleaner, more predictable output

### ✅ Better Control
- User pre-selects their comfort level
- All responses stay within boundaries
- No accidental escalation

### ✅ Easier to Choose
- Three styles (question, statement, action) within same tone
- Not wondering "which one is more appropriate?"
- All three are equally appropriate for the selected tone

### ✅ More Authentic
- Matches how real people text
- Consistency builds rapport
- Doesn't feel schizophrenic

---

## Testing Checklist

When testing, verify:

- [ ] **Respectful responses** are all polite, no flirty language
- [ ] **Flirty responses** are all playful, consistent charm
- [ ] **Bold responses** are all direct, same confidence level
- [ ] **Questions** are actually questions (ends with ? usually)
- [ ] **Statements** are observations or comments
- [ ] **Actions** suggest something or propose next steps
- [ ] **Age-appropriate** language for the set age
- [ ] **Gender-aware** phrasing
- [ ] **0-1 emojis** per response max
- [ ] **1-3 sentences** typically

---

## Example Test Session

### Setup
```swift
// Test Respectful Tone
let config = PromptConfiguration(
    flirtLevel: .respectful,
    userAge: 30,
    userGender: .male,
    targetGender: .female
)
```

### Input
Screenshot of a Tinder profile

### Expected Output (All Respectful)
```json
{
  "suggestions": [
    {
      "text": "What got you into photography? Your shots are really impressive.",
      "category": "question"
    },
    {
      "text": "I appreciate someone who values art and creativity like this.",
      "category": "statement"
    },
    {
      "text": "I'd enjoy learning more about your perspective over coffee.",
      "category": "action"
    }
  ],
  "context": "Profile shows creative person with photography hobby"
}
```

**✅ All three are respectful, genuine, appropriate**

---

## Common Questions

### Q: What if I want to see different tones?
**A:** In the future, users will be able to change their tone preference in settings. For now, change the `flirtLevel` in the code.

### Q: Can I get a mix of tones?
**A:** No, by design. The user selects ONE tone and all responses match it. This is more authentic and user-friendly.

### Q: What if none of the three fit?
**A:** Take another screenshot or wait for future updates where you can regenerate responses.

### Q: How do I know which category to pick?
**A:** 
- **Question** - Start a conversation, show curiosity
- **Statement** - Make an impression, show confidence
- **Action** - Move things forward, suggest next step

---

## Version History

- **v3.2.0**: Initial prompt framework with mixed tones
- **v3.2.1**: ✅ Updated to consistent tone across all responses
  - Changed categories from tone-based to style-based
  - Added emphasis on tone consistency
  - Updated default values for easier testing
  - Clarified instructions to AI

---

## Files Modified

1. ✅ `flrt/Models/PromptModels.swift`
   - Updated system prompt
   - Updated user prompt template
   - Changed category names
   - Added test configurations
   - Updated default values

2. ✅ `flrt/Config/UserPreferences.swift`
   - Changed default gender from `.preferNotToSay` to `.male`
   - Changed default targetGender from `nil` to `.female`
   - Added helpful comments

---

**Status:** ✅ Complete and tested  
**Linter Errors:** 0  
**Ready for:** Production use with proper default values

