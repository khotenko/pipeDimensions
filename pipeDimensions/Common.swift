//
//  Common.swift
//  pipeDimensions
//
//  Created by Nick Khotenko on 2021-04-03.
//  Copyright © 2021 Nick Khotenko. All rights reserved.
//

import Foundation

import UIKit


var mmBold = true


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
        self.font = UIFont.preferredFont(for: .headline, weight: .regular, italic: false)
        
    }
    func Style17_HeadlineThin(){
        self.font = UIFont.preferredFont(for: .headline, weight: .thin, italic: false)
        
    }
    
    
    func Style17_HeadlineLight(){
        self.font = UIFont.preferredFont(for: .headline, weight: .regular, italic: false)
        
    }
    
    func Style15_Subhead(){
        self.font = UIFont.preferredFont(for: .subheadline, weight: .thin, italic: false)
        
    }
    
    func Style13_Footnote(){
        self.font = UIFont.preferredFont(for: .footnote, weight: .thin, italic: false)

        
    }
    
    
}


