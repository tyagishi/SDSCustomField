//
//  SDSTokenField.swift
//
//  Created by : Tomoaki Yagishita on 2022/03/22
//  © 2022  SmallDeskSoftware
//

import os
import SwiftUI

public struct SDSTokenField<TokenObject:SDSTokenProtocol & Equatable>: NSViewRepresentable {
    var logger = Logger.init(subsystem: "com.smalldesksoftware.SDSTokenField", category: "SDSTokenField")
    var tokenStyle: NSTokenField.TokenStyle
    var tokenizingCharacterSet: CharacterSet

    @Binding var tokens: [TokenObject]
    var completionDelay: TimeInterval
    let completionTokens:[TokenObject]
    var avoidDuplicate:Bool
    let acceptOnlyCompletion:Bool
    
    public init(tokens: Binding<[TokenObject]>,
                completionTokens:[TokenObject] = [],
                avoidDuplicate:Bool = false,
                acceptOnlyCompletion:Bool = true,  // currently only true is supported
                tokenStyle: NSTokenField.TokenStyle = .default,
                tokenizingCharacterSet: CharacterSet = NSTokenField.defaultTokenizingCharacterSet,
                completionDelay:TimeInterval = NSTokenField.defaultCompletionDelay ) {
        self._tokens = tokens
        self.completionTokens = completionTokens
        self.avoidDuplicate = avoidDuplicate
        self.acceptOnlyCompletion = acceptOnlyCompletion
        self.tokenStyle = tokenStyle
        self.tokenizingCharacterSet = tokenizingCharacterSet
        self.completionDelay = completionDelay
    }
    
    public func makeNSView(context: Context) -> NSTokenField {
        let tokenField = NSTokenField()
        tokenField.tokenStyle = self.tokenStyle
        tokenField.tokenizingCharacterSet = self.tokenizingCharacterSet
        tokenField.completionDelay = self.completionDelay
        tokenField.delegate = context.coordinator
        tokenField.stringValue = self.tokens.map{ $0.displayString }.joined(separator: ",")
        return tokenField
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    public func updateNSView(_ nsView: NSTokenField, context: Context) {
        //print("updateNSView called")
        nsView.stringValue = self.tokens.map{ $0.displayString }.joined(separator: ",")
    }
    
    public class Coordinator: NSObject, NSTokenFieldDelegate {
        var parent: SDSTokenField
        
        init(_ parent: SDSTokenField) {
            self.parent = parent
        }
        
        public func tokenField(_ tokenField: NSTokenField, displayStringForRepresentedObject representedObject: Any) -> String? {
            //print("use displayStringForRepresentedObject")
            if let str = representedObject as? String {
                return str
            }
            if let token = representedObject as? SDSTokenProtocol {
                //print("use TokenProtocol")
                return token.displayString
            }
            return nil
        }
        
        public func tokenField(_ tokenField: NSTokenField, representedObjectForEditing editingString: String) -> Any? {
            if let editingToken = self.parent.completionTokens.filter({ $0.displayString == editingString }).first {
                //print("found editingToken for \(editingString)")
                return editingToken
            }
            //print("not found editingToken for \(editingString)")
            return nil
        }
        
        public func tokenField(_ tokenField: NSTokenField, shouldAdd tokens: [Any], at index: Int) -> [Any] {
            if !self.parent.acceptOnlyCompletion { return tokens }
            return tokens
        }
        
        // provide completion list
        public func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
            //selectedIndex?.pointee = 2 // can choose pre-selected item if necessary
            let predicate = NSPredicate(format: "SELF CONTAINS[c] %@", substring)
            var completionStringArray = parent.completionTokens.compactMap{$0.displayString}.filter{ predicate.evaluate(with: $0)}
            if !self.parent.avoidDuplicate {
                return completionStringArray
            }
            guard let anyTokens = tokenField.objectValue as? [Any] else { return completionStringArray }

            for token in anyTokens {
                if let token = token as? SDSTokenProtocol {
                    if let index = completionStringArray.firstIndex(of: token.displayString) {
                        completionStringArray.remove(at: index)
                    }
                }
            }
            return completionStringArray
        }
        
        public func controlTextDidEndEditing(_ obj: Notification) {
            guard let tokenField = obj.object as? NSTokenField else { return }

            if let strTokens = tokenField.objectValue as? [String] {
                self.parent.logger.debug("processed as String")
                var newToken: [TokenObject] = []
                for token in strTokens {
                    if let index = parent.completionTokens.firstIndex(where: {$0.displayString == token.displayString}) {
                        newToken.append(parent.completionTokens[index])
                    }
                }
                if !parent.tokens.elementsEqual(newToken) {
                    parent.tokens = newToken
                } else {
                    self.parent.logger.debug("processed as TokenObject")
                }
                return
            }
            if let newTokensFromField = tokenField.objectValue as? [TokenObject] {
                self.parent.logger.debug("processed as TokenObject")
                var newToken: [TokenObject] = []
                for token in newTokensFromField {
                    if let index = parent.completionTokens.firstIndex(where: {$0.displayString == token.displayString}) {
                        newToken.append(parent.completionTokens[index])
                    }
                }
                self.parent.logger.debug("change from:\(self.parent.tokens.compactMap({$0.displayString}).joined(separator: ",")) to:\(newTokensFromField.compactMap({$0.displayString}).joined(separator: ","))")
                if !parent.tokens.elementsEqual(newToken, by: {$0.displayString == $1.displayString}) {
                    parent.tokens = newToken
                } else {
                    self.parent.logger.debug("ignore unnecessary change")
                }
                return
            }
            self.parent.logger.critical("unknown type passed to controlTextDidEndEditing")
            return
        }
        
    }

    public typealias NSViewType = NSTokenField
}


