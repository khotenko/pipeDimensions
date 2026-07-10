//
//  ViewController.swift
//  pipeDimensions
//
//  Created by Nick Khotenko on 2020-06-07.
//  Copyright © 2020 Nick Khotenko. All rights reserved.
//

import UIKit
import SwiftRater

// MARK: - Layout Configuration

/// Mac-specific wrapper view controller that allows dismissal by clicking outside
#if targetEnvironment(macCatalyst)
class DismissibleModalViewController: UIViewController {
    private let contentViewController: UIViewController
    private let preferredWidth: CGFloat
    private let preferredHeight: CGFloat
    private let containerView = UIView()
    
    init(contentViewController: UIViewController, preferredWidth: CGFloat, preferredHeight: CGFloat) {
        self.contentViewController = contentViewController
        self.preferredWidth = preferredWidth
        self.preferredHeight = preferredHeight
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Semi-transparent background
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        // Add tap gesture to dismiss when clicking outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGesture)
        
        // Setup container view
        if #available(iOS 13.0, *) {
            containerView.backgroundColor = .systemBackground
        } else {
            containerView.backgroundColor = .white
        }
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 16
        containerView.layer.shadowOpacity = 0.3
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Add content view controller
        addChild(contentViewController)
        containerView.addSubview(contentViewController.view)
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentViewController.view.layer.cornerRadius = 12
        contentViewController.view.clipsToBounds = true
        contentViewController.didMove(toParent: self)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: preferredWidth),
            containerView.heightAnchor.constraint(equalToConstant: preferredHeight),
            
            contentViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            contentViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // Prevent taps on container from dismissing
        let containerTap = UITapGestureRecognizer(target: self, action: #selector(containerTapped))
        containerView.addGestureRecognizer(containerTap)
    }
    
    @objc private func backgroundTapped() {
        dismiss(animated: true)
    }
    
    @objc private func containerTapped() {
        // Do nothing - this prevents the tap from reaching the background
    }
}
#endif

// MARK: - Layout Configuration

/// Centralized layout configuration that eliminates magic numbers and provides
/// clear, maintainable responsive layout values based on width and text size
struct LayoutConfig {
    // MARK: - Breakpoints
    private static let smallWidth: CGFloat = 320
    private static let mediumWidthStart: CGFloat = 320
    private static let mediumWidthEnd: CGFloat = 490
    private static let largeWidthStart: CGFloat = 490
    private static let maxWidth: CGFloat = 600
    
    // MARK: - Layout Properties
    let headerHeight: CGFloat
    let pickerHeight: CGFloat
    let wtInchesWidth: CGFloat?  // Only set for large text
    
    // Column spacing
    let inchesToMmSpacing: CGFloat
    let mmToLbftSpacing: CGFloat
    let lbftToKgSpacing: CGFloat
    let scheduleTrailingMargin: CGFloat
    
    // MARK: - Factory Method
    
    /// Resolves the appropriate layout configuration based on header width and text size
    /// - Parameters:
    ///   - width: The header view width
    ///   - isLargeText: Whether the user has accessibility large text enabled
    /// - Returns: A configured LayoutConfig with appropriate values
    static func resolve(for width: CGFloat, isLargeText: Bool) -> LayoutConfig {
        // Determine base dimensions
        let headerHeight: CGFloat = isLargeText ? 60 : 45
        let pickerHeight: CGFloat = isLargeText ? 275 : 175
        
        // Determine spacing based on width ranges
        let spacing = calculateSpacing(for: width, isLargeText: isLargeText)
        
        return LayoutConfig(
            headerHeight: headerHeight,
            pickerHeight: pickerHeight,
            wtInchesWidth: isLargeText ? 60 : nil,
            inchesToMmSpacing: spacing.inchesToMm,
            mmToLbftSpacing: spacing.mmToLbft,
            lbftToKgSpacing: spacing.lbftToKg,
            scheduleTrailingMargin: spacing.scheduleTrailing
        )
    }
    
    // MARK: - Private Helpers
    
    private struct Spacing {
        let inchesToMm: CGFloat
        let mmToLbft: CGFloat
        let lbftToKg: CGFloat
        let scheduleTrailing: CGFloat
    }
    
    private static func calculateSpacing(for width: CGFloat, isLargeText: Bool) -> Spacing {
        switch width {
        case ...smallWidth:
            // Compact: minimal spacing
            return Spacing(
                inchesToMm: 5,
                mmToLbft: 5,
                lbftToKg: 17,
                scheduleTrailing: isLargeText ? 5 : 10
            )
            
        case mediumWidthStart..<mediumWidthEnd:
            // Medium: proportional spacing scales with width
            let baseOffset = isLargeText ? 80.714 : 85.714
            let lbftKgOffset: CGFloat = isLargeText ? 60 : 55
            
            return Spacing(
                inchesToMm: (75.0 / 280.0) * width - baseOffset,
                mmToLbft: 0.225 * width - 50,
                lbftToKg: 0.225 * width - lbftKgOffset,
                scheduleTrailing: 10
            )
            
        case mediumWidthEnd..<maxWidth:
            // Large: proportional but with adjusted lb/ft-kg spacing
            let baseOffset = isLargeText ? 80.714 : 85.714
            
            return Spacing(
                inchesToMm: (75.0 / 280.0) * width - baseOffset,
                mmToLbft: 0.225 * width - 50,
                lbftToKg: 0.225 * width - 50,
                scheduleTrailing: 10
            )
            
        default:
            // Extra large: fixed maximum comfortable spacing
            return Spacing(
                inchesToMm: isLargeText ? 80 : 75,
                mmToLbft: isLargeText ? 80 : 85,
                lbftToKg: isLargeText ? 80 : 85,
                scheduleTrailing: 10
            )
        }
    }
}

// MARK: - View Controller

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var wtHeader: UILabel!
    @IBOutlet weak var wtmmHeader: UILabel!
    @IBOutlet weak var lbftHeader: UILabel!
    @IBOutlet weak var kgmHeader: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var schHeader: UILabel!
    
    var p : [pipeData] = []
    var wanted : [pipeData] = []
    
    // Track if initial styling has been applied to avoid redundant updates
    private var hasAppliedInitialStyling = false
    // Track last known header width to detect actual layout changes
    private var lastHeaderWidth: CGFloat = 0
    
    @IBOutlet weak var selector: UIPickerView!
    @IBOutlet weak var pickerHeight: NSLayoutConstraint!
    @IBOutlet weak var WTinchesBoldButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var inches_mm_space: NSLayoutConstraint!
    @IBOutlet weak var mm_lbft_space: NSLayoutConstraint!
    @IBOutlet weak var lbft_kg_space: NSLayoutConstraint!
    @IBOutlet weak var sch_space_fromright: NSLayoutConstraint!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    @IBOutlet weak var WTInchesWidth: NSLayoutConstraint!
  
    
    var dataManager = DataManager()
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var WTmmBold: UIButton!
    
    // NPS Estimation floating button
    private lazy var npsButton: UIButton = {
        let button = UIButton(type: .system)
        
        // Grey color scheme
        if #available(iOS 13.0, *) {
            button.backgroundColor = UIColor.systemGray5
        } else {
            button.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        }
        
        button.layer.cornerRadius = 20  // Smaller radius for 40pt button
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 0.15
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Set button image/text based on iOS version
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
            let image = UIImage(systemName: "circle.circle", withConfiguration: config)
            button.setImage(image, for: .normal)
            button.tintColor = .systemGray
        } else {
            button.setTitle("⊕", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 24)
            button.setTitleColor(.gray, for: .normal)
        }
        
        button.accessibilityLabel = "Estimate NPS from Pipe Arc"
        button.addTarget(self, action: #selector(openNPSEstimator), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Helper Methods
    
    /// Applies font styling to header labels based on current preferences and device type
    private func updateHeaderStyles() {
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        
        if isPhone {
            // Phone styling
            if mmPref {
                wtHeader.Style15_Subhead()
                wtmmHeader.Style17_HeadlineBold()
            } else if inPref {
                wtHeader.Style17_HeadlineBold()
                wtmmHeader.Style15_Subhead()
            } else {
                wtHeader.Style15_Subhead()
                wtmmHeader.Style17_HeadlineBold()
            }
            lbftHeader.Style15_Subhead()
            kgmHeader.Style15_Subhead()
            schHeader.Style15_Subhead()
        } else {
            // iPad/Mac styling
            if mmPref {
                wtHeader.Style17_HeadlineThin()
                wtmmHeader.Style17_HeadlineBold()
            } else if inPref {
                wtHeader.Style17_HeadlineBold()
                wtmmHeader.Style17_HeadlineThin()
            } else {
                wtHeader.Style17_HeadlineThin()
                wtmmHeader.Style17_HeadlineBold()
            }
            lbftHeader.Style17_HeadlineThin()
            kgmHeader.Style17_HeadlineThin()
            schHeader.Style17_HeadlineThin()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func WTmmBoldPressed(_ sender: UIButton) {
        defaults.set(true, forKey: "mmBold")
        defaults.set(false, forKey: "inBold")
        
        mmPref = true
        inPref = false
        
        updateHeaderStyles()
        tableView.reloadData()
    }
    
    @IBAction func WTInchesBoldPressed(_ sender: UIButton) {
        defaults.set(false, forKey: "mmBold")
        defaults.set(true, forKey: "inBold")
        
        mmPref = false
        inPref = true
        
        updateHeaderStyles()
        tableView.reloadData()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            SwiftRater.check()
        }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Only update styles on first layout or when preferences actually changed
        if !hasAppliedInitialStyling {
            mmPref = defaults.bool(forKey: "mmBold")
            inPref = defaults.bool(forKey: "inBold")
            updateHeaderStyles()
            hasAppliedInitialStyling = true
        }
        
        // iPad-specific layout adjustments
        guard UIDevice.current.userInterfaceIdiom == .pad else { return }
        
        let headerWidth = headerView.frame.width
        
        // Only update constraints if width actually changed
        guard headerWidth != lastHeaderWidth else { return }
        lastHeaderWidth = headerWidth
        
        // Resolve layout configuration based on current width and accessibility settings
        let isLargeText = UIApplication.shared.preferredContentSizeCategory >= .extraLarge
        let config = LayoutConfig.resolve(for: headerWidth, isLargeText: isLargeText)
        
        // Apply configuration to constraints
        applyLayoutConfig(config)
        
        selector.updateConstraintsIfNeeded()
    }
    
    /// Applies the resolved layout configuration to all relevant constraints
    /// - Parameter config: The LayoutConfig to apply
    private func applyLayoutConfig(_ config: LayoutConfig) {
        headerHeight.constant = config.headerHeight
        pickerHeight.constant = config.pickerHeight
        inches_mm_space.constant = config.inchesToMmSpacing
        mm_lbft_space.constant = config.mmToLbftSpacing
        lbft_kg_space.constant = config.lbftToKgSpacing
        sch_space_fromright.constant = config.scheduleTrailingMargin
        
        // Only set WT inches width for large text
        if let width = config.wtInchesWidth {
            WTInchesWidth.constant = width
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        selector.dataSource = self
        selector.delegate = self
        
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "pipeCell")
        
        // Load preferences
        mmPref = defaults.bool(forKey: "mmBold")
        inPref = defaults.bool(forKey: "inBold")
        
        // Setup floating NPS estimation button
        setupNPSButton()
        
        // Load JSON data asynchronously to avoid blocking main thread
        loadPipeDataAsync()
    }
    
    // MARK: - NPS Button Setup
    
    /// Sets up the floating NPS estimation button at bottom left
    private func setupNPSButton() {
        view.addSubview(npsButton)
        
        NSLayoutConstraint.activate([
            npsButton.widthAnchor.constraint(equalToConstant: 40),
            npsButton.heightAnchor.constraint(equalToConstant: 40),
            npsButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            npsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - NPS Estimation
    
    /// Opens the NPS estimation tool
    @objc private func openNPSEstimator() {
        let calculator = SagittaCalculator(diameterArray: dataManager.diameterArray)
        let estimatorVC = SagittaViewController(calculator: calculator)
        
        // Use custom wrapper on Mac for click-outside dismissal
        #if targetEnvironment(macCatalyst)
        estimatorVC.modalPresentationStyle = .overFullScreen
        estimatorVC.view.backgroundColor = .clear
        
        // Add dismissal wrapper for Mac
        let wrapperVC = DismissibleModalViewController(contentViewController: estimatorVC, preferredWidth: 380, preferredHeight: 700)
        present(wrapperVC, animated: true)
        #else
        // On iPad, use formSheet for better width control
        if UIDevice.current.userInterfaceIdiom == .pad {
            estimatorVC.modalPresentationStyle = .formSheet
            estimatorVC.preferredContentSize = CGSize(width: 380, height: 700)
        } else {
            estimatorVC.modalPresentationStyle = .pageSheet
        }
        
        // Allow dismissal by tapping outside on iPad (iOS 13+)
        if #available(iOS 13.0, *) {
            estimatorVC.isModalInPresentation = false
            // Set presentation controller delegate to allow dismissal
            estimatorVC.presentationController?.delegate = self
        }
        
        // Configure sheet presentation for iOS 15+ (iPhone only)
        if #available(iOS 15.0, *), UIDevice.current.userInterfaceIdiom == .phone {
            if let sheet = estimatorVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
        }
        
        present(estimatorVC, animated: true)
        #endif
    }
    
    /// Loads pipe data from JSON file asynchronously
    private func loadPipeDataAsync() {
        guard let url = Bundle.main.url(forResource: "actualData", withExtension: "json") else {
            print("Error: Could not find actualData.json")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([pipeData].self, from: data)
                
                // Update on main thread
                DispatchQueue.main.async {
                    self?.p = jsonData
                    // If a pipe was already selected somehow, refresh the view
                    if let selectedRow = self?.selector.selectedRow(inComponent: 0), selectedRow > 0 {
                        self?.updateWantedData(for: selectedRow)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("Error loading pipe data: \(error)")
                }
            }
        }
    }
    
    /// Updates the wanted array based on selected row
    private func updateWantedData(for row: Int) {
        let selectedPipe = dataManager.diameterArray[row]
        if selectedPipe != "NPS [inches]  OD [mm] OD [in]" {
            wanted = p.filter { $0.Name == selectedPipe }
        } else {
            wanted = []
        }
        tableView.reloadData()
    }
}

struct pipeData: Decodable {
    var Name: String
    let WT_inch: Float
    let WT_mm : Float
    let lb_per_ft : Float
    let kg_per_m: Float
    let Sch_1: String
    let Sch_2: String
}



extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return dataManager.diameterArray.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return dataManager.diameterArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = dataManager.diameterArray[row]
        label.Style17_HeadlineLight()
        label.textAlignment = .center
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        if UIApplication.shared.preferredContentSizeCategory < .extraLarge {
            return 35
            
        } else {
            
            return 50
        }
        
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        SwiftRater.incrementSignificantUsageCount()
        updateWantedData(for: row)
    }
    
}


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wanted.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wanteddata = wanted[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pipeCell", for: indexPath) as! TableViewCell
        
        // Configure cell data
        cell.inches.text = String(format: "%.3f", wanteddata.WT_inch)
        cell.mm.text = String(format: "%.2f", wanteddata.WT_mm)
        cell.lbft.text = String(format: "%.1f", wanteddata.lb_per_ft)
        cell.kgm.text = String(format: "%.1f", wanteddata.kg_per_m)
        cell.sch1.text = wanteddata.Sch_1
        cell.sch2.text = wanteddata.Sch_2
        
        // Let cell configure its own styling efficiently
        cell.updateStyling()
        
        return cell
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

@available(iOS 13.0, *)
extension ViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        // Allow dismissal by clicking/tapping outside the modal
        return true
    }
}
