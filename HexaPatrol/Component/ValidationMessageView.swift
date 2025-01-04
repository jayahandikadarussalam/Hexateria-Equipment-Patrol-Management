//
//  ValidationMessageView.swift
//  HexateriaPatrol
//
//  Created by Jaya Handika Darussalam on 18/12/24.
//

import SwiftUI

struct ValidationMessageView: View {
    let condition: Bool
    let message: String
    var body: some View {
        if condition {
            Text(message)
                .font(.footnote)
                .foregroundColor(Color(.systemRed))
                .padding(.top, 4)
                .autocapitalization(.none)
                .textContentType(.newPassword)
                .disableAutocorrection(true)
                .privacySensitive()
        } else {
            EmptyView()
        }
    }
}

#Preview {
    ValidationMessageView(condition: false, message: "Validation")
}
