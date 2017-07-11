//
//  StringUtils.swift
//  testreddit
//
//  Created by Alexander on 7/11/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import UIKit
class StringUtils {
    
    /// Colors some part of an attributed string.
    ///
    /// - Parameters:
    ///   - value: color for the part of the string
    ///   - mutableString: the string to be changed
    ///   - highlightedString: the part to be highlighted
    class func addColorHighlightWith(_ color: UIColor, in mutableString: inout NSMutableAttributedString, for highlightedString: String) {
        addAttribute(name: NSForegroundColorAttributeName, value: color, mutableString: &mutableString, highlightedString: highlightedString)
    }
    
    /// Makes some part of an attributed string hightlighted (for example, bold).
    ///
    /// - Parameters:
    ///   - value: font for the highlight
    ///   - mutableString: the string to be changed
    ///   - highlightedString: the part to be highlighted
    class func addHighlightWith(_ font: UIFont, in mutableString: inout NSMutableAttributedString, for highlightedString: String) {
        addAttribute(name: NSFontAttributeName, value: font, mutableString: &mutableString, highlightedString: highlightedString)
    }
    
    /// Changes some part of an attributed string. Performs a search in mutable string to find the part to be changed and changes its parameters.
    ///
    /// - Parameters:
    ///   - name: name of the attribute
    ///   - value: setting for the part of the string
    ///   - mutableString: the string to be changed
    ///   - highlightedString: the part to be changed
    class func addAttribute(name: String, value: Any, mutableString: inout NSMutableAttributedString, highlightedString: String) {
        if let indexStart = mutableString.string.lowercased().range(of: highlightedString.lowercased(), options: .literal)?.lowerBound {
            mutableString.addAttribute(name, value: value, range: NSRange(location: mutableString.string.characters.distance(from: mutableString.string.startIndex, to: indexStart), length: highlightedString.characters.count))
        }
    }
}
