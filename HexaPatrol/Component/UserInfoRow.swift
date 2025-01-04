//
//  UserInfoRow.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 30/12/24.
//

import SwiftUI

struct UserInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 14))
        }
        .padding(.vertical, 2)
    }
}
