//
//  KeyboardViewController.swift
//  flirtKeyboard
//
//  Created by Kaelin Iwugo on 10/28/25.
//

import UIKit
import UniformTypeIdentifiers

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!
    
    // Keyboard State
    private enum KeyboardState {
        case prompt    // Waiting for screenshot drop
        case processing // Processing screenshot
        case output    // Showing results
    }
    
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
    private var dropZoneView: UIView!
    private var dropZoneLabel: UILabel!
    
    // Loading View Elements
    private var loadingView: UIView!
    private var loadingSpinner: UIActivityIndicatorView!
    private var loadingLabel: UILabel!
    
    // Output View Elements
    private var outputView: UIView!
    private var outputLabel: UILabel!
    private var resetButton: UIButton!
    
    // State
    private var checkResponseTimer: Timer?
    private var currentResponse: String?
    private var pollCount = 0
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Set keyboard height to match standard iOS keyboard
        // Use defaultHigh priority to avoid conflicts with system constraints
        if heightConstraint == nil {
            let keyboardHeight: CGFloat = 270
            heightConstraint = view.heightAnchor.constraint(equalToConstant: keyboardHeight)
            heightConstraint?.priority = .defaultHigh // Changed from .required to avoid conflicts
            heightConstraint?.isActive = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔵 KeyboardViewController viewDidLoad")
        setupUI()
        currentState = .prompt
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("🔴 KeyboardViewController viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("🔴 KeyboardViewController viewDidDisappear")
    }
    
    // Removed override of dismissKeyboard - it's not a real method and might cause issues
    
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
        
        // Next Keyboard Button
        self.nextKeyboardButton = UIButton(type: .system)
        self.nextKeyboardButton.setTitle("⌨️", for: [])
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        containerView.addSubview(self.nextKeyboardButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            contentStackView.bottomAnchor.constraint(equalTo: nextKeyboardButton.topAnchor, constant: -12),
            
            nextKeyboardButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nextKeyboardButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            nextKeyboardButton.widthAnchor.constraint(equalToConstant: 40),
            nextKeyboardButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupPromptView() {
        promptView = UIView()
        promptView.translatesAutoresizingMaskIntoConstraints = false
        
        // Drop Zone View
        dropZoneView = UIView()
        dropZoneView.translatesAutoresizingMaskIntoConstraints = false
        dropZoneView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        dropZoneView.layer.cornerRadius = 12
        dropZoneView.layer.borderWidth = 2
        dropZoneView.layer.borderColor = UIColor.systemBlue.cgColor
        promptView.addSubview(dropZoneView)
        
        // Make drop zone tappable for paste
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dropZoneTapped))
        dropZoneView.addGestureRecognizer(tapGesture)
        dropZoneView.isUserInteractionEnabled = true
        
        // Drop Zone Label
        dropZoneLabel = UILabel()
        dropZoneLabel.translatesAutoresizingMaskIntoConstraints = false
        dropZoneLabel.text = "📸\n\nPaste Screenshot Here\n\n1. Take a screenshot\n2. Tap the thumbnail & copy\n3. Tap here to paste"
        dropZoneLabel.textAlignment = .center
        dropZoneLabel.numberOfLines = 0
        dropZoneLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        dropZoneLabel.textColor = UIColor.systemBlue
        dropZoneView.addSubview(dropZoneLabel)
        
        NSLayoutConstraint.activate([
            dropZoneView.topAnchor.constraint(equalTo: promptView.topAnchor),
            dropZoneView.leadingAnchor.constraint(equalTo: promptView.leadingAnchor),
            dropZoneView.trailingAnchor.constraint(equalTo: promptView.trailingAnchor),
            dropZoneView.bottomAnchor.constraint(equalTo: promptView.bottomAnchor),
            dropZoneView.heightAnchor.constraint(equalToConstant: 200),
            
            dropZoneLabel.centerXAnchor.constraint(equalTo: dropZoneView.centerXAnchor),
            dropZoneLabel.centerYAnchor.constraint(equalTo: dropZoneView.centerYAnchor),
            dropZoneLabel.leadingAnchor.constraint(equalTo: dropZoneView.leadingAnchor, constant: 16),
            dropZoneLabel.trailingAnchor.constraint(equalTo: dropZoneView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupLoadingView() {
        loadingView = UIView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.backgroundColor = UIColor.systemGray6
        loadingView.layer.cornerRadius = 12
        
        // Loading spinner
        loadingSpinner = UIActivityIndicatorView(style: .large)
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        loadingSpinner.color = UIColor.systemBlue
        loadingView.addSubview(loadingSpinner)
        
        // Loading label
        loadingLabel = UILabel()
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.text = "Processing screenshot...\n\nAnalyzing image with AI"
        loadingLabel.textAlignment = .center
        loadingLabel.numberOfLines = 0
        loadingLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        loadingLabel.textColor = UIColor.label
        loadingView.addSubview(loadingLabel)
        
        NSLayoutConstraint.activate([
            loadingView.heightAnchor.constraint(equalToConstant: 200),
            
            loadingSpinner.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor, constant: -30),
            
            loadingLabel.topAnchor.constraint(equalTo: loadingSpinner.bottomAnchor, constant: 20),
            loadingLabel.leadingAnchor.constraint(equalTo: loadingView.leadingAnchor, constant: 16),
            loadingLabel.trailingAnchor.constraint(equalTo: loadingView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupOutputView() {
        outputView = UIView()
        outputView.translatesAutoresizingMaskIntoConstraints = false
        outputView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        outputView.layer.cornerRadius = 12
        outputView.layer.borderWidth = 2
        outputView.layer.borderColor = UIColor.systemGreen.cgColor
        
        // Output label
        outputLabel = UILabel()
        outputLabel.translatesAutoresizingMaskIntoConstraints = false
        outputLabel.text = "Result will appear here"
        outputLabel.textAlignment = .center
        outputLabel.numberOfLines = 0
        outputLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        outputLabel.textColor = UIColor.label
        outputView.addSubview(outputLabel)
        
        // Reset button
        resetButton = UIButton(type: .system)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("Process Another Screenshot", for: .normal)
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        resetButton.backgroundColor = UIColor.systemBlue
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 8
        resetButton.addTarget(self, action: #selector(resetToPrompt), for: .touchUpInside)
        outputView.addSubview(resetButton)
        
        NSLayoutConstraint.activate([
            outputView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            
            outputLabel.topAnchor.constraint(equalTo: outputView.topAnchor, constant: 20),
            outputLabel.leadingAnchor.constraint(equalTo: outputView.leadingAnchor, constant: 16),
            outputLabel.trailingAnchor.constraint(equalTo: outputView.trailingAnchor, constant: -16),
            
            resetButton.topAnchor.constraint(equalTo: outputLabel.bottomAnchor, constant: 20),
            resetButton.leadingAnchor.constraint(equalTo: outputView.leadingAnchor, constant: 16),
            resetButton.trailingAnchor.constraint(equalTo: outputView.trailingAnchor, constant: -16),
            resetButton.bottomAnchor.constraint(equalTo: outputView.bottomAnchor, constant: -20),
            resetButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Check if we have a valid connection before calling needsInputModeSwitchKey
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
        
        // Ensure we're on main thread
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.transitionToState(state)
            }
            return
        }
        
        // Remove all views from stack
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add appropriate view based on state
        switch state {
        case .prompt:
            print("   → Showing prompt view")
            contentStackView.addArrangedSubview(promptView)
            resetDropZone()
            
        case .processing:
            print("   → Showing loading view")
            contentStackView.addArrangedSubview(loadingView)
            loadingSpinner.startAnimating()
            
        case .output:
            print("   → Showing output view")
            
            // Set the response text BEFORE adding to stack
            if let response = currentResponse {
                outputLabel.text = "✅\n\n\(response)"
                print("   → Output text set to: \(response)")
            } else {
                outputLabel.text = "✅\n\nProcessed successfully!"
                print("   ⚠️ No response, using default text")
            }
            
            // Now add to stack
            contentStackView.addArrangedSubview(outputView)
        }
        
        updateTheme()
        
        // Force immediate layout
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        print("✅ State transition complete, view count: \(contentStackView.arrangedSubviews.count)")
        print("   Content stack has subviews: \(contentStackView.arrangedSubviews.map { type(of: $0) })")
    }
    
    @objc private func resetToPrompt() {
        checkResponseTimer?.invalidate()
        checkResponseTimer = nil
        currentResponse = nil
        currentState = .prompt
    }
    
    private func updateTheme() {
        let isDark = self.textDocumentProxy.keyboardAppearance == .dark
        
        // Container
        containerView.backgroundColor = isDark ? UIColor.systemGray6 : UIColor.systemBackground
        
        // Prompt view
        dropZoneLabel.textColor = isDark ? UIColor.systemBlue.withAlphaComponent(0.9) : UIColor.systemBlue
        dropZoneView.backgroundColor = isDark ? UIColor.systemBlue.withAlphaComponent(0.15) : UIColor.systemBlue.withAlphaComponent(0.1)
        
        // Loading view
        loadingView.backgroundColor = isDark ? UIColor.systemGray5 : UIColor.systemGray6
        loadingLabel.textColor = isDark ? UIColor.lightText : UIColor.label
        
        // Output view
        outputLabel.textColor = isDark ? UIColor.lightText : UIColor.label
    }
    
    // MARK: - Pasteboard Handling
    
    @objc private func dropZoneTapped() {
        print("📥 Drop zone tapped - checking pasteboard")
        
        // Visual feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.dropZoneView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.dropZoneView.transform = .identity
            }
        }
        
        // Check if pasteboard has an image
        let pasteboard = UIPasteboard.general
        
        if pasteboard.hasImages {
            print("✅ Image found in pasteboard")
            
            // Get the image from pasteboard
            if let image = pasteboard.image {
                print("✅ Image loaded from pasteboard")
                
                // Generate a name for the screenshot
                let imageName = "screenshot_\(Date().timeIntervalSince1970).jpg"
                
                // Show success feedback
                dropZoneView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
                dropZoneView.layer.borderColor = UIColor.systemGreen.cgColor
                dropZoneLabel.text = "✓ Screenshot received!"
                dropZoneLabel.textColor = UIColor.systemGreen
                
                // Transition to processing state
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.currentState = .processing
                    self?.processImage(image, name: imageName)
                }
            } else {
                print("❌ Could not load image from pasteboard")
                showPasteError("Could not load image")
            }
        } else {
            print("⚠️ No image in pasteboard")
            showPasteError("No image found\n\nCopy a screenshot first")
        }
    }
    
    private func showPasteError(_ message: String) {
        // Show error feedback
        dropZoneView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        dropZoneView.layer.borderColor = UIColor.systemRed.cgColor
        dropZoneLabel.text = "❌\n\n\(message)"
        dropZoneLabel.textColor = UIColor.systemRed
        
        // Reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.resetDropZone()
        }
    }
    
    // MARK: - Image Processing
    
    private func processImage(_ image: UIImage, name: String) {
        // Save image to shared container
        let success = SharedDataManager.shared.saveImageFromKeyboard(image, name: name)
        
        if success {
            print("📸 Image saved to shared container, waiting for main app to process...")
            
            // Start polling for response
            // NOTE: Main app must be running (foreground or background) to process images
            startPollingForResponse()
            
        } else {
            // Show error and reset to prompt
            print("❌ Failed to save image to shared container")
            DispatchQueue.main.async { [weak self] in
                self?.currentResponse = "Failed to save image"
                self?.currentState = .prompt
            }
        }
    }
    
    private func startPollingForResponse() {
        print("🔄 Starting response polling...")
        // Poll for response every 0.5 seconds
        checkResponseTimer?.invalidate()
        pollCount = 0
        checkResponseTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            self.pollCount += 1
            print("   Polling attempt #\(self.pollCount)...")
            self.checkForResponse()
            
            // Safety: stop after 20 seconds
            if self.pollCount > 40 {
                print("⏱️ Polling timeout after 20 seconds")
                timer.invalidate()
            }
        }
    }
    
    private func checkForResponse() {
        if let response = SharedDataManager.shared.getResponse() {
            // Got response!
            print("📨 Response received: \(response)")
            
            // Stop timer AFTER we process
            let timer = checkResponseTimer
            
            SharedDataManager.shared.clearResponse()
            
            // Keep a strong reference and display response
            let strongSelf = self
            DispatchQueue.main.async {
                print("📤 About to show output view")
                strongSelf.currentResponse = response
                strongSelf.loadingSpinner.stopAnimating()
                
                // Stop timer here
                timer?.invalidate()
                strongSelf.checkResponseTimer = nil
                
                // Transition to output
                strongSelf.currentState = .output
                
                // Force layout to ensure view is visible
                strongSelf.view.layoutIfNeeded()
                
                print("✅ Output view displayed with: \(response)")
            }
        }
    }
    
    private func resetDropZone() {
        dropZoneLabel.text = "📸\n\nPaste Screenshot Here\n\n1. Take a screenshot\n2. Tap the thumbnail & copy\n3. Tap here to paste"
        dropZoneView.layer.borderColor = UIColor.systemBlue.cgColor
        updateTheme()
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
        print("🔴 KeyboardViewController deinit")
    }
}
