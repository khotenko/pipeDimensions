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
    
    

    
    let defaults = UserDefaults.standard
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            
            
            

            if defaults.bool(forKey: "mmBold") == true {
                
                inches.Style15_Subhead()
                mm.Style17_HeadlineBold()
                
            }
            
            if defaults.bool(forKey: "mmBold") == false {
                inches.Style17_HeadlineBold()
                mm.Style15_Subhead()
                
                
                
            }
            lbft.Style15_Subhead()
            kgm.Style15_Subhead()
            sch1.Style13_Footnote()
            sch2.Style13_Footnote()
            
            
            if UIApplication.shared.preferredContentSizeCategory < .extraLarge {
                
                topSpace.constant = -8
                bottomSpace.constant = 8
            }
            
            else {
                topSpace.constant = -15
                bottomSpace.constant = 15
                
            }
            
            
            
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            if UIApplication.shared.preferredContentSizeCategory < .extraLarge {
                
                topSpace.constant = -10
                bottomSpace.constant = 10
                
            }
            
            else {
                topSpace.constant = -20
                bottomSpace.constant = 20
                
            }
            
            
            if defaults.bool(forKey: "mmBold") == true {
                
                inches.Style17_HeadlineThin()
                mm.Style17_HeadlineBold()
                
            }
            
            if defaults.bool(forKey: "mmBold") == false {
                
                inches.Style17_HeadlineBold()
                mm.Style17_HeadlineThin()
                
                
            }
            
            
            lbft.Style17_HeadlineThin()
            kgm.Style17_HeadlineThin()
            sch1.Style15_Subhead()
            sch2.Style15_Subhead()
            
        }
        
        if #available(iOS 14.0, *) {
            if UIDevice.current.userInterfaceIdiom == .mac {
                
                if UIApplication.shared.preferredContentSizeCategory < .extraLarge {
                    
                    topSpace.constant = -10
                    bottomSpace.constant = 10
                    
                }
                
                else {
                    topSpace.constant = -20
                    bottomSpace.constant = 20
                    
                }
                
                
                if defaults.bool(forKey: "mmBold") == true {
                    
                    inches.Style17_HeadlineThin()
                    mm.Style17_HeadlineBold()
                    
                }
                
                if defaults.bool(forKey: "mmBold") == false {
                    
                    inches.Style17_HeadlineBold()
                    mm.Style17_HeadlineThin()
                    
                    
                }
                
                
                lbft.Style17_HeadlineThin()
                kgm.Style17_HeadlineThin()
                sch1.Style15_Subhead()
                sch2.Style15_Subhead()
                
            }
        } else {
            // Fallback on earlier versions
        }
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        
        
        
    }
    
    
    
}
