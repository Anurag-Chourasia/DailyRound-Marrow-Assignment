//
//  ContentView.swift
//  Marrow
//
//  Created by Anurag Chourasia on 29/06/24.
//

import SwiftUI

struct ContentView: View {
    @State var isLoggedIn: Bool = false
//    @State var email : String = ""
    var body: some View {
        Group {
            if isLoggedIn {
                DashboardView(isLoggedIn : $isLoggedIn)
            } else {
                LandingView(isLoggedIn : $isLoggedIn)
            }
        }
//        VStack{
//            Spacer()
//            TextField("hi", text: $email)
//            
//        }
    }
}

#Preview {
    ContentView()
}
