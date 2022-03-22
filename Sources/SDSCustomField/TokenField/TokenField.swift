//
//  TokenField.swift
//
//  Created by : Tomoaki Yagishita on 2021/04/09
//  © 2021  SmallDeskSoftware
//

import SwiftUI
import SwiftUI
//import SDSViewExtension

public protocol SDSTokenProtocol {
    var displayString: String { get }
}
// <Element: SDSTokenProtocol>
public struct TokenField<Element: SDSTokenProtocol & Hashable & Equatable>: View {
    @Binding var tokens: [Element]
    var tokenCompletion: [Element]
    // for remove operation
    @State var selectedTokens: [Element] = []
    @State var newTokenString:String = ""

    @State private var suggestedTokens: [Element] = []
    @State private var selectedSuggestedTokenIndex: Int = -1
    
    public init(_ tokens: Binding<[Element]>, suggestTokens: [Element] = []) {
        self._tokens = tokens
        self.tokenCompletion = suggestTokens
    }
    
    public var body: some View {
        let tokenBinding = Binding<String>(get: {
            return newTokenString
        }, set: { newValue in
            self.newTokenString = newValue
            suggestedTokens = tokenCompletion.filter( {$0.displayString.contains(newTokenString)} ).filter( {!tokens.contains($0)})
            if suggestedTokens.count > 0 {
                selectedSuggestedTokenIndex = 0
            } else {
                selectedSuggestedTokenIndex = -1
            }
        })
        return VStack {
            HStack {
                ForEach(tokens, id:\.self) { token in
                    TokenLabel(token, selectedTokens: $selectedTokens)
                }
                TextField("type here...", text: tokenBinding, onCommit: {
                    if (selectedSuggestedTokenIndex < 0 ) { return } // ignore onCommit without selection
                    let selectedToken = suggestedTokens[selectedSuggestedTokenIndex]
                    tokens.append(selectedToken)
                    clearSuggestion()
                })
                .background(Color.clear)
                Button(action: {
                    for selected in selectedTokens {
                        if let index = tokens.firstIndex(of: selected) {
                            tokens.remove(at: index)
                        }
                    }
                }, label: {
                    Image(systemName: "trash")
                })
                .keyboardShortcut(.delete, modifiers: .command)
            }
            .background(RoundedRectangle(cornerRadius: 2).fill(.white))
            if suggestedTokens.count > 0 {
                SuggestionLabels(suggestedTokens, selectionIndex: $selectedSuggestedTokenIndex) { selected in
                    tokens.append(selected)
                    clearSuggestion()
                }
            }
        }
    }
    
    func clearSuggestion() {
        newTokenString = ""
        suggestedTokens = []
        selectedSuggestedTokenIndex = -1
    }
}

struct SuggestionLabels<Element: SDSTokenProtocol & Hashable & Equatable>: View {
    let suggestTokens: [Element]
    @Binding var selectedIndex: Int
    let onCommit: ((Element) -> Void)?
    
    init(_ suggestions: [Element], selectionIndex: Binding<Int>,  onCommit: ((Element)->Void)? = nil ){
        self.suggestTokens = suggestions
        self._selectedIndex = selectionIndex
        self.onCommit = onCommit
    }
    var body: some View {
        ScrollView(.horizontal) {
            ScrollViewReader { scrollProxy in
                HStack {
                    Button(action: {
                        if selectedIndex > 0 {
                            selectedIndex -= 1
                            scrollProxy.scrollTo(selectedIndex)
                        }
                    }, label: {
                        Image(systemName: "arrow.left")
                    })
                    .keyboardShortcut(.leftArrow, modifiers: [])
                    ForEach(Array(zip(suggestTokens.indices, suggestTokens)), id:\.0) { offset, element in
                        Text(element.displayString)
                            .underline(offset == selectedIndex)
                            .onTapGesture {
                                self.onCommit?(element)
                            }
                    }
                    Button(action: {
                        if selectedIndex < suggestTokens.count - 1 {
                            selectedIndex += 1
                            scrollProxy.scrollTo(selectedIndex)
                        }
                        
                    }, label: {
                        Image(systemName: "arrow.right")
                    })
                    .keyboardShortcut(.rightArrow, modifiers: [])
                }
            }
        }
    }
}


struct TokenLabel<Element: SDSTokenProtocol & Equatable>: View {
    let str: Element
    @Binding var selectedTokens: [Element]
    
    init(_ str: Element, selectedTokens: Binding<[Element]>) {
        self.str = str
        self._selectedTokens = selectedTokens
    }
    
    var body: some View {
        Group {
            Text(str.displayString)
                .padding(1)
                .padding(.horizontal, 3)
                .foregroundColor(Color.white)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.blue.opacity(selectedTokens.contains(str) ? 0.5 : 0.6)))
                .overlay(
                    RoundedRectangle(cornerRadius: 5).stroke((selectedTokens.contains(str) ? Color.accentColor : Color.clear), lineWidth: 5)
                )
//                .overlay({
//                    RoundedRectangle(cornerRadius: 5).stroke(Color.accentColor, lineWidth: 5)
//                    //stroke(Color.access, lineWidth: 3) //.stroke((selectedTokens.contains(str) ? Color.accentColor : .clear), lineWidth: 3)
//                })
                //.if(selectedTokens.contains(str)) { $0.overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.accentColor, lineWidth: 3)) }
        }
        .onTapGesture {
            if let index = selectedTokens.firstIndex(of: str) {
                selectedTokens.remove(at: index)
            } else {
                selectedTokens.append(str)
            }
        }
    }
}

extension String: SDSTokenProtocol {
    public var displayString: String {
        self
    }
}

struct TokenFieldView_Previews: PreviewProvider {
    static var previews: some View {
        TokenField(.constant(["One", "Two"]), suggestTokens: ["Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine"] )
    }
}
