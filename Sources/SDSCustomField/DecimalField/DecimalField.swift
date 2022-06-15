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
    @FocusState private var fieldFocus:Bool
    @State private var showButtons: Bool

    public init(_ title: T, value: Binding<Decimal>, showButtons: Bool = false, willCloseNotification: Notification.Name? = nil) {
        self.title = title
        self._decimalValue = value
        self._viewModel = StateObject(wrappedValue: DecimalFieldViewModel(value.wrappedValue, willCloseNotification: willCloseNotification))
        self._showButtons = State(wrappedValue: showButtons)
    }
    public var body: some View {
        HStack {
            TextField(title, text: Binding<String>(get: {
                viewModel.fieldString
            }, set: { newValue in
                viewModel.updateFieldString(newValue)
            }))
            .multilineTextAlignment(.trailing)
            .focused($fieldFocus)
            .onSubmit{ apply() }
            .onChange(of: fieldFocus) { focus in
                if !focus { apply() }
            }
            //.background(viewModel.fieldBackgroundColor) // for using inside Table, use overlay instead of background
            .overlay(content: {
                RoundedRectangle(cornerRadius: 3).fill(viewModel.fieldBackgroundColor.opacity(0.5))
            })
            //.textFieldStyle(.plain)
            if showButtons {
                Button(action: {apply()}, label: {
                    Image(systemName: "arrow.turn.down.left")
                })
                .disabled(viewModel.fieldState != .acceptable)
                Button(action: {cancelInput()}, label: {
                    Image(systemName: "arrow.counterclockwise")
                })
                .disabled(fieldFocus != true)
            }
        }
        .onChange(of: decimalValue, perform: { newValue in
            viewModel.updateDecimalFromOutside(newValue)
        })
        .onChange(of: viewModel.forceApply) { newValue in
            if newValue {
                self.apply()
                viewModel.forceApply = false
            }
        }
    }
    
    func apply() {
        if viewModel.apply() {
            decimalValue = viewModel.decimalValue
        }
    }
    
    func cancelInput() {
        viewModel.cancel()
        fieldFocus = false
    }
}

struct DecimalField_Previews: PreviewProvider {
    static var previews: some View {
        DecimalField("example", value: .constant(Decimal(string: "10.0")!))
    }
}
