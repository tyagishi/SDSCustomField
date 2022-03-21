//
//  DecimalField.swift
//
//  Created by : Tomoaki Yagishita on 2022/03/21
//  © 2022  SmallDeskSoftware
//

import SwiftUI

public struct DecimalField<T: StringProtocol>: View {
    let title: T
    @Binding var decimalValue: Decimal
    @StateObject var viewModel: DecimalFieldViewModel
    public init(_ title: T, value: Binding<Decimal>) {
        self.title = title
        self._decimalValue = value
        self._viewModel = StateObject(wrappedValue: DecimalFieldViewModel(value.wrappedValue))
    }
    public var body: some View {
        HStack {
            TextField(title, text: Binding<String>(get: {
                viewModel.fieldString
            }, set: { newValue in
                viewModel.updateFieldString(newValue)
            }))
            .onSubmit { apply() }
            .background(viewModel.fieldBackgroundColor)
            .textFieldStyle(.plain)
            Button(action: {apply()}, label: {
                Image(systemName: "arrow.turn.down.left")
            })
            Button(action: {cancelInput()}, label: {
                Image(systemName: "x.circle")
            })
        }
    }
    
    func apply() {
        if viewModel.apply() {
            decimalValue = viewModel.decimalValue
        }
    }
    
    func cancelInput() {
        viewModel.cancel()
    }
}

struct DecimalField_Previews: PreviewProvider {
    static var previews: some View {
        DecimalField("example", value: .constant(Decimal(string: "10.0")!))
    }
}
