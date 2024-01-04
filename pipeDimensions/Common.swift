//
//  Common.swift
//  pipeDimensions
//
//  Created by Nick Khotenko on 2021-04-03.
//  Copyright © 2021 Nick Khotenko. All rights reserved.
//

import Foundation

import UIKit


var mmPref: Bool = true
var inPref: Bool = false


struct DataManager {

    let diameterArray = ["NPS [inches]  OD [mm]",
                         "1/8  10.3 mm",
                         "1/4  13.7 mm",
                         "3/8  17.1 mm",
                         "1/2  21.3 mm",
                         "3/4  26.7 mm",
                         "1  33.4 mm",
                         "1-1/4  42.2 mm",
                         "1-1/2  48.3 mm",
                         "2  60.3 mm",
                         "2-1/2  73.0 mm",
                         "3  88.9 mm",
                         "3-1/2  101.6 mm",
                         "4  114.3 mm",
                         "5  141.3 mm",
                         "6  168.3 mm",
                         "8  219.1 mm",
                         "10  273.0 mm",
                         "12  323.9 mm",
                         "14  355.6 mm",
                         "16  406.4 mm",
                         "18  457.2 mm",
                         "20  508 mm",
                         "22  559 mm",
                         "24  610 mm",
                         "26  660 mm",
                         "28  711 mm",
                         "30  762 mm",
                         "32  813 mm",
                         "34  864 mm",
                         "36  914 mm",
                         "38  965 mm",
                         "40  1016 mm",
                         "42  1067 mm",
                         "48  1219 mm",
                         "54  1372 mm",
                         "60  1524 mm"
    ]
    
}


extension UIFont {
    
    static func preferredFont(for style: TextStyle, weight: Weight, italic: Bool = false) -> UIFont {

        // Get the style's default pointSize
        let traits = UITraitCollection(preferredContentSizeCategory: .large)
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style, compatibleWith: traits)

        // Get the font at the default size and preferred weight
        var font = UIFont.systemFont(ofSize: desc.pointSize, weight: weight)
        if italic == true {
            font = font.with([.traitItalic])
        }

        // Setup the font to be auto-scalable
        let metrics = UIFontMetrics(forTextStyle: style)


        if #available(macCatalyst 14.0, *) {
            if #available(iOS 14.0, *) {
                if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac{
                    
                    
                    if style == TextStyle.title3 {
                        
                        return metrics.scaledFont(for: font, maximumPointSize: 33.0)
                    }
                    
                    
                    if style == TextStyle.headline {
                        
                        return metrics.scaledFont(for: font, maximumPointSize: 30.0)
                    }
                    
                    
                    if style == TextStyle.subheadline {
                        
                        return metrics.scaledFont(for: font, maximumPointSize: 25.0)
                    }
                    
                    if style == TextStyle.footnote{
                        
                        return metrics.scaledFont(for: font, maximumPointSize: 20.0)
                    }
                    
                    else {
                        
                        return metrics.scaledFont(for: font)
                    }
                    
                }
            } else {
                // Fallback on earlier versions
            }
        } else {
            // Fallback on earlier versions
        }
        
    
   
            if UIDevice.current.userInterfaceIdiom == .pad {
                
                if style == TextStyle.headline {
                    
                    return metrics.scaledFont(for: font, maximumPointSize: 30.0)
                }
                
                
                if style == TextStyle.subheadline {
                    
                    return metrics.scaledFont(for: font, maximumPointSize: 25.0)
                }
                
                if style == TextStyle.footnote{
                    
                    return metrics.scaledFont(for: font, maximumPointSize: 20.0)
                }
                
                else {
                    
                    return metrics.scaledFont(for: font)
                }
                
            }
      
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            
            if style == TextStyle.headline {
                       
                       return metrics.scaledFont(for: font, maximumPointSize: 22.0)
                   }
                   
                   
                   if style == TextStyle.subheadline {
                       
                       return metrics.scaledFont(for: font, maximumPointSize: 20.0)
                   }
                   
                   if style == TextStyle.footnote{
                       
                       return metrics.scaledFont(for: font, maximumPointSize: 18.0)
                   }
            
                   else {
                               
                               return metrics.scaledFont(for: font)
                           }

        }
        
        else {
                    
                    return metrics.scaledFont(for: font)
                }
        
        
       
    }
    
    private func with(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits).union(fontDescriptor.symbolicTraits)) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
}

extension UILabel {
    

    
    func Style17_HeadlineBold(){
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.font = UIFont.preferredFont(for: .headline, weight: .regular, italic: false)

        } else {
            
            self.font = UIFont.preferredFont(for: .title3, weight: .bold, italic: false)

        }
        
    }
    func Style17_HeadlineThin(){
        if UIDevice.current.userInterfaceIdiom == .phone {
            
            self.font = UIFont.preferredFont(for: .headline, weight: .thin, italic: false)
        } else {
            self.font = UIFont.preferredFont(for: .title3, weight: .regular, italic: false)

        }
        
    }
    
    
    func Style17_HeadlineLight(){
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.font = UIFont.preferredFont(for: .headline, weight: .regular, italic: false)
        } else{
            self.font = UIFont.preferredFont(for: .title3, weight: .bold, italic: false)
        }
        
    }
    
    func Style15_Subhead(){
      
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.font = UIFont.preferredFont(for: .subheadline, weight: .thin, italic: false)
        } else {
            self.font = UIFont.preferredFont(for: .headline, weight: .regular, italic: false)

        }
        
    }
    
    func Style13_Footnote(){
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.font = UIFont.preferredFont(for: .footnote, weight: .thin, italic: false)
        } else{
            self.font = UIFont.preferredFont(for: .subheadline, weight: .regular, italic: false)

            
        }

        
    }
    
    
}


