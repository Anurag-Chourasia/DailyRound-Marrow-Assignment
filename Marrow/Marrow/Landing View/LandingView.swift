//
//  LandingView.swift
//  Marrow
//
//  Created by Anurag Chourasia on 28/06/24.
//

import SwiftUI
import CoreData

struct LandingView: View {
    
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        NavigationView{
            
            
            VStack(spacing: 0) {
                
                HStack(spacing: 0) {
                    Spacer()
                    Text("MedBook")
                        .font(.largeTitle)
//                        .padding(.leading, 30)
                    Spacer()
                }
                
                .padding(.vertical, 50)
                
                Image("Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .cornerRadius(100)
                
                Spacer()
                
                HStack(spacing: 0) {
                    Spacer()
                    
                    
                    NavigationLink(destination: SignUpView(isLoggedIn: $isLoggedIn)){
                        Text("Sign Up")
                            .font(.headline)
                            .frame(width:80)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: LoginView(isLoggedIn: $isLoggedIn)){
                        Text("Login")
                            .font(.headline)
                            .frame(width:80)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 50)
            }
            
        }.navigationBarBackButtonHidden()
            .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    LandingView(isLoggedIn: .constant(false))
}
