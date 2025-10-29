//
//  PromptModels.swift
//  flrt
//
//  Prompt configuration and customization models
//

import Foundation

// MARK: - Prompt Configuration

/// User preferences for response generation
struct PromptConfiguration {
    let flirtLevel: FlirtLevel
    let userAge: Int
    let userGender: Gender
    let targetGender: Gender?  // Optional: who they're talking to
    
    /// Initialize with default values for easy testing
    init(
        flirtLevel: FlirtLevel = .flirty,
        userAge: Int = 25,
        userGender: Gender = .male,
        targetGender: Gender? = .female
    ) {
        self.flirtLevel = flirtLevel
        self.userAge = userAge
        self.userGender = userGender
        self.targetGender = targetGender
    }
    
    /// Quick test configurations
    static let testRespectful = PromptConfiguration(flirtLevel: .respectful, userAge: 30, userGender: .male, targetGender: .female)
    static let testFlirty = PromptConfiguration(flirtLevel: .flirty, userAge: 25, userGender: .male, targetGender: .female)
    static let testBold = PromptConfiguration(flirtLevel: .bold, userAge: 22, userGender: .female, targetGender: .male)
}

// MARK: - Flirt Level

enum FlirtLevel: String, CaseIterable {
    case respectful = "Respectful"
    case flirty = "Flirty"
    case bold = "Bold"
    
    var description: String {
        switch self {
        case .respectful:
            return "polite, friendly, and considerate with subtle interest"
        case .flirty:
            return "playful, charming, and confidently flirtatious"
        case .bold:
            return "direct, daring, and unapologetically confident"
        }
    }
    
    var toneGuidance: String {
        switch self {
        case .respectful:
            return "Keep responses warm and engaging while maintaining clear boundaries. Show interest through thoughtful questions and genuine compliments."
        case .flirty:
            return "Balance playfulness with charm. Use light teasing, playful banter, and subtle compliments that show confidence and interest."
        case .bold:
            return "Be direct and confident. Show clear interest, use more forward language, and don't shy away from playful innuendo when contextually appropriate."
        }
    }
}

// MARK: - Gender

enum Gender: String, CaseIterable {
    case male = "Male"
    case female = "Female"
    case nonBinary = "Non-binary"
    case preferNotToSay = "Prefer not to say"
    
    var pronoun: String {
        switch self {
        case .male:
            return "he/him"
        case .female:
            return "she/her"
        case .nonBinary:
            return "they/them"
        case .preferNotToSay:
            return "they/them"
        }
    }
}

// MARK: - Conversation Context

enum ConversationType {
    case initialMessage      // First message to someone
    case ongoingConversation // Continuing an existing chat
    case profileAnalysis     // Analyzing a profile for openers
    case imageResponse       // Responding to a shared image
    
    var contextDescription: String {
        switch self {
        case .initialMessage:
            return "Generate conversation starters for initiating contact"
        case .ongoingConversation:
            return "Provide response suggestions for an ongoing conversation"
        case .profileAnalysis:
            return "Analyze the profile and suggest engaging openers"
        case .imageResponse:
            return "Craft responses related to the image content"
        }
    }
}

// MARK: - Prompt Template

struct PromptTemplate {
    let systemPrompt: String
    let userPromptTemplate: String
    
    static let `default` = PromptTemplate(
        systemPrompt: Self.buildSystemPrompt(),
        userPromptTemplate: Self.buildUserPromptTemplate()
    )
    
    private static func buildSystemPrompt() -> String {
        return """
        You are an expert dating conversation assistant. Your role is to analyze screenshots and messages to generate three engaging, authentic response options FOR THE USER to send.
        
        Core Capabilities:
        - Leverage your enhanced GPT Vision capabilities to analyze visual content, profiles, and conversation screenshots effectively
        - Distinguish between messages sent BY the user vs messages sent TO the user
        - Understand the full conversation context and flow from the user's perspective
        - Generate responses that naturally continue the user's side of the conversation
        
        Critical Analysis Steps:
        1. IDENTIFY MESSAGE OWNERSHIP:
           - Blue/right-aligned bubbles = Messages FROM the user (what they already sent)
           - Gray/left-aligned bubbles = Messages TO the user (what they received)
           - Green bubbles (iMessage) = Usually the user's messages
           - White/gray bubbles = Usually the other person's messages
        
        2. UNDERSTAND CONVERSATION FLOW:
           - What did the OTHER PERSON just say? (This is what you're responding to)
           - What has the USER already said? (This provides context for your response style)
           - What's the conversational momentum and energy?
           - Is this early conversation, mid-conversation, or deep conversation?
        
        3. ANALYZE CONTEXT:
           - Read the LAST message sent TO the user (this is what needs a response)
           - Consider what the user has already said (their voice, style, interests)
           - Note any questions asked, topics raised, or emotional tone
           - Identify opportunities to advance the conversation
        
        Response Guidelines:
        - Generate EXACTLY three distinct response options for the USER to send
        - ALL THREE responses must match the SAME tone level specified by the user
        - Each response should offer a different angle or approach WITHIN that tone
        - Vary the style: one question-based, one statement-based, one action-oriented
        - Responses should flow naturally from what the OTHER PERSON just said
        - Match the energy, pace, and style the user has already established
        - Use minimal to no emojis (only if/when natural)
        - Avoid excessive punctuation and hyphens
        - Keep responses concise and easy to send (1-3 sentences typically)
        
        Tone Requirements:
        - Casual and natural, like texting a friend
        - Age-appropriate language and cultural references
        - Confident but not arrogant
        - Engaging without being try-hard
        - CONSISTENT with the specified flirt level
        
        What to Avoid:
        - Generic or cliché responses
        - Ignoring what the other person just said
        - Responding to the user's OWN messages instead of the other person's
        - Overuse of emojis or punctuation (!!!, ..., etc.)
        - Formal or robotic language
        - Questions that feel like an interview
        - Responses that are too long or complex
        - Mixing different tone levels across the three responses
        
        Your goal is to help users respond in a way that's authentic to them, directly addresses what the other person said, and maximizes engagement and connection.
        """
    }
    
    private static func buildUserPromptTemplate() -> String {
        return """
        Analyze the provided screenshot and generate three response options FOR THE USER to send.
        
        User Context:
        - Age: {AGE}
        - Gender: {GENDER}
        - Conversation with: {TARGET_GENDER}
        - Desired tone: {FLIRT_LEVEL} - {FLIRT_DESCRIPTION}
        
        Tone Guidance:
        {TONE_GUIDANCE}
        
        Critical Analysis Required:
        
        STEP 1 - IDENTIFY WHO SAID WHAT:
        Look at the message bubbles in the screenshot:
        - Blue/right bubbles OR green iMessage bubbles = Messages the USER already sent
        - Gray/left bubbles OR white bubbles = Messages the OTHER PERSON sent
        
        STEP 2 - FIND THE LAST MESSAGE TO RESPOND TO:
        - What is the LAST message from the OTHER PERSON (gray/left/white bubble)?
        - This is what your response suggestions should directly address
        - Do NOT respond to the user's own messages (blue/right/green bubbles)
        
        STEP 3 - UNDERSTAND THE USER'S VOICE:
        - Review what the USER has already said in their messages
        - Match their texting style, length, and energy
        - Stay consistent with how they've been communicating
        
        STEP 4 - GENERATE RESPONSES:
        Create three distinct response options that:
        - Directly respond to what the OTHER PERSON just said
        - ALL match the {FLIRT_LEVEL} tone consistently
        - Feel natural for a {AGE}-year-old {GENDER}
        - Match the user's established communication style
        - Offer different angles WITHIN the same tone:
          * Option 1: Question-based approach
          * Option 2: Statement or observation
          * Option 3: Action or suggestion
        - Are ready to copy and send
        
        IMPORTANT REMINDERS:
        - You are responding FOR the user, TO the other person
        - Respond to what the OTHER PERSON (gray/left bubbles) just said
        - Do NOT respond to the user's own messages (blue/right bubbles)
        - All three responses MUST maintain the {FLIRT_LEVEL} tone
        - Do NOT vary between respectful, flirty, and bold - stick to the specified tone
        
        Output Format:
        Provide ONLY a JSON response with this exact structure:
        {
          "suggestions": [
            {
              "text": "First response option (question-based)",
              "category": "question"
            },
            {
              "text": "Second response option (statement)",
              "category": "statement"
            },
            {
              "text": "Third response option (action/suggestion)",
              "category": "action"
            }
          ],
          "context": "What the OTHER PERSON just said that you're responding to"
        }
        
        Remember: 
        - Analyze WHO sent WHAT message using visual cues
        - Respond to the OTHER PERSON's last message, not the user's
        - Be authentic, be engaging, stay consistent with the {FLIRT_LEVEL} tone
        - Match the user's established communication style
        """
    }
    
    /// Build a customized prompt with variable injection
    static func build(with config: PromptConfiguration) -> (system: String, user: String) {
        let template = PromptTemplate.default
        
        // Inject variables into user prompt
        let customUserPrompt = template.userPromptTemplate
            .replacingOccurrences(of: "{AGE}", with: "\(config.userAge)")
            .replacingOccurrences(of: "{GENDER}", with: config.userGender.rawValue.lowercased())
            .replacingOccurrences(of: "{TARGET_GENDER}", with: config.targetGender?.rawValue.lowercased() ?? "someone")
            .replacingOccurrences(of: "{FLIRT_LEVEL}", with: config.flirtLevel.rawValue)
            .replacingOccurrences(of: "{FLIRT_DESCRIPTION}", with: config.flirtLevel.description)
            .replacingOccurrences(of: "{TONE_GUIDANCE}", with: config.flirtLevel.toneGuidance)
        
        return (system: template.systemPrompt, user: customUserPrompt)
    }
}

