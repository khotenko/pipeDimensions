//
//  TableViewCell.swift
//  pipeDimensions
//
//  Created by Nick Khotenko on 2020-06-08.
//  Copyright © 2020 Nick Khotenko. All rights reserved.
//

import UIKit




class TableViewCell: UITableViewCell {
    
    @IBOutlet var inches: UILabel!
    @IBOutlet var mm: UILabel!
    @IBOutlet var lbft: UILabel!
    @IBOutlet var kgm: UILabel!
    @IBOutlet var sch1: UILabel!
    @IBOutlet var sch2: UILabel!
    @IBOutlet var mainStackView: UIStackView!
    @IBOutlet var ContentView: UIView!
    @IBOutlet var SchStackView: UIStackView!
    @IBOutlet var bottomSpace: NSLayoutConstraint!
    @IBOutlet var topSpace: NSLayoutConstraint!
    
    // Cache last applied preference to avoid redundant styling
    private var lastMmBoldState: Bool?
    
    let defaults = UserDefaults.standard
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set up spacing constraints based on device and accessibility settings
        configureSpacing()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset cache on reuse to ensure fresh styling check
        lastMmBoldState = nil
    }
    
    /// Configures spacing constraints based on device type and accessibility settings
    private func configureSpacing() {
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        let isLargeText = UIApplication.shared.preferredContentSizeCategory >= .extraLarge
        
        if isPhone {
            topSpace.constant = isLargeText ? -15 : -8
            bottomSpace.constant = isLargeText ? 15 : 8
        } else {
            // iPad and Mac
            topSpace.constant = isLargeText ? -20 : -10
            bottomSpace.constant = isLargeText ? 20 : 10
        }
    }
    
    /// Updates cell styling based on current preferences - call this on cell configuration
    func updateStyling() {
        let currentMmBold = defaults.bool(forKey: "mmBold")
        
        // Skip if styling hasn't changed since last application
        if lastMmBoldState == currentMmBold {
            return
        }
        
        lastMmBoldState = currentMmBold
        applyStyling(mmBold: currentMmBold)
    }
    
    /// Applies font styling to all labels based on preference
    private func applyStyling(mmBold: Bool) {
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        
        if isPhone {
            // Phone styling
            if mmBold {
                inches.Style15_Subhead()
                mm.Style17_HeadlineBold()
            } else {
                inches.Style17_HeadlineBold()
                mm.Style15_Subhead()
            }
            lbft.Style15_Subhead()
            kgm.Style15_Subhead()
            sch1.Style13_Footnote()
            sch2.Style13_Footnote()
        } else {
            // iPad/Mac styling
            if mmBold {
                inches.Style17_HeadlineThin()
                mm.Style17_HeadlineBold()
            } else {
                inches.Style17_HeadlineBold()
                mm.Style17_HeadlineThin()
            }
            lbft.Style17_HeadlineThin()
            kgm.Style17_HeadlineThin()
            sch1.Style15_Subhead()
            sch2.Style15_Subhead()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        
        
        
    }
    
    
    
}
