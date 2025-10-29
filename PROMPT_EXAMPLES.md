# Prompt Examples

Real examples of how different configurations affect the prompts sent to the AI.

---

## Example 1: Respectful 30-Year-Old Male

### Configuration
```swift
PromptConfiguration(
    flirtLevel: .respectful,
    userAge: 30,
    userGender: .male,
    targetGender: .female
)
```

### Generated User Prompt
```
Analyze the provided screenshot and generate three response options.

User Context:
- Age: 30
- Gender: male
- Conversation with: female
- Desired tone: Respectful - polite, friendly, and considerate with subtle interest

Tone Guidance:
Keep responses warm and engaging while maintaining clear boundaries. Show interest 
through thoughtful questions and genuine compliments.

Instructions:
1. Analyze the screenshot carefully using your vision capabilities
2. Understand the context, vibe, and any visual or textual cues
3. Generate three distinct response options that:
   - Match the Respectful tone
   - Feel natural for a 30-year-old male
   - Offer different approaches (e.g., playful, thoughtful, bold)
   - Are ready to copy and send
```

### Expected Response Style
- Polite and genuine
- Thoughtful questions
- Subtle compliments
- Professional but warm

**Example Outputs:**
1. "That's really interesting! What got you into photography in the first place?"
2. "I love your perspective on that. Have you always been passionate about travel?"
3. "You seem to have great taste in music. What concert would you recommend I check out?"

---

## Example 2: Flirty 25-Year-Old Female

### Configuration
```swift
PromptConfiguration(
    flirtLevel: .flirty,
    userAge: 25,
    userGender: .female,
    targetGender: .male
)
```

### Generated User Prompt
```
Analyze the provided screenshot and generate three response options.

User Context:
- Age: 25
- Gender: female
- Conversation with: male
- Desired tone: Flirty - playful, charming, and confidently flirtatious

Tone Guidance:
Balance playfulness with charm. Use light teasing, playful banter, and subtle 
compliments that show confidence and interest.

Instructions:
1. Analyze the screenshot carefully using your vision capabilities
2. Understand the context, vibe, and any visual or textual cues
3. Generate three distinct response options that:
   - Match the Flirty tone
   - Feel natural for a 25-year-old female
   - Offer different approaches (e.g., playful, thoughtful, bold)
   - Are ready to copy and send
```

### Expected Response Style
- Playful and confident
- Light teasing
- Charming compliments
- Fun and engaging

**Example Outputs:**
1. "Okay but when are you taking me on this adventure you keep talking about 😏"
2. "You're either really funny or really dangerous, I can't tell which yet"
3. "I'm starting to think you're all talk... prove me wrong"

---

## Example 3: Bold 22-Year-Old Non-Binary

### Configuration
```swift
PromptConfiguration(
    flirtLevel: .bold,
    userAge: 22,
    userGender: .nonBinary,
    targetGender: nil
)
```

### Generated User Prompt
```
Analyze the provided screenshot and generate three response options.

User Context:
- Age: 22
- Gender: non-binary
- Conversation with: someone
- Desired tone: Bold - direct, daring, and unapologetically confident

Tone Guidance:
Be direct and confident. Show clear interest, use more forward language, and 
don't shy away from playful innuendo when contextually appropriate.

Instructions:
1. Analyze the screenshot carefully using your vision capabilities
2. Understand the context, vibe, and any visual or textual cues
3. Generate three distinct response options that:
   - Match the Bold tone
   - Feel natural for a 22-year-old non-binary
   - Offer different approaches (e.g., playful, thoughtful, bold)
   - Are ready to copy and send
```

### Expected Response Style
- Direct and confident
- Forward language
- Clear interest shown
- Playful innuendo when appropriate

**Example Outputs:**
1. "Stop being cute, it's distracting and I have things to do today"
2. "Come over. We can figure out the rest later"
3. "You talk a lot for someone who could just kiss me instead"

---

## Comparison: Same Screenshot, Different Settings

### Scenario: Screenshot of a Dating Profile
*Profile shows someone at a coffee shop with a book*

#### Respectful (30M → F)
1. "I noticed you're reading Murakami! What's your favorite of his works?"
2. "That coffee shop looks really cozy. Do you have a favorite spot for reading?"
3. "You seem to have great taste in books and cafes. Any recommendations?"

#### Flirty (25F → M)
1. "A guy who reads Murakami? Okay I'm intrigued 📚"
2. "That looks like the perfect date spot tbh, just saying"
3. "Coffee, books, and good vibes? We should test that combination sometime"

#### Bold (22NB → Any)
1. "That coffee shop better have good wifi because I'm sliding into those DMs all night"
2. "Murakami huh? I bet you're wild in the most unexpected ways"
3. "Let's skip the small talk and meet at that coffee shop this weekend"

---

## Age Differences

### Same Flirt Level (Flirty), Different Ages

#### Age: 22
"Bet you can't make me laugh as hard as this meme just did"
"Wanna see if we vibe as much in person as we do here?"
"This energy >>> anything else I've seen today"

#### Age: 30
"I have to say, your sense of humor is really refreshing"
"I'd love to continue this conversation over coffee sometime"
"You seem like someone who'd be fun to get to know better"

#### Age: 45
"Your profile caught my attention for all the right reasons"
"I appreciate someone who can hold an interesting conversation like this"
"I'd enjoy learning more about your perspective on this"

---

## Gender-Specific Nuances

### Bold Flirtation Across Genders

#### Male → Female
"That smile could definitely get me in trouble"
"I'm trying to play it cool but you're making it really difficult"
"When can I take you somewhere as beautiful as you are?"

#### Female → Male
"You're either trouble or exactly what I need, can't decide yet"
"Stop being hot and saying smart things, it's unfair"
"I don't usually do this but you should definitely text me"

#### Non-binary → Any
"Your vibe is absolutely immaculate and I'm here for it"
"Everything about this conversation feels right and I'm not questioning it"
"You're exactly the kind of chaos I want in my life"

---

## Context-Specific Examples

### First Message (Profile Analysis)

**Screenshot:** Tinder profile with hiking photos

**Respectful:**
1. "Your hiking photos are amazing! What's been your favorite trail so far?"
2. "I love that you're adventurous. Do you have any trips planned?"
3. "Those views are stunning. Where was that last photo taken?"

**Flirty:**
1. "Okay but who's taking you on these adventures, and how do I apply? 🏔️"
2. "You're either a professional hiker or really good at making it look easy"
3. "I'm not outdoorsy but I'd definitely follow you up a mountain"

**Bold:**
1. "Take me hiking and I'll take you to dinner. Deal?"
2. "Those mountains don't look half as impressive as you do climbing them"
3. "Less talking, more planning our first adventure together"

---

### Ongoing Conversation

**Screenshot:** Message thread about weekend plans

**Respectful:**
1. "That sounds like a great weekend! I'd love to hear how it goes"
2. "Those plans sound perfect. Mind if I join for part of it?"
3. "You always seem to have such interesting things going on"

**Flirty:**
1. "Your weekend sounds good but mine could be better if you're free 😏"
2. "Cancel one of those plans and hang out with me instead"
3. "All that and you didn't invite me? I'm wounded"

**Bold:**
1. "Change of plans. Spend the weekend with me"
2. "Those all sound boring compared to what we could be doing together"
3. "I'm free all weekend and you should be too. Let's go"

---

## What Makes Each Level Different?

### Respectful
- ✅ Questions over statements
- ✅ Genuine interest
- ✅ Clear boundaries
- ❌ No assumptions
- ❌ No innuendo
- ❌ No pressure

### Flirty
- ✅ Playful teasing
- ✅ Subtle compliments
- ✅ Confident but not pushy
- ✅ Light emoji use
- ⚠️ Some assumptions okay
- ❌ No explicit content

### Bold
- ✅ Direct statements
- ✅ Clear intentions
- ✅ Forward language
- ✅ Playful innuendo
- ✅ Confident assumptions
- ⚠️ Push boundaries (tastefully)

---

## Testing Your Prompts

### Quick Checklist

For each response generated, ask:

1. **Age-appropriate?** Does it sound like someone of this age would say it?
2. **Gender-aware?** Does it respect gender dynamics?
3. **Tone-matched?** Does it align with the flirt level?
4. **Natural?** Could you copy and send this right now?
5. **Emoji count?** 0-1 per response?
6. **Length?** 1-3 sentences?
7. **Punctuation?** Minimal exclamation marks?

---

## Pro Tips

### Making Respectful More Engaging
- Focus on specific details from the screenshot
- Ask thoughtful, open-ended questions
- Show genuine curiosity
- Compliment actions/choices, not just appearance

### Making Flirty More Effective
- Use playful teasing, not mockery
- Confident, not cocky
- Show interest clearly but don't over-pursue
- Balance fun with genuine connection

### Making Bold Work
- Read the room - context matters
- Be direct but not crude
- Confidence is sexy, desperation is not
- Know when to dial it back

---

**Remember:** The best prompt is one that helps the user sound like themselves, just... better.

