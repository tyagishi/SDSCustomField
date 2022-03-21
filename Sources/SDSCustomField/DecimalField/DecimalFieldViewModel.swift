//
//  DecimalFieldViewModel.swift
//
//  Created by : Tomoaki Yagishita on 2022/03/21
//  © 2022  SmallDeskSoftware
//

import Foundation
import SwiftUI
import Combine

class DecimalFieldViewModel: ObservableObject {
    var stringSharedWithUpperView: String
    var decimalValue: Decimal
    @Published public private(set) var fieldString: String

    let invalidValueBackground = Color.red.opacity(0.4)
    let acceptableValueBackground = Color.blue.opacity(0.4)
    let acceptedValueBackground = Color.white

    enum FieldState {
        case invalid, acceptable, accepted
    }
    
    @Published var fieldState: FieldState = .accepted

    init(_ initDecimal: Decimal) {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        let str = nf.string(from: initDecimal as NSDecimalNumber)!

        self.stringSharedWithUpperView = str
        self.decimalValue = initDecimal
        self.fieldString = str
        self.fieldState = .accepted // because initially it is synced
        
    }

    func updateFieldState() {
        if !canAccept(fieldString) {
            self.fieldState = .invalid
        } else {
            if fieldString == stringSharedWithUpperView {
                self.fieldState = .accepted
            } else {
                self.fieldState = .acceptable
            }
        }
    }
    
    // MARK: UIs
    var fieldBackgroundColor: Color {
        switch fieldState {
        case .invalid:
            return invalidValueBackground
        case .acceptable:
            return acceptableValueBackground
        case .accepted:
            return acceptedValueBackground
        }
    }
    
    public func updateDecimalFromOutside(_ decimal: Decimal) {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        let str = nf.string(from: decimal as NSDecimalNumber)!

        self.stringSharedWithUpperView = str
        self.decimalValue = decimal
        self.fieldString = str
        self.fieldState = .accepted
    }
    
    public func updateFieldString(_ str: String) {
        self.fieldString = str
        updateFieldState()
    }
    
    // MARK: process input string/value
    let digitsForAcceptability = "0123456789" + NumberFormatter().decimalSeparator + NumberFormatter().groupingSeparator + NumberFormatter().currencySymbol
    let digitsForProcess = "0123456789" + NumberFormatter().decimalSeparator
    
    
    func filteredString(_ str: String) -> String {
        return str.filter({digitsForAcceptability.contains($0)})
    }
    public func canAccept(_ str: String) -> Bool {
        return filteredString(str) == str
    }
    
    func stringForDecimalConversion(_ str: String) -> String {
        return str.filter({digitsForProcess.contains($0)})
    }
    
    // return value:
    //     false: can not accept current field value as Decimal
    //     true : ok
    public func apply() -> Bool {
        guard canAccept(fieldString) else { return false }
        // update fieldString format
        stringSharedWithUpperView = fieldString
        decimalValue = Decimal(string: stringForDecimalConversion(fieldString))!

        let nf = NumberFormatter()
        nf.numberStyle = .currency
        fieldString = nf.string(from: decimalValue as NSDecimalNumber)!
        stringSharedWithUpperView = fieldString
        
        updateFieldState()
        return true
    }
    public func cancel() {
        fieldString = stringSharedWithUpperView
        updateFieldState()
    }
    
}
