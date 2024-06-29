//
//  MarrowApp.swift
//  Marrow
//
//  Created by Anurag Chourasia on 28/06/24.
//

import SwiftUI

@main
struct MarrowApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            let userEmail = UserDefaults.standard.value(forKey: "LoggedInUserEmail") as? String ?? ""
            
            if let fetchUser = persistenceController.fetchUser(email: userEmail.lowercased()){
                if fetchUser.isSuccessfullyLoggedIn{
                    ContentView(isLoggedIn: true)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }else{
                    ContentView(isLoggedIn: false)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
            }else{
                ContentView(isLoggedIn: false)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            
        }
    }
}
