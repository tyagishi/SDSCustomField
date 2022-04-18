//
//  OptionalDatePicker.swift
//
//  Created by : Tomoaki Yagishita on 2022/04/18
//  © 2022  SmallDeskSoftware
//

import SwiftUI

public struct OptionalDatePicker<DateLabel: View>: View {
    @Environment(\.optionalDatePickerComponent) var pickerComponent
    @Binding var date: Date?
    @State var localDate: Date
    let toggleTitle: String
    let title: DateLabel

    public init(_ hiddenToggleTitle: String, _ dateTitle: (()-> DateLabel), date: Binding<Date?>) {
        self.toggleTitle = hiddenToggleTitle
        self.title = dateTitle()
        self._date = date
        if let date = date.wrappedValue {
            self._localDate = State(wrappedValue: date)
        } else {
            self._localDate = State(wrappedValue: Date())
        }
    }
    
    public var body: some View {
        HStack {
            Toggle(toggleTitle, isOn: Binding<Bool>(get: {
                !(date == nil)
            }, set: { newValue in
                if newValue {
                    date = localDate
                } else {
                    date = nil
                }
            }))
            .labelsHidden()
            DatePicker(selection: $localDate, displayedComponents: pickerComponent) {
                title
            }
            .disabled(date==nil)
            .onChange(of: localDate) { newValue in
                date = localDate
            }
//            .labelsHidden()
//            DatePicker(title, selection: $localDate, displayedComponents: pickerComponent)
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
        OptionalDatePicker("ToggleTitle", {Text("PickerTitle")}, date: .constant(nil))
    }
}
