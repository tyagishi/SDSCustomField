//
//  SubmitField.swift
//
//  Created by : Tomoaki Yagishita on 2022/07/11
//  © 2022  SmallDeskSoftware
//

import SwiftUI

public enum FieldState {
    case valid
    case invalid
}

struct SubmitFieldAlignmentKey: EnvironmentKey {
    typealias Value = TextAlignment
    static var defaultValue: TextAlignment = .leading
}

extension EnvironmentValues {
    var submitFieldAlignment: TextAlignment {
        get {
            return self[SubmitFieldAlignmentKey.self]
        }
        set {
            self[SubmitFieldAlignmentKey.self] = newValue
        }
    }
}

public struct SubmitField: View {
    @Environment(\.submitFieldAlignment) var textAlignment
    let label: String
    @Binding var text: String
    let fieldState: FieldState
    let notification: Notification.Name?

    @State private var fieldString: String = ""
    @FocusState private var focus: Bool
    
    public init(_ label: String,_ text: Binding<String>,_ fieldState: FieldState,_ notificationName: Notification.Name? = nil) {
        self.label = label
        self._text = text
        self.fieldState = fieldState
        self.notification = notificationName
    }
    
    public var body: some View {
        TextField(label, text: $fieldString)
            .onSubmit {
                text = fieldString
            }
            .multilineTextAlignment(textAlignment)
            .focused($focus)
            .onChange(of: focus) { newValue in
                if newValue == false { // loose focus
                    text = fieldString
                }
            }
            .onAppear {
                fieldString = text
            }
            .background {
                if fieldState == .invalid {
                    Color.red
                }
            }
            .textFieldStyle(.plain)
            .overlay {
                if fieldState == .invalid {
                    Text("(invalid)").font(.footnote).foregroundColor(Color.white).frame(maxWidth: .infinity, alignment: overlayAlignment).padding(3)
                }
            }
            .optionalOnReceive(notificationName: notification) {_ in
                text = fieldString
            }
            .onChange(of: text) { newValue in
                fieldString = newValue
            }
    }
    
    var overlayAlignment: Alignment {
        switch textAlignment {
        case .leading:
            return .trailing
        case .trailing:
            return .leading
        default:
            return .trailing
        }
    }
}

extension SubmitField {
    public func textAlignment(_ alignment: TextAlignment) -> some View {
        self
            .environment(\.submitFieldAlignment, alignment)
    }
}


struct SubmitField_Previews: PreviewProvider {
    static var previews: some View {
        SubmitField("label", .constant("Hello world"), .valid)
    }
}
