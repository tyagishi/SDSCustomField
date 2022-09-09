//
//  OnDemandTextEditor.swift
//
//  Created by : Tomoaki Yagishita on 2022/09/09
//  © 2022  SmallDeskSoftware
//

import SwiftUI
import SDSViewExtension

public struct OnDemandTextEditor: View {
    @Binding var text: String
    let showButtons: Bool

    @State private var textEditorMode = false
    
    public init(text: Binding<String>, showButtons: Bool = false){
        self._text = text
        self.showButtons = showButtons
    }
    
    public var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { textEditorMode.toggle() }, label: {
                    Label(textEditorMode ? "done" : "edit", systemImage: "square.and.pencil")
                })
            }.show(showButtons)
            if textEditorMode {
                ZStack {
                    TextEditor(text: $text)
                    #if os(iOS)
                    Button(action: { textEditorMode.toggle() }, label: { Text("Done") })
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color.blue.opacity(0.2)))
                        .padding(5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    #endif
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    Text(text)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .onTapGesture {
                    textEditorMode.toggle()
                }
            }
        }
    }
}



struct OnDemandTextEditor_Previews: PreviewProvider {
    static var previews: some View {
        OnDemandTextEditor(text: .constant("Text Editor?"))
    }
}
