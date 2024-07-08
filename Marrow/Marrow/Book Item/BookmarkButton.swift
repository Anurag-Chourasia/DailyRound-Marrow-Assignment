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
    var imageUrl: URL?
    @State var book : Book
    
    var body: some View {
        Button(action: {
            isBookmarked.toggle()
            if isBookmarked{
                if let imageURL = imageUrl {
                    downloadImage(from: imageURL) { imageData in
                        persistenceController.saveBook(book,
                                                       imageData: imageData)
                    }
                }
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
    // Helper function to download image data from URL
    private func downloadImage(from url: URL, completion: @escaping (Data?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(data)
        }.resume()
    }
}
