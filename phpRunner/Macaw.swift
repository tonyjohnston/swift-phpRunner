//
//  Macaw.swift
//  Macaw
//
//  Created by Mac Mini on 1/18/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa
import Foundation

class Macaw {
    var textView : NSTextView
    
    struct color {
        static let normal     = [NSForegroundColorAttributeName: NSColor.black]
        static let comment    = [NSForegroundColorAttributeName: NSColor(red: 0.00, green: 0.50, blue: 0.00, alpha: 1.0)] // green
        static let keyword    = [NSForegroundColorAttributeName: NSColor(red: 0.75, green: 0.20, blue: 0.75, alpha: 1.0)] // magenta
        static let identifier = [NSForegroundColorAttributeName: NSColor(red: 0.33, green: 0.20, blue: 0.66, alpha: 1.0)] // purple
        static let symbol     = [NSForegroundColorAttributeName: NSColor(red: 0.75, green: 0.50, blue: 0.00, alpha: 1.0)] // orange
        static let type       = [NSForegroundColorAttributeName: NSColor(red: 0.00, green: 0.66, blue: 0.66, alpha: 1.0)] // cyan
        static let literal    = [NSForegroundColorAttributeName: NSColor(red: 0.66, green: 0.00, blue: 0.00, alpha: 1.0)] // red
        static let number     = [NSForegroundColorAttributeName: NSColor(red: 0.00, green: 0.00, blue: 0.75, alpha: 1.0)] // blue
        static let attribute  = [NSForegroundColorAttributeName: NSColor(red: 1.00, green: 0.33, blue: 0.00, alpha: 1.0)] // orange
    }
    
    struct regex {
        static let keywords      = "\\b(and|include_once|list|abstract|global|private|echo|interface|as|static|endswitch|array|null|if|endwhile|or|const|for|endforeach|self|var|while|isset|public|protected|exit|foreach|throw|elseif|include|__FILE__|empty|require_once|do|xor|return|parent|clone|use|__CLASS__|__LINE__|else|break|print|eval|new|catch|__METHOD__|case|exception|default|die|require|__FUNCTION__|enddeclare|final|try|switch|continue|endfor|endif|declare|unset|true|false|trait|goto|instanceof|insteadof|__DIR__|__NAMESPACE__|yield|finally)\\b"
        static let types         = "\\b(Int|Float|Double|String|Bool|Character|Void|U?Int(8|16|32|64)?|Array|Dictionary|(Array)(<.*>)|(Dictionary)(<.*>)|(Optional)(<.*>)|(protocol)(<.*>))\\b"
        static let stringLiteral = "(\".*\")"
        static let numberLiteral = "\\b([0-9]*(\\.[0-9]*)?)\\b"
        static let symbols       = "(\\+|-|\\*|/|=|\\{|\\}|\\[|\\]|\\(|\\))"
        static let identifiers   = "(\\B\\$[0-9]+|\\b[\\w^\\d][\\w\\d]*\\b|\\B`[\\w^\\d][\\w\\d]*`\\B)"
        static let attributes    = "((@)(\\B\\$[0-9]+|\\b[\\w^\\d][\\w\\d]*\\b|\\B`[\\w^\\d][\\w\\d]*`\\B))(\\()(.*)\\)"
        static let commentLine   = "(//.*)"
        static let commentBlock  = "(/\\*.*\\*/)" // Not working, regex must search block not line
    }
    
    let patterns = [
        regex.commentLine   : color.comment,
        regex.commentBlock  : color.comment,
        regex.stringLiteral : color.literal,
        regex.numberLiteral : color.number,
        regex.keywords      : color.keyword,
        regex.types         : color.type,
        regex.attributes    : color.attribute,
        regex.identifiers   : color.identifier
    ]
    
    init(_ textView: NSTextView) {
        self.textView = textView
    }
    
    // Colorize all
    func colorize() {
        let all = textView.string ?? ""
        let range = NSString(string: textView.string!).range(of: all)
        colorize(range)
    }
    
    // Colorize range
    func colorize(_ range: NSRange) {
        var extended = NSUnionRange(range, NSString(string: textView.string!).lineRange(for: NSMakeRange(range.location, 0)))
        extended = NSUnionRange(range, NSString(string: textView.string!).lineRange(for: NSMakeRange(NSMaxRange(range), 0)))
        
        for (pattern, attribute) in patterns {
            applyStyles(extended, pattern, attribute)
        }
    }
    
    func applyStyles(_ range: NSRange, _ pattern: String, _ attribute: [String: Any]) {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        regex?.enumerateMatches(in: textView.string!, options: [], range: range) {
            match, flags, stop in
            
            let matchRange = match?.rangeAt(1)
            self.textView.textStorage?.addAttributes(attribute, range: matchRange!)
            let maxRange = matchRange!.location + matchRange!.length
            
            if maxRange + 1 < (self.textView.textStorage?.length)! {
                self.textView.textStorage?.addAttributes(color.normal, range: NSMakeRange(maxRange, 1))
            }
        }
    }
}


// End
