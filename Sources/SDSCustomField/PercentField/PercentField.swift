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
    let willCloseNotificationName: Notification.Name?

    public init(_ title: T, value: Binding<Decimal>, showButtons: Bool = false, willCloseNotification: Notification.Name? = nil) {
        self.title = title
        self._percentValue = value
        self._viewModel = StateObject(wrappedValue: PercentFieldViewModel(value.wrappedValue))
        self._showButtons = State(wrappedValue: showButtons)
        self.willCloseNotificationName = willCloseNotification
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
            .overlay(content: {
                RoundedRectangle(cornerRadius: 3).fill(viewModel.fieldBackgroundColor.opacity(0.5))
            })
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
        .optionalOnReceive(notificationName: willCloseNotificationName, action: { newValue in
            self.apply()
        })
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
