//
//  OptionalPicker.swift
//
//  Created by : Tomoaki Yagishita on 2023/02/28
//  © 2023  SmallDeskSoftware
//

import SwiftUI

public struct OptionalPicker<Content: View, NilContent: View, SelectionValue: Hashable, Label: View>: View {
    @Binding var givenSelection: SelectionValue?
    let noSelection: SelectionValue
    let content: Content
    let nilContent: NilContent
    let label: Label

    @State private var selection: SelectionValue

    public init(selection: Binding<SelectionValue?>, noSelection: SelectionValue,
                @ViewBuilder content: @escaping () -> Content,
                @ViewBuilder nilContent: @escaping (() -> NilContent) = { Text("-") },
                @ViewBuilder label: @escaping () -> Label) {

        self._givenSelection = selection
        if let givenInitialSelection = selection.wrappedValue {
            self._selection = State(initialValue: givenInitialSelection)
        } else {
            self._selection = State(initialValue: noSelection)
        }
        self.noSelection = noSelection
        self.content = content()
        self.label = label()
        self.nilContent = nilContent()
    }

    public var body: some View {
        Picker(selection: $selection, content: {
            nilContent.tag(noSelection)
            content
        }, label: {
            label
        })
        .onChange(of: selection) { newValue in
            if newValue == noSelection { givenSelection = nil
            } else { givenSelection = newValue }
        }
    }
}
