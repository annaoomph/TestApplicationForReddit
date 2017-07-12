//
//  StringUtils.swift
//  testreddit
//
//  Created by Anna on 7/11/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import UIKit

/// An extension on NsMtableAttributedString, allowing easily color or highlight its parts.
extension NSMutableAttributedString {
    
    /// Colors some part of an attributed string.
    ///
    /// - Parameters:
    ///   - value: color for the part of the string.
    ///   - mutableString: the string to be changed.
    ///   - highlightedString: the part to be highlighted.
    func addColorHighlightWith(_ color: UIColor, for highlightedString: String) {
        addAttribute(name: NSForegroundColorAttributeName, value: color, highlightedString: highlightedString)
    }
    
    /// Makes some part of an attributed string hightlighted (for example, bold).
    ///
    /// - Parameters:
    ///   - value: font for the highlight.
    ///   - mutableString: the string to be changed.
    ///   - highlightedString: the part to be highlighted.
    func addHighlightWith(_ font: UIFont, for highlightedString: String) {
        addAttribute(name: NSFontAttributeName, value: font, highlightedString: highlightedString)
    }
    
    /// Changes some part of an attributed string. Performs a search in mutable string to find the part to be changed and changes its parameters.
    ///
    /// - Parameters:
    ///   - name: name of the attribute that needs to be changed.
    ///   - value: setting for the part of the string.
    ///   - mutableString: the string to be changed.
    ///   - highlightedString: the part to be changed.
    func addAttribute(name: String, value: Any, highlightedString: String) {
        if let indexStart = self.string.lowercased().range(of: highlightedString.lowercased(), options: .literal)?.lowerBound {
            self.addAttribute(name, value: value, range: NSRange(location: self.string.characters.distance(from: self.string.startIndex, to: indexStart), length: highlightedString.characters.count))
        }
    }
}
