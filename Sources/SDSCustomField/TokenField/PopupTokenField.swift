//
//  PopupTokenField.swift
//
//  Created by : Tomoaki Yagishita on 2022/04/02
//  © 2022  SmallDeskSoftware
//

import SwiftUI

struct PopupTokenField<Element: SDSTokenProtocol & Hashable & Equatable>: View {
    @Binding var tokens: [Element]
    var tokenCompletion: [Element]
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}
