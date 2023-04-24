//
//  File.swift
//
//  Created by : Tomoaki Yagishita on 2023/04/24
//  © 2023  SmallDeskSoftware
//

import Foundation
import SwiftUI

public struct ClosedRangeField<V: Comparable, F: ParseableFormatStyle>: View where F.FormatInput == V, F.FormatOutput == String {
    @Binding var range: ClosedRange<V>
    @State private var lower: V
    @State private var upper: V
    let format: F
    @State private var valueIsInvalid = false

    public init(range: Binding<ClosedRange<V>>, format: F) {
        self._range = range
        self._lower = State(wrappedValue: range.wrappedValue.lowerBound)
        self._upper = State(wrappedValue: range.wrappedValue.upperBound)
        self.format = format
    }

    public var body: some View {
        HStack {
            TextField("Lower", value: $lower, format: format)
                .redIfInvalid(valueIsInvalid)
                .onChange(of: lower, perform: { newValue in
                    guard newValue < self.range.upperBound else {
                        valueIsInvalid = true
                        return }
                    valueIsInvalid = false
                    self._range.wrappedValue = newValue...(self.range.upperBound)
                })
            Text("~")
            TextField("Upper", value: $upper, format: format)
                .redIfInvalid(valueIsInvalid)
                .onChange(of: upper, perform: { newValue in
                    guard self.range.lowerBound < newValue else {
                        valueIsInvalid = true
                        return }
                    valueIsInvalid = false
                    self._range.wrappedValue = (self.range.lowerBound)...newValue
                })
        }
        .onChange(of: range, perform: { newRange in
            lower = newRange.lowerBound
            upper = newRange.upperBound
        })
    }
}

extension View {
    @ViewBuilder
    func redIfInvalid(_ invalid: Bool) -> some View {
        if invalid {
            if #available(iOS 16, macOS 13, *) {
                self
                    .foregroundColor(.red)
                    .bold()
            } else {
                self
                    .foregroundColor(.red)
            }
        } else {
            self
        }
    }
}
