//
//  PasswordTextFieldView.swift
//  Marrow
//
//  Created by Anurag Chourasia on 28/06/24.
//

import Foundation
import SwiftUI

struct PasswordTextFieldView: View {
    
    @Binding private var text: String
    @State private var isSecured: Bool = true
    @State private var placeholderText: String
    @State private var mandatoryField : Bool
    private var title: String
    
    init(_ title: String,
         text: Binding<String>,
         placeholderText : String,
         mandatoryField: Bool) {
        self.title = title
        self._text = text
        self.placeholderText = placeholderText
        self.mandatoryField = mandatoryField
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isSecured {
                    SecureField(title, text: $text)
                        .padding(.trailing, 21)
                        .placeholder(when: text.isEmpty) {
                            HStack(spacing:0){
                                Text(placeholderText)
                                    .foregroundColor(Color(UIColor(hex: "#242E3D")))
                                    .font(.title2)
                                if mandatoryField{
                                    Text("*")
                                        .foregroundColor(Color.red)
                                        .font(.title2)
                                }
                            }
                        }
                        .frame(height: 53)
                        .padding(.leading,19)
                } else {
                    TextField(title, text: $text)
                        .padding(.trailing, 21)
                        .placeholder(when: text.isEmpty) {
                            HStack(spacing:0){
                                Text(placeholderText)
                                    .foregroundColor(Color(UIColor(hex: "#242E3D")))
                                    .font(.title2)
                                if mandatoryField{
                                    Text("*")
                                        .foregroundColor(Color.red)
                                        .font(.title2)
                                }
                            }
                        }
                        .frame(height: 53)
                        .padding(.leading,19)
                }
            }.padding(.trailing, 32)
            
            HStack(spacing: 0) {
                Button(action: {
                    isSecured.toggle()
                }) {
                        Image(systemName: isSecured ? "eye" : "eye.slash")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                            .frame(width: 20,
                                   height:20)
                            .padding(.leading, 20)
                            .padding(.trailing, 22.58)
                }
            }
        }
    }
}
