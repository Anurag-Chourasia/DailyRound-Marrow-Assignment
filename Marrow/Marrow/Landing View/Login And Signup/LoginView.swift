//
//  LoginView.swift
//  Marrow
//
//  Created by Anurag Chourasia on 28/06/24.
//

import SwiftUI

struct LoginView: View {
    @Environment (\.presentationMode) var presentationMode
    
    @State private var email: String = ""
    @State private var password: String = ""
    @Binding var isLoggedIn: Bool
    @State private var errorMessage: String = ""
    @State private var showAlert = false
    @State private var isLoading = false
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistenceController = PersistenceController.shared
    
    var body: some View {
        
        NavigationView{
            
            GeometryReader{ geometry in
                
                ScrollView{
                    
                    ZStack{
                        
                        VStack(spacing:0){
                            
                            HStack(spacing:0){
                                
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Image(systemName: "chevron.left")
                                        .renderingMode(.template)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 15,height: 15)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 30)
                                                .stroke(Color.blue, lineWidth: 2)
                                        )
                                }
                                .padding(.top,20)
                                .padding(.leading,20)
                                
                                Spacer()
                            }
                            .padding(.bottom,30)
                            
                            HStack(spacing:0){
                                
                                Text("Welcome,\nlog in to continue")
                                    .font(.title)
                                    .padding(.leading, 30)
                                
                                Spacer()
                            }
                            .padding(.bottom,50)
                            
                            
                            HStack(spacing:0){
                                EmailTextFieldView("", email: $email)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 26.5)
                                    .stroke(Color(UIColor(hex: "#DADADA")), lineWidth: 1)
                            )
                            .padding(.bottom,14)
                            .padding(.horizontal,34)
                            
                            HStack(spacing: 0) {
                                PasswordTextFieldView("",
                                              text: $password,
                                              placeholderText: "Password",
                                              mandatoryField: true)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 26.5)
                                    .stroke(Color(UIColor(hex: "#DADADA")), lineWidth: 1)
                            )
                            .padding(.bottom,20)
                            .padding(.horizontal,34)
                            
                            
                            HStack(spacing: 0) {
                                
                                Button(action: {
                                    isLoading = true
                                    if !email.isEmpty && !password.isEmpty{
                                        showAlert = !isValidEmail(email)
                                        if !showAlert{
                                            if isValidPassword(password){
                                                errorMessage = ""
                                                if let existingUser = persistenceController.fetchUser(email: email.lowercased()) {
                                                    
                                                    if existingUser.password == password{
                                                        
                                                        isLoading = false
                                                        
                                                        UserDefaults.standard.setValue(email.lowercased(), forKey: "LoggedInUserEmail")
                                                        persistenceController.logInUser(email: email.lowercased())
                                                        withAnimation(.easeInOut){
                                                            isLoggedIn = true
                                                        }
                                                        
                                                    }else{
                                                        showAlert = true
                                                        errorMessage = "Wrong Password"
                                                    }
                                                }else{
                                                    showAlert = true
                                                    errorMessage = "Sign Up first to login in"
                                                }
                                                
                                            }else{
                                                showAlert = true
                                                errorMessage = "Password Must contain 8 characters minimum including 1 alphabet, 1 number and 1 special character like @,#"
                                            }
                                        }else{
                                            errorMessage = "Enter a valid email"
                                            showAlert = true
                                        }
                                    }else{
                                        errorMessage = "Fields cannot be empty"
                                        showAlert = true
                                    }
                                    
                                }){
                                    Text("Login")
                                        .font(.custom("Montserrat-Bold", size: 16))
                                        .frame(height: 55)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.white)
                                        .background(RoundedRectangle(cornerRadius: 26.5))
                                }
                                .alert(isPresented: $showAlert) {
                                    Alert(title: Text("Error"),
                                          message: Text("\(errorMessage)"),
                                          dismissButton: .default(Text("OK"),
                                                                  action: {
                                        isLoading = false
                                    }))
                                }
                            }
                            .foregroundColor(Color(UIColor(hex: "#07629B")))
                            .padding(.bottom,18)
                            .padding(.leading,33)
                            .padding(.trailing,33)
                            
                            
                            Spacer()
                            
                            
                        }
                        .opacity(isLoading ? 0.2 : 1.0)
                        
                        
                        if isLoading {
                            VStack{
                                Spacer()
                                ProgressView("Loading.")
                                
                                    .progressViewStyle(CircularProgressViewStyle())
                                Spacer()
                            }
                            .frame(width: geometry.size.width)
                            .background(Color(UIColor(hex: "#FFFFFF")).opacity(0.5))
                        }
                    }
                }.ignoresSafeArea(.keyboard)
            }
        }.navigationBarBackButtonHidden()
            .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
