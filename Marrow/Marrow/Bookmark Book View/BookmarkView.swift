//
//  BookmarkView.swift
//  Marrow
//
//  Created by Anurag Chourasia on 29/06/24.
//

import SwiftUI

struct BookmarkView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    let persistenceController = PersistenceController.shared

    @Environment (\.presentationMode) var presentationMode
    @State var bookmarkBooks : [Book] = []
    @State private var errorMessage: String = ""
    @State private var showAlert = false
    var body: some View {
        VStack(spacing:0){
            HStack(spacing:0){
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10,height: 10)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
                
                .padding(.horizontal,20)

                Text("Bookmark")
                    .font(.title)
                
                Spacer()
            }
            .padding(.vertical,20)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0){
                    ForEach(bookmarkBooks) { book in
                        BookItem(item: book,
                                 fromBookMark: true)
                            .padding(.vertical,5)
                    }
                }
                .padding(.vertical, 10)
            }
            .onAppear{
                bookmarkBooks = persistenceController.fetchBooks()
                if bookmarkBooks.count == 0{
                    showAlert = true
                    errorMessage = "No record found"
                }
            }
            .onChange(of: bookmarkBooks){_ in
                bookmarkBooks = persistenceController.fetchBooks()
            }
        }.navigationBarBackButtonHidden()
            .navigationViewStyle(StackNavigationViewStyle())
            .alert(isPresented: $showAlert) {
                                    Alert(title: Text("Error"),
                                          message: Text("\(errorMessage)"),
                                          dismissButton: .default(Text("OK"),
                                                                  action: {
                                        presentationMode.wrappedValue.dismiss()
                                    }))
                                }
    }
}

#Preview {
    BookmarkView()
}
