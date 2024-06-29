//
//  BookItem.swift
//  Marrow
//
//  Created by Anurag Chourasia on 29/06/24.
//

import SwiftUI
import Kingfisher
struct BookItem: View {
    @Environment(\.managedObjectContext) private var viewContext
    let persistenceController = PersistenceController.shared
    
    var item : Book
    @State private var isLoading : Bool = true
    @State private var authorNames : String = ""
    @State private var isBookmarked: Bool = false // State to track bookmark status
    @State private var showBookmarkButton: Bool = false // State to control bookmark button visibility
    var body: some View {
        HStack(spacing: 0){
            HStack(spacing: 0){
                
                VStack(alignment: .center,spacing:0){
                    let coverI = item.coverI ?? 0
                    let urlString = "https://covers.openlibrary.org/b/id/\(coverI)-M.jpg"
                    let url = URL(string: urlString)
                    ZStack {
                        KFImage.url(url)
                            .loadDiskFileSynchronously()
                            .cacheMemoryOnly()
                            .fade(duration: 0.25)
                            .onProgress { receivedSize, totalSize in
                                self.isLoading = true
                            }
                            .onSuccess { result in
                                let imageSize = result.image.size
                                if imageSize.width == 0 && imageSize.height == 0 {
                                    //                                        print("The downloaded image has no size (width and height are zero).")
                                    self.isLoading = true
                                    //                                        print("onSuccess")
                                    //                                        print(url ?? "")
                                } else {
                                    if imageSize.width >= 100 && imageSize.height >= 100{
                                        self.isLoading = false
                                    }else{
                                        self.isLoading = true
                                        //                                            print("onSuccess")
                                        //                                            print(url ?? "")
                                    }
                                    //                                        print("The downloaded image size: \(imageSize.width) x \(imageSize.height)")
                                }
                            }
                            .onFailure { error in
                                self.isLoading = false
//                                print("onFailure")
//                                print(url ?? "")
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: (100/5)*3,height: 100)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 5) // Circle shape for border
                                    .stroke(Color(UIColor(hex: "#22B6CA")), lineWidth: 1)
                                    .frame(width: (100/5)*3,height: 100)
                            )
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                    }
                }
                .frame(height: 100)
                
                
                
                
                VStack(alignment: .leading, spacing:0){
                    
                    Text("\(item.title)")
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .foregroundColor(Color(UIColor(hex: "#233C7E")))
                        .font(.footnote)
                        .padding(.bottom,6)
                    
                    Text(authorNames.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No Author" : authorNames)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .foregroundColor(Color(UIColor(hex: "#363636")))
                        .font(.footnote)
                        .padding(.bottom,8)
                        .onAppear{
                            if let authorNames = item.authorName {
                                for i in 0..<authorNames.count {
                                    if !authorNames[i].isEmpty{
                                        self.authorNames.append(authorNames[i])
                                        if i == authorNames.count - 2 {
                                            self.authorNames.append(" & ")
                                        } else if i < authorNames.count - 2 {
                                            self.authorNames.append(", ")
                                        }
                                    }
                                }
                                if self.authorNames.last != "."{
                                    self.authorNames.append(".")
                                }
                            }
//                            print(authorNames)
//                            print(authorNames.trimmingCharacters(in: .whitespacesAndNewlines).count)
                        }
                    
                    HStack(spacing:0){
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(item.ratingsAverage ?? 0) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                            
                        }
                        Text("\(item.ratingsCount ?? 0) Ratings")
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .font(.footnote)
                            .padding(.leading,10)
                    }
                    .padding(.bottom,12)
                    
                    
                    let formattedRating = (item.ratingsAverage ?? 0.0).formattedString(maxFractionDigits: 2)
                    Text("\(formattedRating) Average Review")
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .font(.footnote)
                        .padding(.bottom,12)
                    
                    
                }
                .padding(.leading,17)
                
                Spacer()
            }
            .padding(.horizontal,23)
            .padding(.vertical,16)
            
            //Add swipe and tap gesture to add book mark button
            
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(Color(UIColor(hex: "#FFFFFF")))
                    .shadow(color: Color.black.opacity(0.4), radius: 3, x: 0, y: 0)
                    .padding(.horizontal,13)
            )
            
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        // Detect swipe direction from right to left
                        if gesture.translation.width < 0 && abs(gesture.translation.width) > 50 {
                            withAnimation(.easeIn){
                                showBookmarkButton = true
                            }
                        } else {
                            withAnimation(.easeOut){
                                showBookmarkButton = false
                            }
                        }
                    }
            )
            .onAppear{
                if let book = persistenceController.bookExists(item){
                    if book.title == item.title{
                        isBookmarked = true
                    }else{
                        isBookmarked = false
                    }
                }else{
                    isBookmarked = false
                }
            }

            
            if showBookmarkButton {
                BookmarkButton(isBookmarked: $isBookmarked,
                               book: item)
                    .padding(.trailing, 10)
                    .transition(.move(edge: .trailing))
            }
        }
        .onChange(of: persistenceController.updatedBooks){_ in
            if let book = persistenceController.bookExists(item){
                if book.title == item.title{
                    print("BookExist1")
                    isBookmarked = true
                }else{
                    print("BookDoesntExist1")
                    isBookmarked = false
                }
            }else{
                isBookmarked = false
                print("Error1")
            }
        }
    }
}

