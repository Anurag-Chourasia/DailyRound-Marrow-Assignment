//
//  BookmarkButton.swift
//  Marrow
//
//  Created by Anurag Chourasia on 29/06/24.
//

import SwiftUI

struct BookmarkButton: View {
    @Binding var isBookmarked: Bool
    @Environment(\.managedObjectContext) private var viewContext
    let persistenceController = PersistenceController.shared
    @State var book : Book
    
    var body: some View {
        Button(action: {
            isBookmarked.toggle()
            if isBookmarked{
                persistenceController.saveBook(book)
            }else{
                persistenceController.deleteBook(book)
            }
        }) {
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                .foregroundColor(isBookmarked ? .white : .green)
                .padding(8)
                .background(isBookmarked ? Color.green : .white)
                .clipShape(Circle())
                .shadow(radius: 3)
        }
        .onChange(of: persistenceController.updatedBooks){_ in
            if let book = persistenceController.bookExists(book){
                if book.title == self.book.title{
                    print("BookExist2")
                    isBookmarked = true
                }else{
                    print("BookDoesntExist2")
                    isBookmarked = false
                }
            }else{
                isBookmarked = false
                print("Error2")
            }
        }
    }
}
