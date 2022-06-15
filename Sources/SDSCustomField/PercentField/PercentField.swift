//
//  PercentField.swift
//
//  Created by : Tomoaki Yagishita on 2022/05/22
//  © 2022  SmallDeskSoftware
//

import SwiftUI

public struct PercentField<T: StringProtocol>: View {
    let title: T
    @Binding var percentValue: Decimal
    @StateObject var viewModel: PercentFieldViewModel
    @FocusState private var fieldFocus:Bool
    @State private var showButtons: Bool

    public init(_ title: T, value: Binding<Decimal>, showButtons: Bool = false, willCloseNotification: Notification.Name? = nil) {
        self.title = title
        self._percentValue = value
        self._viewModel = StateObject(wrappedValue: PercentFieldViewModel(value.wrappedValue, willCloseNotification: willCloseNotification))
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
        .onChange(of: percentValue, perform: { newValue in
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
            percentValue = viewModel.decimalValue
        }
    }
    
    func cancelInput() {
        viewModel.cancel()
        fieldFocus = false
    }
}
