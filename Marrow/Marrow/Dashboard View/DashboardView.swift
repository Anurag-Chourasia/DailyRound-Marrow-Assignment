//
//  DashboardView.swift
//  Marrow
//
//  Created by Anurag Chourasia on 28/06/24.
//

import SwiftUI
import Kingfisher

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let persistenceController = PersistenceController.shared
    
    @State private var searchBook : String = ""
    
    @StateObject private var api = NetworkClass()
    @State private var books: [Book] = []
    
    @State private var sortByCategoryArray: [String] = ["Title","Average","Hits"]
    @State private var selectedCategoryFilter: String = ""
    
    @State private var errorMessage: String = ""
    @State private var showAlert = false
    @State private var logOutAlert = false
    
    @State private var isLoading = false
    @State private var isBookLoading = false
    
    @State private var offset: Int = 0 // Track offset for pagination
    @State private var isLoadingMore: Bool = false // Track loading state for "load more" button
    @State private var loadingMoreBookNotPossible : Bool = false
    
    @Binding var isLoggedIn: Bool
    
    @State private var showBookmarkView : Bool = false
    
    var filteredBooks: [Book] {
        switch selectedCategoryFilter {
        case "Title":
            return books.sorted { $0.title < $1.title } // Sort alphabetically by title
        case "Average":
            return books.sorted { $0.ratingsAverage ?? 0 > $1.ratingsAverage ?? 0} // Sort by ratings average descending
        case "Hits":
            return books.sorted { $0.ratingsCount ?? 0 > $1.ratingsCount ?? 0 } // Sort by ratings count descending
        default:
            return books // Return all books by default
        }
    }
    
    var body: some View {
        NavigationView{
            GeometryReader{ geometry in
                ZStack{
                    VStack(spacing:0){
                        
                        HStack(spacing:0){
                            
                            Text("MedBook")
                                .font(.title)
                                .padding(.leading, 30)
                            
                            Spacer()
                            
                            NavigationLink(destination: BookmarkView()){                         
                                Image(systemName: "bookmark.circle.fill")
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.black)
                                    .frame(height: 35)
                            }
                            .padding(.trailing,30)
                            
                            Button(action: {
                                // remove userdefault and also make userentity data isSuccessfullyLogin = false
                                isLoading = true
                                logOutAlert = true
                            }) {
                                Image("Logout")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 30)
                            }
                            .padding(.trailing,20)
                            
                        }
                        .padding(.vertical,20)
                        
                        HStack{
                            Text("What topic interest you today?")
                                .font(.title2)
                                .padding(.leading, 30)
                            Spacer()
                        }
                        .padding(.top)
                        .padding(.bottom,20)
                        
                        
                        HStack(spacing: 0) {
                            Image(systemName: "book.fill")
                                .resizable()
                                .frame(width: 21, height: 21)
                                .padding(.top, 16)
                                .padding(.bottom, 16)
                                .padding(.leading, 19)
                                .padding(.trailing, 19)
                            
                            TextField("", text: $searchBook)
                                .padding(.trailing, 21)
                                .placeholder(when: searchBook.isEmpty) {
                                    HStack(spacing:0) {
                                        Text("Search for Books")
                                            .foregroundColor(Color(UIColor(hex: "#242E3D")))
                                            .font(.title3)
                                    }
                                }
                                .onChange(of: searchBook){newText in
                                    if isBookLoading || isLoadingMore{
                                        
                                    }else{
                                        performSearch()
                                        offset = 0
                                        loadingMoreBookNotPossible = false
                                    }
                                }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 26.5)
                                .stroke(Color(UIColor(hex: "#DADADA")), lineWidth: 1)
                        )
                        .padding(.bottom,14)
                        .padding(.horizontal,20)
                        
                        ZStack{
                            
                            if !self.books.isEmpty && searchBook.count >= 3{
                                VStack(spacing:0){
                                    
                                    HStack(spacing:0){
                                        
                                        VStack(spacing: 0){
                                            Text("Sort by: ")
                                                .foregroundColor(Color(UIColor(hex: "#242E3D")))
                                                .font(.system(size: 13))
                                            HStack{
                                                Color.clear
                                                    .frame(height: 3)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        ForEach(sortByCategoryArray, id: \.self) { item in
                                            
                                            Button(action: {
                                                DispatchQueue.main.async {
                                                    self.selectedCategoryFilter = "\(item)"
                                                }
                                                
                                                print("\(item) tapped")
                                            }) {
                                                VStack(spacing: 0){
                                                    if selectedCategoryFilter == item{
                                                        Text(item)
                                                            .foregroundColor(.black)
                                                            .font(.system(size: 13))
                                                        
                                                        HStack{
                                                            Color(UIColor(hex: "#22B6CA"))
                                                                .frame(height: 3)
                                                                .clipShape(RoundedRectangle(cornerRadius: 1.5))
                                                        }
                                                    }else{
                                                        Text(item)
                                                            .foregroundColor(.gray)
                                                            .font(.system(size: 13))
                                                        
                                                        HStack{
                                                            Color.clear
                                                                .frame(height: 3)
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action:{
                                            DispatchQueue.main.async {
                                                self.selectedCategoryFilter = ""
                                            }
                                        }){
                                            VStack(spacing: 0){
                                                Text("Clear")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 13))
                                                Color.clear
                                                    .frame(height: 3)
                                            }
                                        }
                                        
                                        
                                    }
                                    .frame(height:31)
                                    
                                    
                                    GeometryReader { innerGeometry in
                                        
                                        ScrollView(.vertical, showsIndicators: false) {
                                            
                                            VStack(spacing: 0) {
                                                ForEach(filteredBooks, id: \.self) { book in
                                                    BookItem(item: book)
                                                        .padding(.vertical, 5)
                                                        .id(book.id)
                                                }
                                                
                                                if isLoadingMore {
                                                    ProgressView()
                                                        .progressViewStyle(CircularProgressViewStyle())
                                                        .padding()
                                                } else if !loadingMoreBookNotPossible {
                                                    Text("Loading More...")
                                                        .padding()
                                                        .foregroundColor(.black)
                                                        .onAppear {
                                                            loadMoreBooksIfNeeded(with: innerGeometry)
                                                        }
                                                }
                                            }
                                            .padding(.vertical, 10)
                                            
                                        }.coordinateSpace(name: "scrollview")
                                    }
                                }
                            }
                            
                            if isBookLoading{
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
                        }
                        
                        Spacer()
                    }.navigationBarBackButtonHidden()
                    
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Error"),
                                  message: Text("\(errorMessage)"),
                                  dismissButton: .default(Text("OK"),
                                                          action: {
                                isLoading = false
                            }))
                        }
                    
                        .alert(isPresented: $logOutAlert) {
                            Alert(
                                title: Text("Logout"),
                                message: Text("Are you sure ?"),
                                primaryButton: .default(Text("Yes")) {
                                    if let email = UserDefaults.standard.value(forKey: "LoggedInUserEmail") as? String{
                                        persistenceController.logOutUser(email: email)
                                        if let existingUser = persistenceController.fetchUser(email: email){
                                            if !existingUser.isSuccessfullyLoggedIn{
                                                UserDefaults.standard.removeObject(forKey: "LoggedInUserEmail")
                                                
                                                withAnimation(.easeIn){
                                                    isLoading = false
                                                    isLoggedIn = false
                                                }
                                            }else{
                                                isLoading = false
                                            }
                                            
                                        }else{
                                            isLoading = false
                                        }
                                        
                                    }else{
                                        isLoading = false
                                    }
                                },
                                secondaryButton: .cancel(Text("Cancel")) {
                                    isLoading = false
                                }
                            )
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
                }
            }
        }
        
    }
    
    private func performSearch() {
        
        if searchBook.count >= 3 && !isBookLoading{
            isBookLoading = true
            offset = 0 // Reset offset when performing a new search
            fetchBooks(title: searchBook.lowercased(), offset: offset)
        } else {
            if !isBookLoading && !isLoadingMore{
                withAnimation(.easeIn) {
                    books = []
                    self.selectedCategoryFilter = ""
                }
            }
        }
    }
    
    private func fetchBooks(title: String, offset: Int) {
        api.fetchBooks(title: title, offset: offset) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newBooks):
                    if newBooks.count != 10{
                        loadingMoreBookNotPossible = true
                    }
                    if offset == 0 {
                        books = newBooks
                    } else {
                        books.append(contentsOf: newBooks)
                        isLoadingMore = false
                    }
                    isBookLoading = false
                case .failure(let error):
                    errorMessage = "Error fetching books: \(error.localizedDescription)"
                    if error.localizedDescription == "No data received"{
                        loadingMoreBookNotPossible = true
                    }
                    showAlert = true
                    isBookLoading = false
                    isLoadingMore = false
                }
            }
        }
    }
    
    private func loadMoreBooksIfNeeded(with geometry: GeometryProxy) {
        let contentHeight = geometry.size.height
        let offsetY = geometry.frame(in: .named("scrollview")).maxY - geometry.size.height
        let screenHeight = UIScreen.main.bounds.height
        let triggerOffset = contentHeight - offsetY - screenHeight
        
        if triggerOffset <= 0 { // Check if triggerOffset is less than or equal to 0 for exact bottom
            // Simulate loading delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // Replace with actual data fetching logic
                loadMoreBooks()
            }
        }
    }
    
    private func loadMoreBooks() {
        isLoadingMore = true
        offset += 10 // Increment offset for pagination
        fetchBooks(title: searchBook.lowercased(), offset: offset)
    }
    
}

#Preview {
    DashboardView(isLoggedIn: .constant(true))
}
