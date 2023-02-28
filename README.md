# SDSCustomField

Custom Field collection for SwiftUI

- OptionalPicker
  nil-capable Picker
```
import SwiftUI
import SDSCustomField

struct ContentView: View {
    @State private var value: String? = nil
    @State private var intValue: Int? = 3
    var body: some View {
        VStack {
            OptionalPicker(selection: $value, noSelection: "-99",
                           content: {
                ForEach(1..<10, id: \.self) { num in
                    Text(num.formatted())
                        .tag(String("\(num)"))
                }
            }, nilContent: { Text("-") },
                           label: { Text("String") })
            Text("value: \(value ?? "nil")")

            OptionalPicker(selection: $intValue, noSelection: -99,
                           content: {
                ForEach(1..<10, id: \.self) { num in
                    Text(num.formatted())
                        .tag(num)
                }
            }, label: { Text("Int") })
            .pickerStyle(.segmented)
            if let intValue = intValue {
                Text("intValue: \(intValue)")
            } else {
                Text("intValue: nil")
            }
        }
        .padding()
    }
}
```


- DecimalField
   TextField for handling Decimal and String

- SubmitField
   TextField will update value only with "return" or focus lose
   
- OptionalDatePicker
   nil-capable DatePicker

- PercentField
   textfield for percent

- TokenField
   NSTokenField alternative
   

## OnDemandTextEditor

at first it is (multi-line) Text. With tapping, it will become TextEditor
