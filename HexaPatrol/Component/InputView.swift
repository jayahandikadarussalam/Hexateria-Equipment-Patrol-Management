//
//  InputView.swift
//  HexateriaPatrol
//
//  Created by Jaya Handika Darussalam on 18/12/24.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    @State private var showPassword: Bool = false
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
                .disableAutocorrection(true)

            HStack {
                if isSecureField && !showPassword {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: 15))
                        .foregroundColor(Color(.label))
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                } else {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 15))
                        .foregroundColor(Color(.label))
                        .textContentType(.none)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }

                if isSecureField {
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
            }

            Divider()
                .background(Color(.separator))
        }
    }
}

#Preview {
    InputView(
        text: .constant(""),
        title: "Password",
        placeholder: "Enter your password",
        isSecureField: true
    )
}
