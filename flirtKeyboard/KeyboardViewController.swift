//
//  KeyboardViewController.swift
//  flirtKeyboard
//
//  Created by Kaelin Iwugo on 10/28/25.
//

import UIKit
import Photos

class KeyboardViewController: UIInputViewController, PHPhotoLibraryChangeObserver {

    @IBOutlet var nextKeyboardButton: UIButton!
    
    // Keyboard State
    private enum KeyboardState {
        case prompt    // Waiting for user to fetch screenshot
        case processing // Processing screenshot
        case output    // Showing results
    }
    
    // Height Constants
    private let compactHeight: CGFloat = 120  // Small height for prompt state
    private let expandedHeight: CGFloat = 380 // Full height for output state
    
    private var currentState: KeyboardState = .prompt {
        didSet {
            transitionToState(currentState)
        }
    }
    
    // UI Container
    private var containerView: UIView!
    private var contentStackView: UIStackView!
    private var heightConstraint: NSLayoutConstraint?
    
    // Prompt View Elements
    private var promptView: UIView!
    private var promptLabel: UILabel!
    
    // Loading View Elements
    private var loadingView: UIView!
    private var loadingLabel: UILabel!
    
    // Output View Elements
    private var outputView: UIView!
    private var outputScrollView: UIScrollView!
    private var outputContentView: UIView!
    private var outputScreenshotView: UIImageView!
    private var incomingMessageBubble: UIView!
    private var incomingMessageLabel: UILabel!
    private var responseBubblesContainer: UIStackView!
    private var responseBubble1: UIView!
    private var responseBubble2: UIView!
    private var responseBubble3: UIView!
    private var responseLabel1: UILabel!
    private var responseLabel2: UILabel!
    private var responseLabel3: UILabel!
    private var toolbarView: UIView!
    private var plusButton: UIButton!
    private var flrtButton: UIButton!
    private var closeButton: UIButton!
    
    // State
    private var checkResponseTimer: Timer?
    private var currentResponse: String?
    private var currentScreenshot: UIImage?
    private var isObservingPhotoLibrary = false
    private var lastScreenshotCount = 0
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Set keyboard height based on current state
        if heightConstraint == nil {
            // Start with compact height
            heightConstraint = view.heightAnchor.constraint(equalToConstant: compactHeight)
            heightConstraint?.priority = .defaultHigh
            heightConstraint?.isActive = true
        }
    }
    
    // MARK: - Height Management
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔵 KeyboardViewController viewDidLoad")
        setupUI()
        currentState = .prompt
        startPhotoLibraryObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("🔴 KeyboardViewController viewWillDisappear")
        stopPhotoLibraryObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("🔴 KeyboardViewController viewDidDisappear")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Main container
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.systemBackground
        self.view.addSubview(containerView)
        
        // Content stack view to hold different state views
        contentStackView = UIStackView()
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 12
        contentStackView.distribution = .fill
        containerView.addSubview(contentStackView)
        
        // Setup all three view states
        setupPromptView()
        setupLoadingView()
        setupOutputView()
        
        // Next Keyboard Button (hidden by default, only shows if needed)
        self.nextKeyboardButton = UIButton(type: .system)
        self.nextKeyboardButton.setTitle("🌐", for: [])
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        self.nextKeyboardButton.isHidden = true  // Hide by default
        containerView.addSubview(self.nextKeyboardButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Next keyboard button (bottom-left when visible)
            nextKeyboardButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            nextKeyboardButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            nextKeyboardButton.widthAnchor.constraint(equalToConstant: 32),
            nextKeyboardButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupPromptView() {
        promptView = UIView()
        promptView.translatesAutoresizingMaskIntoConstraints = false
        
        // Prompt Label - centered
        promptLabel = UILabel()
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        promptLabel.text = "take a screen shot to analyze"
        promptLabel.textAlignment = .center
        promptLabel.numberOfLines = 0
        promptLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        promptLabel.textColor = UIColor.secondaryLabel
        promptView.addSubview(promptLabel)
        
        NSLayoutConstraint.activate([
            promptLabel.centerXAnchor.constraint(equalTo: promptView.centerXAnchor),
            promptLabel.centerYAnchor.constraint(equalTo: promptView.centerYAnchor),
            promptLabel.leadingAnchor.constraint(equalTo: promptView.leadingAnchor, constant: 16),
            promptLabel.trailingAnchor.constraint(equalTo: promptView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupLoadingView() {
        loadingView = UIView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        // Loading label only - simple and clean
        loadingLabel = UILabel()
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.text = "processing"
        loadingLabel.textAlignment = .center
        loadingLabel.numberOfLines = 1
        loadingLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        loadingLabel.textColor = UIColor.secondaryLabel
        loadingView.addSubview(loadingLabel)
        
        NSLayoutConstraint.activate([
            loadingLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            loadingLabel.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
        ])
    }
    
    private func setupOutputView() {
        outputView = UIView()
        outputView.translatesAutoresizingMaskIntoConstraints = false
        outputView.backgroundColor = UIColor.systemBackground
        
        // Scrollable content area
        outputScrollView = UIScrollView()
        outputScrollView.translatesAutoresizingMaskIntoConstraints = false
        outputScrollView.showsVerticalScrollIndicator = true
        outputScrollView.alwaysBounceVertical = true
        outputView.addSubview(outputScrollView)
        
        // Content container for scroll view
        outputContentView = UIView()
        outputContentView.translatesAutoresizingMaskIntoConstraints = false
        outputScrollView.addSubview(outputContentView)
        
        // Main vertical stack for messages
        let messagesStack = UIStackView()
        messagesStack.translatesAutoresizingMaskIntoConstraints = false
        messagesStack.axis = .vertical
        messagesStack.spacing = 8
        messagesStack.alignment = .fill
        outputContentView.addSubview(messagesStack)
        
        // Row 1: Screenshot (left-aligned, like incoming message)
        let screenshotRow = UIView()
        screenshotRow.translatesAutoresizingMaskIntoConstraints = false
        
        outputScreenshotView = UIImageView()
        outputScreenshotView.translatesAutoresizingMaskIntoConstraints = false
        outputScreenshotView.contentMode = .scaleAspectFit
        outputScreenshotView.layer.cornerRadius = 12
        outputScreenshotView.clipsToBounds = true
        outputScreenshotView.backgroundColor = UIColor.systemGray5
        screenshotRow.addSubview(outputScreenshotView)
        
        // Row 2: Incoming text message (left-aligned, gray bubble)
        let incomingRow = UIView()
        incomingRow.translatesAutoresizingMaskIntoConstraints = false
        
        let (incomingBubble, incomingLabel) = createIncomingBubble(text: "flrt options")
        incomingMessageBubble = incomingBubble
        incomingMessageLabel = incomingLabel
        incomingRow.addSubview(incomingBubble)
        
        // Rows 3-5: Response bubbles (right-aligned, blue)
        let response1Row = createResponseRow(text: "This is a sample response")
        let response2Row = createResponseRow(text: "Here's another suggestion")
        let response3Row = createResponseRow(text: "And a third option")
        
        // Store references to response bubbles
        responseBubble1 = response1Row.subviews.first!
        responseBubble2 = response2Row.subviews.first!
        responseBubble3 = response3Row.subviews.first!
        
        responseLabel1 = responseBubble1.subviews.first as? UILabel
        responseLabel2 = responseBubble2.subviews.first as? UILabel
        responseLabel3 = responseBubble3.subviews.first as? UILabel
        
        // Add all rows to stack
        messagesStack.addArrangedSubview(screenshotRow)
        messagesStack.addArrangedSubview(incomingRow)
        messagesStack.addArrangedSubview(response1Row)
        messagesStack.addArrangedSubview(response2Row)
        messagesStack.addArrangedSubview(response3Row)
        
        // Toolbar at bottom
        setupToolbar()
        outputView.addSubview(toolbarView)
        
        NSLayoutConstraint.activate([
            // Scroll view
            outputScrollView.topAnchor.constraint(equalTo: outputView.topAnchor),
            outputScrollView.leadingAnchor.constraint(equalTo: outputView.leadingAnchor),
            outputScrollView.trailingAnchor.constraint(equalTo: outputView.trailingAnchor),
            outputScrollView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor),
            
            // Content view
            outputContentView.topAnchor.constraint(equalTo: outputScrollView.topAnchor),
            outputContentView.leadingAnchor.constraint(equalTo: outputScrollView.leadingAnchor),
            outputContentView.trailingAnchor.constraint(equalTo: outputScrollView.trailingAnchor),
            outputContentView.bottomAnchor.constraint(equalTo: outputScrollView.bottomAnchor),
            outputContentView.widthAnchor.constraint(equalTo: outputScrollView.widthAnchor),
            
            // Messages stack
            messagesStack.topAnchor.constraint(equalTo: outputContentView.topAnchor, constant: 12),
            messagesStack.leadingAnchor.constraint(equalTo: outputContentView.leadingAnchor, constant: 12),
            messagesStack.trailingAnchor.constraint(equalTo: outputContentView.trailingAnchor, constant: -12),
            messagesStack.bottomAnchor.constraint(equalTo: outputContentView.bottomAnchor, constant: -12),
            
            // Screenshot row
            outputScreenshotView.leadingAnchor.constraint(equalTo: screenshotRow.leadingAnchor),
            outputScreenshotView.topAnchor.constraint(equalTo: screenshotRow.topAnchor),
            outputScreenshotView.bottomAnchor.constraint(equalTo: screenshotRow.bottomAnchor),
            outputScreenshotView.widthAnchor.constraint(equalToConstant: 120),
            outputScreenshotView.heightAnchor.constraint(equalToConstant: 160),
            
            // Incoming message row
            incomingBubble.leadingAnchor.constraint(equalTo: incomingRow.leadingAnchor),
            incomingBubble.topAnchor.constraint(equalTo: incomingRow.topAnchor),
            incomingBubble.bottomAnchor.constraint(equalTo: incomingRow.bottomAnchor),
            incomingBubble.widthAnchor.constraint(lessThanOrEqualToConstant: 240),
            
            // Toolbar
            toolbarView.leadingAnchor.constraint(equalTo: outputView.leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: outputView.trailingAnchor),
            toolbarView.bottomAnchor.constraint(equalTo: outputView.bottomAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupToolbar() {
        toolbarView = UIView()
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        // Match the system keyboard background color more accurately
        toolbarView.backgroundColor = UIColor(red: 0.85, green: 0.87, blue: 0.89, alpha: 1.0)
        
        // Plus button (left) - with circular background
        plusButton = UIButton(type: .system)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        plusButton.setTitleColor(UIColor.systemBlue, for: .normal)
        plusButton.backgroundColor = UIColor.white
        plusButton.layer.cornerRadius = 18
        plusButton.layer.shadowColor = UIColor.black.cgColor
        plusButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        plusButton.layer.shadowRadius = 2
        plusButton.layer.shadowOpacity = 0.1
        toolbarView.addSubview(plusButton)
        
        // Flrt button (center) - with rounded background
        flrtButton = UIButton(type: .system)
        flrtButton.translatesAutoresizingMaskIntoConstraints = false
        flrtButton.setTitle("flrt", for: .normal)
        flrtButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        flrtButton.setTitleColor(UIColor.white, for: .normal)
        flrtButton.backgroundColor = UIColor.systemBlue
        flrtButton.layer.cornerRadius = 16
        flrtButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        toolbarView.addSubview(flrtButton)
        
        // Close button (right) - with circular background
        closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        closeButton.setTitleColor(UIColor.secondaryLabel, for: .normal)
        closeButton.backgroundColor = UIColor.white
        closeButton.layer.cornerRadius = 18
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        closeButton.layer.shadowRadius = 2
        closeButton.layer.shadowOpacity = 0.1
        closeButton.addTarget(self, action: #selector(resetToPrompt), for: .touchUpInside)
        toolbarView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            plusButton.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 12),
            plusButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 36),
            plusButton.heightAnchor.constraint(equalToConstant: 36),
            
            flrtButton.centerXAnchor.constraint(equalTo: toolbarView.centerXAnchor),
            flrtButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            flrtButton.heightAnchor.constraint(equalToConstant: 32),
            
            closeButton.trailingAnchor.constraint(equalTo: toolbarView.trailingAnchor, constant: -12),
            closeButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    // MARK: - Bubble Creation Helpers
    
    private func createIncomingBubble(text: String) -> (UIView, UILabel) {
        let bubble = UIView()
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.backgroundColor = UIColor.systemGray5
        bubble.layer.cornerRadius = 18
        bubble.clipsToBounds = true
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = UIColor.label
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        bubble.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -14),
            label.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -10)
        ])
        
        return (bubble, label)
    }
    
    // MARK: - Response Handling
    
    private func updateBubblesWithResponse(_ response: String) {
        // Try to parse as JSON
        if let suggestions = parseJSONResponse(response) {
            // Update bubbles with parsed suggestions
            if suggestions.count > 0 {
                responseLabel1?.text = suggestions[0]
            }
            if suggestions.count > 1 {
                responseLabel2?.text = suggestions[1]
            }
            if suggestions.count > 2 {
                responseLabel3?.text = suggestions[2]
            }
            print("✅ Updated bubbles with AI suggestions")
        } else {
            // Fallback: try pipe-separated
            let suggestions = response.components(separatedBy: "|")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            if suggestions.count > 0 {
                responseLabel1?.text = suggestions[0]
            }
            if suggestions.count > 1 {
                responseLabel2?.text = suggestions[1]
            }
            if suggestions.count > 2 {
                responseLabel3?.text = suggestions[2]
            }
            print("✅ Updated bubbles with fallback parsing")
        }
        
        // Update incoming message bubble context if available
        // Keep the static "flrt options" text - don't update with context
        // The incoming bubble is just a visual separator, not a dynamic message
    }
    
    private func parseJSONResponse(_ jsonString: String) -> [String]? {
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let suggestions = json["suggestions"] as? [[String: Any]] else {
            return nil
        }
        
        return suggestions.compactMap { $0["text"] as? String }
    }
    
    private func createResponseRow(text: String) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        
        let bubble = UIView()
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.backgroundColor = UIColor.systemBlue
        bubble.layer.cornerRadius = 18
        bubble.clipsToBounds = true
        row.addSubview(bubble)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        bubble.addSubview(label)
        
        NSLayoutConstraint.activate([
            bubble.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            bubble.topAnchor.constraint(equalTo: row.topAnchor),
            bubble.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            bubble.widthAnchor.constraint(lessThanOrEqualToConstant: 240),
            
            label.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -14),
            label.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -10)
        ])
        
        return row
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if self.textDocumentProxy.documentContextBeforeInput != nil || self.textDocumentProxy.documentContextAfterInput != nil {
            self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateTheme()
    }
    
    // MARK: - State Management
    
    private func transitionToState(_ state: KeyboardState) {
        print("🔄 State transition to: \(state)")
        
        let strongSelf = self
        
        // Remove all views from stack
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add appropriate view based on state and adjust height
        switch state {
        case .prompt:
            print("   → Showing prompt view (compact)")
            contentStackView.addArrangedSubview(promptView)
            setKeyboardHeight(compactHeight, animated: true)
            // Ensure observer is running in prompt state
            startPhotoLibraryObserver()
            
        case .processing:
            print("   → Showing loading view (expanded)")
            contentStackView.addArrangedSubview(loadingView)
            setKeyboardHeight(expandedHeight, animated: true)
            // Stop observer during processing to avoid conflicts
            stopPhotoLibraryObserver()
            
        case .output:
            print("   → Showing output view (expanded)")
            contentStackView.addArrangedSubview(outputView)
            setKeyboardHeight(expandedHeight, animated: true)
            // Stop observer in output state
            stopPhotoLibraryObserver()
            
            // Set the screenshot in output view (cropped to remove keyboard)
            if let screenshot = currentScreenshot {
                let croppedScreenshot = cropKeyboardFromScreenshot(screenshot)
                outputScreenshotView.image = croppedScreenshot
                print("   → Screenshot set in output view (cropped)")
            }
            
            // Update bubble text with AI response
            if let response = currentResponse {
                print("   → Response received")
                updateBubblesWithResponse(response)
            }
        }
        
        updateTheme()
        strongSelf.view.layoutIfNeeded()
        
        print("✅ State transition complete, view count: \(contentStackView.arrangedSubviews.count)")
    }
    
    @objc private func resetToPrompt() {
        print("🔄 Reset to prompt requested")
        
        // Ensure we're on the main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { 
                print("❌ Self was deallocated in resetToPrompt")
                return 
            }
            
            // Clean up timers and state
            self.checkResponseTimer?.invalidate()
            self.checkResponseTimer = nil
            self.currentResponse = nil
            self.currentScreenshot = nil
            
            // Clear the screenshot from output view to free memory
            self.outputScreenshotView.image = nil
            
            // Reset prompt label
            self.promptLabel.text = "take a screen shot to analyze"
            self.promptLabel.textColor = UIColor.secondaryLabel
            
            // Transition back to prompt state
            self.currentState = .prompt
            
            // Restart photo library observer to watch for new screenshots
            self.startPhotoLibraryObserver()
            
            print("✅ Reset complete, ready for new screenshot")
        }
    }
    
    
    private func updateTheme() {
        let isDark = self.textDocumentProxy.keyboardAppearance == .dark
        
        // Container
        containerView.backgroundColor = isDark ? UIColor.systemGray6 : UIColor.systemBackground
        
        // Prompt and loading views use secondaryLabel (always gray)
        promptLabel.textColor = UIColor.secondaryLabel
        loadingLabel.textColor = UIColor.secondaryLabel
    }
    
    // MARK: - Screenshot Fetching
    
    @objc private func fetchScreenshotTapped() {
        print("📸 Fetch screenshot button tapped")
        
        // Check photo library authorization
        let status = PhotoLibraryManager.shared.checkAuthorizationStatus()
        
        switch status {
        case .notDetermined:
            print("📸 Requesting photo library authorization...")
            PhotoLibraryManager.shared.requestAuthorization { [weak self] newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self?.fetchAndProcessScreenshot()
                    } else {
                        self?.showPermissionDeniedAlert()
                    }
                }
            }
            
        case .authorized, .limited:
            fetchAndProcessScreenshot()
            
        case .denied, .restricted:
            showPermissionDeniedAlert()
            
        @unknown default:
            print("❌ Unknown authorization status")
            showPermissionDeniedAlert()
        }
    }
    
    private func fetchAndProcessScreenshot() {
        print("📸 Fetching latest screenshot from photo library...")
        
        // Fetch the latest screenshot
        guard let screenshot = PhotoLibraryManager.shared.fetchLatestScreenshot() else {
            print("❌ No screenshot found in photo library")
            showNoScreenshotAlert()
            return
        }
        
        print("✅ Screenshot fetched successfully")
        
        // Store the screenshot
        currentScreenshot = screenshot
        
        // Generate a name for the screenshot
        let imageName = "screenshot_\(Date().timeIntervalSince1970).jpg"
        
        // Transition to processing and process the image
        currentState = .processing
        processImage(screenshot, name: imageName)
    }
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Photo Access Required",
            message: "Please enable photo library access in Settings → Privacy → Photos → Flrt to use this feature.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { [weak self] _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                // Use extensionContext to open URL in keyboard extensions
                self?.extensionContext?.open(url, completionHandler: { success in
                    print(success ? "✅ Opened Settings" : "❌ Failed to open Settings")
                })
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    private func showNoScreenshotAlert() {
        let alert = UIAlertController(
            title: "No Screenshots Found",
            message: "Please take a screenshot first, then tap the fetch button.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Image Processing
    
    private func processImage(_ image: UIImage, name: String) {
        // Save image to shared container
        let success = SharedDataManager.shared.saveImageFromKeyboard(image, name: name)
        
        if success {
            print("📸 Image saved to shared container, waiting for main app to process...")
            
            // Start polling for response
            startPollingForResponse()
            
        } else {
            print("❌ Failed to save image to shared container")
            DispatchQueue.main.async { [weak self] in
                self?.currentResponse = "Failed to save image"
                self?.currentState = .prompt
            }
        }
    }
    
    private func startPollingForResponse() {
        // Poll for response every 0.5 seconds
        checkResponseTimer?.invalidate()
        checkResponseTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForResponse()
        }
    }
    
    private func checkForResponse() {
        if let response = SharedDataManager.shared.getResponse() {
            print("📨 Response received: \(response)")
            checkResponseTimer?.invalidate()
            checkResponseTimer = nil
            
            SharedDataManager.shared.clearResponse()
            
            // Display response in output view
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    print("❌ Self was deallocated in checkForResponse")
                    return
                }
                print("📤 About to show output view")
                self.currentResponse = response
                self.currentState = .output
                print("✅ Output view should now be visible")
            }
        }
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents
        updateTheme()
    }
    
    deinit {
        checkResponseTimer?.invalidate()
        stopPhotoLibraryObserver()
        print("🔴 KeyboardViewController deinit")
    }
    
    // MARK: - Image Processing
    
    /// Crops the keyboard area from a screenshot
    /// Removes the bottom portion where the keyboard typically appears
    private func cropKeyboardFromScreenshot(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else {
            return image
        }
        
        let imageHeight = CGFloat(cgImage.height)
        let imageWidth = CGFloat(cgImage.width)
        
        // Calculate keyboard height as a percentage of screen height
        // iOS keyboards are typically 270-300pt on most devices
        // Crop out the keyboard area while preserving more content above it
        // Use 30% to show more of the screenshot content
        let keyboardHeightPercentage: CGFloat = 0.30
        let keyboardHeightInPixels = imageHeight * keyboardHeightPercentage
        
        // Calculate the crop rectangle (everything ABOVE the keyboard)
        let cropHeight = imageHeight - keyboardHeightInPixels
        let cropRect = CGRect(
            x: 0,
            y: 0,
            width: imageWidth,
            height: cropHeight
        )
        
        // Perform the crop
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            print("⚠️ Failed to crop image, returning original")
            return image
        }
        
        let croppedImage = UIImage(
            cgImage: croppedCGImage,
            scale: image.scale,
            orientation: image.imageOrientation
        )
        
        print("✂️ Cropped screenshot from \(Int(imageHeight))px to \(Int(cropHeight))px (removed ~\(Int(keyboardHeightInPixels))px keyboard)")
        
        return croppedImage
    }
    
    // MARK: - Photo Library Observer
    
    private func startPhotoLibraryObserver() {
        guard !isObservingPhotoLibrary else { return }
        
        let status = PhotoLibraryManager.shared.checkAuthorizationStatus()
        guard status == .authorized || status == .limited else {
            print("⚠️ Photo library not authorized, cannot start observer")
            return
        }
        
        PHPhotoLibrary.shared().register(self)
        isObservingPhotoLibrary = true
        
        // Get initial screenshot count
        lastScreenshotCount = getScreenshotCount()
        
        print("👀 Started observing photo library. Current screenshot count: \(lastScreenshotCount)")
    }
    
    private func stopPhotoLibraryObserver() {
        guard isObservingPhotoLibrary else { return }
        
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        isObservingPhotoLibrary = false
        
        print("👋 Stopped observing photo library")
    }
    
    private func getScreenshotCount() -> Int {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "(mediaSubtype & %d) != 0", PHAssetMediaSubtype.photoScreenshot.rawValue)
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        return fetchResult.count
    }
    
    // PHPhotoLibraryChangeObserver delegate method
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        print("📸 Photo library changed!")
        
        // Check if screenshot count increased
        let newCount = getScreenshotCount()
        
        if newCount > lastScreenshotCount {
            print("🆕 New screenshot detected! Count: \(lastScreenshotCount) → \(newCount)")
            lastScreenshotCount = newCount
            
            // Auto-fetch if we're in prompt state
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if self.currentState == .prompt {
                    print("🚀 Auto-fetching new screenshot...")
                    
                    // Auto-fetch after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.fetchAndProcessScreenshot()
                    }
                }
            }
        } else {
            lastScreenshotCount = newCount
        }
    }
    
}
