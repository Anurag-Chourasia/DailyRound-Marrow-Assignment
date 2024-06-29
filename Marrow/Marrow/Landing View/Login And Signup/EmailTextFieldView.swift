//
//  EmailTextFieldView.swift
//  Marrow
//
//  Created by Anurag Chourasia on 29/06/24.
//

import SwiftUI

struct EmailTextFieldView: View {
    @Binding private var email: String
    private var title: String
    
    init(_ text : String,
         email: Binding<String>) {
        self._email = email
        self.title = text
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Image("ProfileIcon")
                .resizable()
                .frame(width: 21, height: 21)
                .padding(.vertical, 16)
                .padding(.horizontal, 19)
            
            TextField("", text: $email)
                .padding(.trailing, 21)
                .placeholder(when: email.isEmpty) {
                    HStack(spacing:0) {
                        Text("Email")
                            .foregroundColor(Color(UIColor(hex: "#242E3D")))
                            .font(.title2)
                    }
                }
                .frame(height: 53)
        }
        
    }
}

#Preview {
    EmailTextFieldView("", email: .constant(""))
}
