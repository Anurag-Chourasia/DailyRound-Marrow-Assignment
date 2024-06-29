//
//  SignUpView.swift
//  Marrow
//
//  Created by Anurag Chourasia on 28/06/24.
//

import SwiftUI

struct SignUpView: View {
    @Environment (\.presentationMode) var presentationMode
    
    @State private var email: String = ""
    @State private var password: String = ""
    @Binding var isLoggedIn: Bool
    @State private var errorMessage: String = ""
    @State private var showAlert = false
    @State private var isLoading = false
    
    @StateObject private var api = NetworkClass()
    @State private var countries: [String] = []
    @State private var selectedCountryIndex: Int = 0
    
    @StateObject var keyboardHeight = KeyboardResponder()
    @Environment(\.managedObjectContext) private var viewContext
    let persistenceController = PersistenceController.shared
    
    var body: some View {
        
        NavigationView{
                        
            GeometryReader{ geometry in
                ZStack{
                    
                ScrollView{
                    
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
                                
                                Text("Welcome,\nSign up to continue")
                                    .font(.title)
                                    .padding(.leading, 30)
                                
                                Spacer()
                            }
                            .padding(.bottom,50)
                            
                            Spacer()
                            
                            HStack(spacing:0){
                                EmailTextFieldView("", email: $email)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 26.5)
                                    .stroke(Color(UIColor(hex: "#DADADA")), lineWidth: 1)
                            )
                            .padding(.bottom,20)
                            .padding(.horizontal,34)
                            
                            
                            HStack(spacing: 0) {
                                PasswordTextFieldView("",
                                              text: $password,
                                              placeholderText: "Password",
                                              mandatoryField: true)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 26.5)
                                    .stroke(Color(UIColor(hex: "#DADADA")), lineWidth: 1)
                            )
                            .padding(.bottom,20)
                            .padding(.horizontal,34)
                            
                            VStack{
                                
                                HStack{
                                    Image(systemName: isValidEmail(email) ? "checkmark.square" : "square")
                                    Text("Must be a valid email")
                                    Spacer()
                                }
                                .padding(.vertical,5)
                                .padding(.horizontal,20)
                                
                                HStack{
                                    Image(systemName: password.hasUppercaseCharacter ? "checkmark.square" : "square")
                                    Text("Must contain an uppercase")
                                    Spacer()
                                }
                                .padding(.vertical,5)
                                .padding(.horizontal,20)
                                
                                HStack{
                                    Image(systemName: password.hasLowercaseCharacter ? "checkmark.square" : "square")
                                    Text("Must contain an lowercase")
                                    Spacer()
                                }
                                .padding(.vertical,5)
                                .padding(.horizontal,20)
                                
                                HStack{
                                    Image(systemName: password.hasSpecialCharacter ? "checkmark.square" : "square")
                                    Text("Must contain a special character")
                                    Spacer()
                                }
                                .padding(.vertical,5)
                                .padding(.horizontal,20)
                                
                                HStack{
                                    Image(systemName: password.hasNumberCharacter ? "checkmark.square" : "square")
                                    Text("Must contain a number character")
                                    Spacer()
                                }
                                .padding(.vertical,5)
                                .padding(.horizontal,20)
                                
                                HStack{
                                    Image(systemName: password.count >= 8 ? "checkmark.square" : "square")
                                    Text("At least 8 characters")
                                    Spacer()
                                }
                                .padding(.vertical,5)
                                .padding(.horizontal,20)
                                
                            }
                            
                            if !countries.isEmpty && !isLoading{
                                WheelPickerView(selectedCountryIndex: $selectedCountryIndex,
                                                country: countries)
                                .padding(.vertical)
                            }
                            
                            
                            
                        HStack(spacing: 0) {
                            Button(action: {
                                isLoading = true
                                if !email.isEmpty && !password.isEmpty{
                                    showAlert = !isValidEmail(email)
                                    if !showAlert{
                                        if isValidPassword(password){
                                            errorMessage = ""
                                            
                                            if persistenceController.saveUser(email: email.lowercased(), password: password) {
                                                // User saved successfully, proceed with next steps
                                                print("User saved successfully")
                                                //                                                        Navigate to home page here
                                                isLoading = false
                                                UserDefaults.standard.setValue(email.lowercased(), forKey: "LoggedInUserEmail")
                                                withAnimation(.easeInOut){
                                                    
                                                    isLoggedIn = true
                                                }
                                                
                                            } else {
                                                showAlert = true
                                                errorMessage = "User with this email already exists"
                                                
                                                print("User with this email already exists")
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
                                Text("Sign Up")
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
                        
                    }
                    
                    if isLoading {
                        VStack{
                            Spacer()
                            ProgressView("Loading.")
                            
                                .progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                        .frame(width: geometry.size.width)
                        .background(Color(UIColor(hex: "#FFFFFF"))
                            .opacity(0.5))
                    }
                }.ignoresSafeArea(.keyboard, edges: .bottom)
            }
            
        }.navigationBarBackButtonHidden()
            .onAppear {
                
                isLoading = true
                
                if let savedCountryModel = persistenceController.fetchCountryModel(), let selectedCountryName = persistenceController.fetchSelectedCountryName() {
                    print("CountryModel found in Core Data")
                    
                    DispatchQueue.main.async {
                        self.countries = savedCountryModel.data.map{ $0.value.country }.sorted()
                        if !self.countries.isEmpty{
                            print(selectedCountryName)
                            self.selectedCountryIndex = self.countries.firstIndex(of: selectedCountryName) ?? 0
                        }
                    }
                    
                    

                    
                    isLoading = false
                    
//                                    persistenceController.deleteAllData(entity: "CountryEntity")
//                                    persistenceController.deleteAllData(entity: "DatumEntity")
//                                    persistenceController.deleteAllData(entity: "RegionEntity")
                } else {
                    
                    print("No CountryModel found in Core Data")

                    api.fetchCountries { fetchedCountries in
                        
                        DispatchQueue.main.async {
                            
                            self.countries = fetchedCountries?.data.map { $0.value.country }.sorted() ?? []

                            api.fetchIPDetails { (response, error) in
                                if let error = error {
                                    // Handle error
                                    print("Error fetching IP details: \(error.localizedDescription)")
                                    isLoading = false
                                    errorMessage = "Error fetching IP details: \(error.localizedDescription)"
                                    showAlert = true
                                    
                                } else if let response = response {
                                    
                                    self.selectedCountryIndex = self.countries.firstIndex(of: response.country) ?? 0
                                    
//                                    print(selectedCountryIndex)
                                    
                                    if let countryModel = fetchedCountries{
                                        persistenceController.saveCountryModel(countryModel)
                                        if !countries.isEmpty{
                                            let name = countries[selectedCountryIndex]
//                                            print(name)
                                            persistenceController.saveDefaultCountryName(selectedCountryName: name)
                                        }
                                       
                                    }
                                    isLoading = false
                                } else {
                                    print("Unexpected nil response and error")
                                    isLoading = false
                                }
                            }
                        }
                    }
                }
                
            }
    }
}

#Preview {
    SignUpView( isLoggedIn: .constant(false))
}

struct WheelPickerView: View {
    @Binding var selectedCountryIndex: Int
    var country: [String]
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistenceController = PersistenceController.shared
    
    var body: some View {
        VStack {
            Picker(selection: $selectedCountryIndex, label: Text("Select an Item")) {
                ForEach(0..<country.count, id: \.self) { index in
                    Text(self.country[index])
                        .tag(index)
                }
            }
            .frame(height: 140)
            .pickerStyle(.wheel)
            .onChange(of: selectedCountryIndex){_ in
                let name = country[selectedCountryIndex]
                persistenceController.saveDefaultCountryName(selectedCountryName: name)
            }
            
        }
    }
}

