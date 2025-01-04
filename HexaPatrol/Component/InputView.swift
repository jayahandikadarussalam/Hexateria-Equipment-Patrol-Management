//
//  InputView.swift
//  HexateriaPatrol
//
//  Created by Jaya Handika Darussalam on 18/12/24.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .foregroundColor(Color(.label))
                .fontWeight(.semibold)
                .font(.system(size: 18))
                .autocapitalization(.none)
                .autocorrectionDisabled()
            if isSecureField {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 15))
                    .foregroundColor(Color(.label))
                    .textContentType(.newPassword)
                    .disableAutocorrection(true)
                    .textContentType(.newPassword)

            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 15))
                    .foregroundColor(Color(.label))
            }
            Divider()
                .background(Color(.separator))
        }
    }
}

#Preview {
    InputView(text: .constant(""),
              title: "Email Address",
              placeholder: "name@example.com")
}
