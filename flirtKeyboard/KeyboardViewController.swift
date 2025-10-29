//
//  KeyboardViewController.swift
//  flirtKeyboard
//
//  Created by Kaelin Iwugo on 10/28/25.
//

import UIKit
import UniformTypeIdentifiers

class KeyboardViewController: UIInputViewController, UIDropInteractionDelegate {

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
        
        // Enable drag and drop
        let dropInteraction = UIDropInteraction(delegate: self)
        dropZoneView.addInteraction(dropInteraction)
        
        // Drop Zone Label
        dropZoneLabel = UILabel()
        dropZoneLabel.translatesAutoresizingMaskIntoConstraints = false
        dropZoneLabel.text = "📸\n\nDrag Screenshot Here\n\nTake a screenshot, then drag the\nthumbnail into this area"
        dropZoneLabel.textAlignment = .center
        dropZoneLabel.numberOfLines = 0
        dropZoneLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
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
        
        // Keep a strong reference to prevent deallocation during transition
        let strongSelf = self
        
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
            contentStackView.addArrangedSubview(outputView)
            if let response = currentResponse {
                outputLabel.text = "✅\n\n\(response)"
                print("   → Output text set to: \(response)")
            } else {
                print("   ⚠️ No response to display!")
            }
        }
        
        updateTheme()
        
        // Force layout
        strongSelf.view.layoutIfNeeded()
        
        print("✅ State transition complete, view count: \(contentStackView.arrangedSubviews.count)")
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
    
    // MARK: - UIDropInteractionDelegate
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        // Check if the session contains an image
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        // Show that we accept the drop with copy operation
        // Use .copy to prevent iOS from switching apps
        let proposal = UIDropProposal(operation: .copy)
        return proposal
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        print("📥 Drop interaction started")
        
        // Keep a strong reference to self to prevent deallocation
        let strongSelf = self
        
        // Handle the dropped image using item providers (safer for extensions)
        for item in session.items {
            item.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let error = error {
                    print("❌ Error loading image: \(error)")
                    return
                }
                
                guard let image = object as? UIImage else {
                    print("❌ No image in drop")
                    return
                }
                
                print("✅ Image received from drop")
                
                // Generate a name for the screenshot
                let imageName = "screenshot_\(Date().timeIntervalSince1970).jpg"
                
                // Transition to processing state and process image
                DispatchQueue.main.async {
                    print("🔄 Transitioning to processing state")
                    strongSelf.currentState = .processing
                    strongSelf.processImage(image, name: imageName)
                }
            }
            break // Only process first item
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
        // Visual feedback when drag enters the drop zone
        UIView.animate(withDuration: 0.2) {
            self.dropZoneView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
            self.dropZoneView.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        // Reset visual feedback when drag exits
        UIView.animate(withDuration: 0.2) {
            self.dropZoneView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            self.dropZoneView.transform = .identity
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession) {
        // Reset transform after drop completes
        UIView.animate(withDuration: 0.2) {
            self.dropZoneView.transform = .identity
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
        // Poll for response every 0.5 seconds
        checkResponseTimer?.invalidate()
        checkResponseTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForResponse()
        }
    }
    
    private func checkForResponse() {
        if let response = SharedDataManager.shared.getResponse() {
            // Got response!
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
                self.loadingSpinner.stopAnimating()
                self.currentState = .output
                print("✅ Output view should now be visible")
            }
        }
    }
    
    private func resetDropZone() {
        dropZoneLabel.text = "📸\n\nDrag Screenshot Here\n\nTake a screenshot, then drag the\nthumbnail into this area"
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
