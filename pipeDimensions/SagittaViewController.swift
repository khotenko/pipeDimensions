//
//  SagittaViewController.swift
//  pipeDimensions
//
//  Created on 2026-07-09.
//  Copyright © 2026 Nick Khotenko. All rights reserved.
//

import UIKit

/// View controller for the Sagitta-based NPS estimation tool
class SagittaViewController: UIViewController {
    
    // MARK: - Properties
    
    private let calculator: SagittaCalculator
    private var currentUnit: MeasurementUnit = .inches
    private var currentResult: NPSEstimationResult?
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Header
    private let titleLabel = UILabel()
    private let closeButton: UIButton = {
        if #available(iOS 13.0, *) {
            return UIButton(type: .close)
        } else {
            let button = UIButton(type: .system)
            button.setTitle("✕", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 24, weight: .light)
            return button
        }
    }()
    private let descriptionLabel = UILabel()
    private let formulaLabel = UILabel()
    
    // Schematic view
    private let schematicView = SagittaSchematicView()
    
    // Unit toggle
    private let unitSegmentedControl = UISegmentedControl(items: ["in", "mm"])
    
    // Input field labels
    private let sagittaLabel = UILabel()
    private let chordLabel = UILabel()
    
    // Decimal conversion labels (shown under inputs in inch mode)
    private let sagittaConversionLabel = UILabel()
    private let chordConversionLabel = UILabel()
    
    // Input fields
    private let sagittaTextField = UITextField()
    private let chordTextField = UITextField()
    
    // Error label
    private let errorLabel = UILabel()
    
    // Results container
    private let resultsContainerView = UIView()
    private let estimatedODLabel = UILabel()
    private let warningLabel = UILabel()
    private let matchesStackView = UIStackView()
    
    // Live schematic
    private let liveSchematicView = LivePipeSchematicView()
    
    // Recent calculations
    private var recentCalculations: [RecentCalculation] = []
    private let recentCalculationsHeaderButton = UIButton(type: .system)
    private let recentCalculationsStackView = UIStackView()
    private var isRecentCalculationsExpanded = true
    private var recentCalculationsShowTimer: Timer?
    
    // MARK: - Initialization
    
    init(calculator: SagittaCalculator) {
        self.calculator = calculator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    deinit {
        recentCalculationsShowTimer?.invalidate()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        // Adjust scroll indicator insets to avoid close button
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Title
        titleLabel.text = "Estimate NPS from Top of Pipe"
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        
        // Close button
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        // Formula
        formulaLabel.text = "OD = 2·(s² + (c/2)²) / (2·s)"
        formulaLabel.font = UIFont.italicSystemFont(ofSize: 14)
        if #available(iOS 13.0, *) {
            formulaLabel.textColor = .tertiaryLabel
        } else {
            formulaLabel.textColor = .lightGray
        }
        
        // Schematic
        schematicView.translatesAutoresizingMaskIntoConstraints = false
        
        // Unit controls
        unitSegmentedControl.selectedSegmentIndex = 0
        unitSegmentedControl.addTarget(self, action: #selector(unitChanged), for: .valueChanged)
        
        // Input field labels
        sagittaLabel.text = "S (Sagitta) [in]"
        sagittaLabel.font = .preferredFont(forTextStyle: .caption1)
        if #available(iOS 13.0, *) {
            sagittaLabel.textColor = .secondaryLabel
        } else {
            sagittaLabel.textColor = .darkGray
        }
        
        chordLabel.text = "C (Chord) [in]"
        chordLabel.font = .preferredFont(forTextStyle: .caption1)
        if #available(iOS 13.0, *) {
            chordLabel.textColor = .secondaryLabel
        } else {
            chordLabel.textColor = .darkGray
        }
        
        // Input fields
        configureSagittaField()
        configureChordField()
        
        // Setup conversion labels
        setupConversionLabels()
        
        // Error label
        errorLabel.textColor = .systemRed
        errorLabel.font = .preferredFont(forTextStyle: .caption1)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        
        // Results
        resultsContainerView.isHidden = true
        if #available(iOS 13.0, *) {
            resultsContainerView.backgroundColor = .secondarySystemBackground
        } else {
            resultsContainerView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        }
        resultsContainerView.layer.cornerRadius = 12
        
        estimatedODLabel.font = .preferredFont(forTextStyle: .headline)
        estimatedODLabel.numberOfLines = 0
        
        warningLabel.font = .preferredFont(forTextStyle: .caption1)
        warningLabel.textColor = .systemOrange
        warningLabel.numberOfLines = 0
        warningLabel.isHidden = true
        
        matchesStackView.axis = .vertical
        matchesStackView.spacing = 8
        
        // Live schematic
        liveSchematicView.translatesAutoresizingMaskIntoConstraints = false
        liveSchematicView.isHidden = true
        
        // Recent calculations header button
        recentCalculationsHeaderButton.setTitle("▼ Recent Calculations", for: .normal)
        recentCalculationsHeaderButton.titleLabel?.font = .preferredFont(forTextStyle: .caption1)
        recentCalculationsHeaderButton.addTarget(self, action: #selector(toggleRecentCalculations), for: .touchUpInside)
        recentCalculationsHeaderButton.isHidden = true
        recentCalculationsHeaderButton.contentHorizontalAlignment = .left
        if #available(iOS 13.0, *) {
            recentCalculationsHeaderButton.setTitleColor(.systemBlue, for: .normal)
        } else {
            recentCalculationsHeaderButton.setTitleColor(.blue, for: .normal)
        }
        
        // Recent calculations stack view
        recentCalculationsStackView.axis = .vertical
        recentCalculationsStackView.spacing = 2
        recentCalculationsStackView.isHidden = true
        
        // Add all subviews
        [titleLabel, closeButton, formulaLabel,
         schematicView, unitSegmentedControl,
         sagittaLabel, chordLabel, sagittaTextField, chordTextField,
         sagittaConversionLabel, chordConversionLabel,
         recentCalculationsHeaderButton, recentCalculationsStackView, errorLabel,
         resultsContainerView, liveSchematicView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        [estimatedODLabel, warningLabel, matchesStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            resultsContainerView.addSubview($0)
        }
    }
    
    private func configureSagittaField() {
        sagittaTextField.placeholder = "e.g 5/16"
        sagittaTextField.borderStyle = .roundedRect
        sagittaTextField.keyboardType = .default  // Allows "/" and space for fractions in inch mode
        sagittaTextField.delegate = self
        sagittaTextField.addTarget(self, action: #selector(inputChanged), for: .editingChanged)
    }
    
    private func configureChordField() {
        chordTextField.placeholder = "e.g 4 1/4"
        chordTextField.borderStyle = .roundedRect
        chordTextField.keyboardType = .default  // Allows "/" and space for fractions in inch mode
        chordTextField.delegate = self
        chordTextField.addTarget(self, action: #selector(inputChanged), for: .editingChanged)
    }
    
    private func setupConversionLabels() {
        sagittaConversionLabel.font = .preferredFont(forTextStyle: .caption2)
        sagittaConversionLabel.isHidden = false
        if #available(iOS 13.0, *) {
            sagittaConversionLabel.textColor = .secondaryLabel
        } else {
            sagittaConversionLabel.textColor = .darkGray
        }
        
        chordConversionLabel.font = .preferredFont(forTextStyle: .caption2)
        chordConversionLabel.isHidden = false
        if #available(iOS 13.0, *) {
            chordConversionLabel.textColor = .secondaryLabel
        } else {
            chordConversionLabel.textColor = .darkGray
        }
    }
    
    // MARK: - Layout
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title and close button
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            closeButton.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            
            // Formula
            formulaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            formulaLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            // Schematic
            schematicView.topAnchor.constraint(equalTo: formulaLabel.bottomAnchor, constant: 12),
            schematicView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            schematicView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            schematicView.heightAnchor.constraint(equalToConstant: 120),
            
            // Unit controls
            unitSegmentedControl.topAnchor.constraint(equalTo: schematicView.bottomAnchor, constant: 16),
            unitSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            // Input field labels
            sagittaLabel.topAnchor.constraint(equalTo: unitSegmentedControl.bottomAnchor, constant: 16),
            sagittaLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            chordLabel.topAnchor.constraint(equalTo: sagittaLabel.topAnchor),
            chordLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 6),
            
            // Input fields
            sagittaTextField.topAnchor.constraint(equalTo: sagittaLabel.bottomAnchor, constant: 6),
            sagittaTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sagittaTextField.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -6),
            
            chordTextField.topAnchor.constraint(equalTo: chordLabel.bottomAnchor, constant: 6),
            chordTextField.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 6),
            chordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Decimal conversion labels (under input fields)
            sagittaConversionLabel.topAnchor.constraint(equalTo: sagittaTextField.bottomAnchor, constant: 2),
            sagittaConversionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            chordConversionLabel.topAnchor.constraint(equalTo: chordTextField.bottomAnchor, constant: 2),
            chordConversionLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 6),
            
            // Error label
            errorLabel.topAnchor.constraint(equalTo: chordConversionLabel.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Results container
            resultsContainerView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            resultsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resultsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Results content
            estimatedODLabel.topAnchor.constraint(equalTo: resultsContainerView.topAnchor, constant: 16),
            estimatedODLabel.leadingAnchor.constraint(equalTo: resultsContainerView.leadingAnchor, constant: 16),
            estimatedODLabel.trailingAnchor.constraint(equalTo: resultsContainerView.trailingAnchor, constant: -16),
            
            warningLabel.topAnchor.constraint(equalTo: estimatedODLabel.bottomAnchor, constant: 8),
            warningLabel.leadingAnchor.constraint(equalTo: resultsContainerView.leadingAnchor, constant: 16),
            warningLabel.trailingAnchor.constraint(equalTo: resultsContainerView.trailingAnchor, constant: -16),
            
            matchesStackView.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: 12),
            matchesStackView.leadingAnchor.constraint(equalTo: resultsContainerView.leadingAnchor, constant: 12),
            matchesStackView.trailingAnchor.constraint(equalTo: resultsContainerView.trailingAnchor, constant: -12),
            matchesStackView.bottomAnchor.constraint(equalTo: resultsContainerView.bottomAnchor, constant: -16),
            
            // Live schematic
            liveSchematicView.topAnchor.constraint(equalTo: resultsContainerView.bottomAnchor, constant: 16),
            liveSchematicView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            liveSchematicView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            liveSchematicView.heightAnchor.constraint(equalToConstant: 200),
            
            // Recent calculations header button
            recentCalculationsHeaderButton.topAnchor.constraint(equalTo: liveSchematicView.bottomAnchor, constant: 16),
            recentCalculationsHeaderButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            // Recent calculations stack view
            recentCalculationsStackView.topAnchor.constraint(equalTo: recentCalculationsHeaderButton.bottomAnchor, constant: 4),
            recentCalculationsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recentCalculationsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            recentCalculationsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    // MARK: - Actions
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func unitChanged() {
        currentUnit = unitSegmentedControl.selectedSegmentIndex == 0 ? .inches : .millimeters
        
        // Update labels with unit
        let unitSymbol = currentUnit.symbol
        sagittaLabel.text = "S [\(unitSymbol)]"
        chordLabel.text = "C [\(unitSymbol)]"
        
        // Update keyboard types and placeholders based on unit mode
        if currentUnit == .inches {
            // Inch mode: allow "/" and space for fractions
            sagittaTextField.keyboardType = .default
            chordTextField.keyboardType = .default
            sagittaTextField.placeholder = "e.g 5/16"
            chordTextField.placeholder = "e.g 4 1/4"
            sagittaConversionLabel.isHidden = false
            chordConversionLabel.isHidden = false
        } else {
            // MM mode: numeric only
            sagittaTextField.keyboardType = .decimalPad
            chordTextField.keyboardType = .decimalPad
            sagittaTextField.placeholder = "7.9"
            chordTextField.placeholder = "114"
            sagittaConversionLabel.isHidden = true
            chordConversionLabel.isHidden = true
        }
        
        // Convert existing values
        convertFieldValues()
        
        // Update conversion labels if in inch mode
        if currentUnit == .inches {
            updateConversionLabels()
        }
        
        // Recalculate
        performCalculation()
    }
    
    @objc private func inputChanged() {
        // Update conversion labels if in inch mode
        if currentUnit == .inches {
            updateConversionLabels()
        }
        
        // Invalidate existing timer
        recentCalculationsShowTimer?.invalidate()
        
        // Start new timer to save calculation after 2 seconds of inactivity
        recentCalculationsShowTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            // Save the current valid result if it exists
            if let result = self?.currentResult, result.isValid {
                self?.addToRecentCalculations(result)
            }
        }
        
        performCalculation()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func toggleRecentCalculations() {
        isRecentCalculationsExpanded.toggle()
        
        // Only show stack view if there are calculations and expanded
        if !recentCalculations.isEmpty {
            recentCalculationsStackView.isHidden = !isRecentCalculationsExpanded
        }
        
        let arrow = isRecentCalculationsExpanded ? "▼" : "▶"
        recentCalculationsHeaderButton.setTitle("\(arrow) Recent Calculations", for: .normal)
    }
    
    // MARK: - Calculation
    
    private func performCalculation() {
        guard let sagittaText = sagittaTextField.text, !sagittaText.isEmpty,
              let chordText = chordTextField.text, !chordText.isEmpty else {
            hideResults()
            return
        }
        
        // Parse input values, supporting fractions in inches mode
        let sagitta = currentUnit == .inches ?
            sagittaText.parseFraction() ?? Double(sagittaText) :
            Double(sagittaText)
        
        let chord = currentUnit == .inches ?
            chordText.parseFraction() ?? Double(chordText) :
            Double(chordText)
        
        guard let sagittaVal = sagitta, sagittaVal > 0,
              let chordVal = chord, chordVal > 0 else {
            hideResults()
            return
        }
        
        let result = calculator.calculate(sagitta: sagittaVal, chord: chordVal, unit: currentUnit)
        currentResult = result
        
        if result.isValid {
            displayResults(result)
        } else {
            showError(result.errorMessage ?? "Unknown error")
        }
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        resultsContainerView.isHidden = true
        liveSchematicView.isHidden = true
    }
    
    private func hideResults() {
        errorLabel.isHidden = true
        resultsContainerView.isHidden = true
        liveSchematicView.isHidden = true
        currentResult = nil
    }
    
    private func displayResults(_ result: NPSEstimationResult) {
        errorLabel.isHidden = true
        resultsContainerView.isHidden = false
        liveSchematicView.isHidden = false
        
        // Update OD label
        estimatedODLabel.text = "Estimated OD: \(result.formattedOD(in: currentUnit))"
        
        // Show warning if applicable
        if result.isSagittaFullDiameter {
            warningLabel.text = "⚠️ S ≥ C: The contour tool fully surrounded the pipe. S is assumed to be same as C."
            warningLabel.isHidden = false
        } else {
            warningLabel.isHidden = true
        }
        
        // Clear and populate matches
        matchesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        result.matches.forEach { match in
            let matchView = createMatchView(for: match, result: result)
            matchesStackView.addArrangedSubview(matchView)
        }
        
        // Update live schematic
        liveSchematicView.updateOD(result.estimatedOD)
        
        // Do NOT save to recent calculations immediately - let the debounce timer handle it
    }
    
    private func createMatchView(for match: NPSMatch, result: NPSEstimationResult) -> UIView {
        let container = UIView()
        if match.isClosest {
            container.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        } else {
            if #available(iOS 13.0, *) {
                container.backgroundColor = .tertiarySystemBackground
            } else {
                container.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
            }
        }
        container.layer.cornerRadius = 8
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon
        let iconImageView = UIImageView()
        let iconName: String
        let iconColor: UIColor
        
        switch match.matchType {
        case .closest:
            iconName = "checkmark.circle"
            iconColor = .systemGreen
        case .smaller:
            iconName = "arrow.down.circle"
            iconColor = .systemBlue
        case .larger:
            iconName = "arrow.up.circle"
            iconColor = .systemOrange
        }
        
        if #available(iOS 13.0, *) {
            iconImageView.image = UIImage(systemName: iconName)
            iconImageView.tintColor = iconColor
        } else {
            // Fallback: use colored circle for iOS 12
            iconImageView.backgroundColor = iconColor.withAlphaComponent(0.2)
            iconImageView.layer.cornerRadius = 12
            iconImageView.clipsToBounds = true
        }
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Labels
        let titleLabel = UILabel()
        titleLabel.text = "NPS \(match.npsEntry.npsLabel)"
        titleLabel.font = match.isClosest ? .boldSystemFont(ofSize: 16) : .systemFont(ofSize: 15)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let odLabel = UILabel()
        let odText = currentUnit == .inches ?
            "\(String(format: "%.3f", match.npsEntry.odInches)) in" :
            "\(String(format: "%.1f", match.npsEntry.odMillimeters)) mm"
        odLabel.text = "OD: \(odText)"
        odLabel.font = .systemFont(ofSize: 13)
        if #available(iOS 13.0, *) {
            odLabel.textColor = .secondaryLabel
        } else {
            odLabel.textColor = .darkGray
        }
        odLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let deltaLabel = UILabel()
        deltaLabel.text = match.formattedDelta(in: currentUnit)
        deltaLabel.font = .systemFont(ofSize: 12)
        if match.isClosest {
            deltaLabel.textColor = .systemGreen
        } else {
            if #available(iOS 13.0, *) {
                deltaLabel.textColor = .tertiaryLabel
            } else {
                deltaLabel.textColor = .lightGray
            }
        }
        deltaLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconImageView)
        container.addSubview(titleLabel)
        container.addSubview(odLabel)
        container.addSubview(deltaLabel)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            iconImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            
            odLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            odLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            odLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            
            deltaLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            deltaLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func convertFieldValues() {
        // Convert between units when toggle changes
        let factor = currentUnit == .inches ? (1.0 / 25.4) : 25.4
        
        // Convert sagitta field
        if let text = sagittaTextField.text, !text.isEmpty {
            // Try to parse as fraction first (when converting FROM inches)
            let value = text.parseFraction() ?? Double(text) ?? 0
            if value > 0 {
                sagittaTextField.text = String(format: "%.3f", value * factor)
            }
        }
        
        // Convert chord field
        if let text = chordTextField.text, !text.isEmpty {
            // Try to parse as fraction first (when converting FROM inches)
            let value = text.parseFraction() ?? Double(text) ?? 0
            if value > 0 {
                chordTextField.text = String(format: "%.3f", value * factor)
            }
        }
    }
    
    private func updateConversionLabels() {
        // Update sagitta conversion label - only show for fractions
        if let text = sagittaTextField.text, !text.isEmpty,
           text.contains("/") {
            if let value = text.parseFraction() {
                sagittaConversionLabel.text = "\(text) is = \(String(format: "%.3f", value))"
            }
        } else {
            sagittaConversionLabel.text = ""
        }
        
        // Update chord conversion label - only show for fractions
        if let text = chordTextField.text, !text.isEmpty,
           text.contains("/") {
            if let value = text.parseFraction() {
                chordConversionLabel.text = "\(text) is = \(String(format: "%.3f", value))"
            }
        } else {
            chordConversionLabel.text = ""
        }
    }
    
    private func addToRecentCalculations(_ result: NPSEstimationResult) {
        // Limit recent calculations to 10 entries
        if recentCalculations.count >= 10 {
            recentCalculations.removeLast()
        }
        
        // Capture the exact user input strings
        let sagittaInput = sagittaTextField.text ?? ""
        let chordInput = chordTextField.text ?? ""
        
        // Add new calculation
        let newCalculation = RecentCalculation(
            result: result,
            date: Date(),
            sagittaInput: sagittaInput,
            chordInput: chordInput
        )
        recentCalculations.insert(newCalculation, at: 0)
        
        // Update UI
        updateRecentCalculationsUI()
    }
    
    private func updateRecentCalculationsUI() {
        // Clear existing views
        recentCalculationsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Show/hide entire section based on whether there are calculations
        let hasCalculations = !recentCalculations.isEmpty
        recentCalculationsHeaderButton.isHidden = !hasCalculations
        recentCalculationsStackView.isHidden = !hasCalculations || !isRecentCalculationsExpanded
        
        // Add entries only if there are calculations
        if hasCalculations {
            for calculation in recentCalculations {
                let entryView = createRecentCalculationEntry(for: calculation)
                recentCalculationsStackView.addArrangedSubview(entryView)
            }
        }
    }
    
    private func createRecentCalculationEntry(for calculation: RecentCalculation) -> UIView {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        // Format with stored user input
        let npsMatch = calculation.result.matches.first { $0.isClosest }
        let npsLabel = npsMatch?.npsEntry.npsLabel ?? "—"
        
        let odFormatted = currentUnit == .inches ?
            String(format: "%.3f in", calculation.result.estimatedOD) :
            String(format: "%.1f mm", calculation.result.estimatedOD)
        
        // Parse the stored inputs
        let sagittaParsed = calculation.sagittaInput.parseFraction() ?? 0
        let chordParsed = calculation.chordInput.parseFraction() ?? 0
        
        // Format inputs: only show brackets if input was fractional
        let sagittaFormatted: String
        if calculation.sagittaInput.contains("/") {
            sagittaFormatted = "\(calculation.sagittaInput) (\(String(format: "%.3f", sagittaParsed)))"
        } else {
            sagittaFormatted = String(format: "%.3f", sagittaParsed)
        }
        
        let chordFormatted: String
        if calculation.chordInput.contains("/") {
            chordFormatted = "\(calculation.chordInput) (\(String(format: "%.3f", chordParsed)))"
        } else {
            chordFormatted = String(format: "%.3f", chordParsed)
        }
        
        let text = "S=\(sagittaFormatted) C=\(chordFormatted) → OD = \(odFormatted) | NPS \(npsLabel)"
        label.text = text
        
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = .darkGray
        }
        
        return label
    }
}

// MARK: - UITextFieldDelegate

extension SagittaViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == sagittaTextField {
            chordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - Fraction Parser Utility

/// Extension to parse fraction and mixed number strings
private extension String {
    /// Parses fraction strings like "5/16", "4 1/4", "5.25", or "5"
    /// Returns the decimal value or nil if parsing fails
    func parseFraction() -> Double? {
        let trimmed = self.trimmingCharacters(in: .whitespaces)
        
        // Empty string
        guard !trimmed.isEmpty else { return nil }
        
        // Try simple decimal first (most common case)
        if let decimal = Double(trimmed) {
            return decimal
        }
        
        // Check if it's a mixed number (has space and fraction): "4 1/4"
        if trimmed.contains(" ") && trimmed.contains("/") {
            let parts = trimmed.components(separatedBy: " ")
            if parts.count == 2,
               let wholePart = Double(parts[0]),
               let fraction = parseSingleFraction(parts[1]) {
                return wholePart + fraction
            }
        }
        
        // Check if it's just a fraction: "5/16"
        if trimmed.contains("/") {
            return parseSingleFraction(trimmed)
        }
        
        return nil
    }
    
    /// Parses a single fraction string like "5/16"
    private func parseSingleFraction(_ fractionStr: String) -> Double? {
        let components = fractionStr.components(separatedBy: "/")
        guard components.count == 2,
              let numerator = Double(components[0].trimmingCharacters(in: .whitespaces)),
              let denominator = Double(components[1].trimmingCharacters(in: .whitespaces)),
              denominator != 0 else {
            return nil
        }
        return numerator / denominator
    }
}

// MARK: - Recent Calculation Model

/// Represents a single recent calculation
struct RecentCalculation {
    let result: NPSEstimationResult
    let date: Date
    let sagittaInput: String
    let chordInput: String
}
