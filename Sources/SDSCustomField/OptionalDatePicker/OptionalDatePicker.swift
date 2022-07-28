//
//  OptionalDatePicker.swift
//
//  Created by : Tomoaki Yagishita on 2022/04/18
//  © 2022  SmallDeskSoftware
//

import SwiftUI

public struct OptionalDatePicker<ToggleLabel: View>: View {
    @Environment(\.optionalDatePickerComponent) var pickerComponent
    @Binding var date: Date?
    @State var localDate: Date
    let toggleLabel: ToggleLabel
    let dateTitle: String

    public init(_ toggleLabel: (()-> ToggleLabel), _ hiddenDateTitle: String, date: Binding<Date?>) {
        self.toggleLabel = toggleLabel()
        self.dateTitle = hiddenDateTitle
        self._date = date
        if let date = date.wrappedValue {
            self._localDate = State(wrappedValue: date)
        } else {
            self._localDate = State(wrappedValue: Date())
        }
    }
    
    public var body: some View {
        HStack {
            Toggle(isOn: Binding<Bool>(get: {
                !(date == nil)
            }, set: { newValue in
                if newValue {
                    date = localDate
                } else {
                    date = nil
                }
            }), label: {
                toggleLabel
                    .opacity(date == nil ? 0.5 : 1.0)
            })
            DatePicker(selection: $localDate, displayedComponents: pickerComponent) {
                Text(dateTitle)
                    .opacity(date == nil ? 0.5 : 1.0)
            }
            .disabled(date==nil)
            .onChange(of: localDate) { newValue in
                guard  Date.distantPast < newValue &&
                        newValue < Date.distantFuture else { return }
                date = localDate
            }
            .labelsHidden()
        }

    }
}

extension OptionalDatePicker {
    public func displayComponents(_ components: DatePickerComponents) -> some View {
        self.environment(\.optionalDatePickerComponent, components)
    }
}

public struct OptionalDatePickerComponentKey: EnvironmentKey {
    public typealias Value = DatePickerComponents
    static public var defaultValue: DatePickerComponents = [.date, .hourAndMinute]
}

extension EnvironmentValues {
    var optionalDatePickerComponent: DatePickerComponents {
        get {
            return self[OptionalDatePickerComponentKey.self]
        }
        set {
            self[OptionalDatePickerComponentKey.self] = newValue
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        OptionalDatePicker({Text("ToggleTitle")}, "PickerTitle", date: .constant(nil))
    }
}
