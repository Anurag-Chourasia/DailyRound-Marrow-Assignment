//
//  Persistence.swift
//  Marrow
//
//  Created by Anurag Chourasia on 28/06/24.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    @Published var updatedBooks: [Book]?
    let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "Marrow") // Adjusted to match your database name
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Error loading Core Data stores: \(error)")
            }
        }
    }
    
    // Save CountryModel to Core Data
    func saveCountryModel(_ countryModel: CountryModel) {
        let context = container.viewContext
        
        let countryEntity = CountryEntity(context: context)
        countryEntity.status = countryModel.status
        countryEntity.statusCode = Int16(countryModel.statusCode)
        countryEntity.version = countryModel.version
        countryEntity.access = countryModel.access
        countryEntity.total = Int16(countryModel.total)
        countryEntity.offset = Int16(countryModel.offset)
        countryEntity.limit = Int16(countryModel.limit)
        
        for (_, datum) in countryModel.data {
            let datumEntity = DatumEntity(context: context)
            datumEntity.country = datum.country
            
            let regionEntity = RegionEntity(context: context)
            regionEntity.region = datum.region.rawValue
            
            datumEntity.region = regionEntity
            countryEntity.addToData(datumEntity)
        }
        
        saveContext()
    }
    
    func saveDefaultCountryName(selectedCountryName: String) {
        let context = container.viewContext
        
        do {
            let fetchRequest: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
            let countryEntities = try context.fetch(fetchRequest)
            
            // If a CountryEntity already exists, update its selectedCountryName
            if let existingCountryEntity = countryEntities.first {
                existingCountryEntity.selectedCountryName = selectedCountryName
            } else {
                // If no CountryEntity exists, create a new one and save the selectedCountryName
                let newCountryEntity = CountryEntity(context: context)
                newCountryEntity.selectedCountryName = selectedCountryName
            }
            
            saveContext()
        } catch {
            print("Error saving default country name: \(error)")
        }
    }
    
    // Fetch selected country name from Core Data
    func fetchSelectedCountryName() -> String? {
        let context = container.viewContext
        
        do {
            let fetchRequest: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
            let countryEntities = try context.fetch(fetchRequest)
            
            guard let firstCountryEntity = countryEntities.first else {
                print("No CountryEntity found")
                return nil
            }
            
            // Return the selectedCountryName attribute from the first found entity
            return firstCountryEntity.selectedCountryName
        } catch {
            print("Error fetching selected country name: \(error)")
            return nil
        }
    }
    
    // Fetch CountryModel from Core Data
    func fetchCountryModel() -> CountryModel? {
        let context = container.viewContext
        
        do {
            let fetchRequest: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
            let countryEntities = try context.fetch(fetchRequest)
            //            print(countryEntities)
            guard let firstCountryEntity = countryEntities.first else {
                return nil
            }
            
            //            print("firstCountryEntity.selectedCountryName ",firstCountryEntity.selectedCountryName)
            
            var data: [String: Datum] = [:]
            firstCountryEntity.data?.forEach { (datumEntity) in
                if let datum = datumEntity as? DatumEntity {
                    let regionEnum = Region(rawValue: datum.region?.region ?? "") ?? .africa // Default region if unknown
                    data[datum.country ?? ""] = Datum(country: datum.country ?? "", region: regionEnum)
                }
            }
            
            let countryModel = CountryModel(status: firstCountryEntity.status ?? "",
                                            statusCode: Int(firstCountryEntity.statusCode),
                                            version: firstCountryEntity.version ?? "",
                                            access: firstCountryEntity.access ?? "",
                                            total: Int(firstCountryEntity.total),
                                            offset: Int(firstCountryEntity.offset),
                                            limit: Int(firstCountryEntity.limit),
                                            data: data)
            
            return countryModel
        } catch {
            print("Error fetching CountryModel: \(error)")
            return nil
        }
    }
    
    private func saveContext() {
        let context = container.viewContext
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    // Function to delete all objects from a given entity
    func deleteAllData(entity: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            let context = container.viewContext
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Error deleting data: \(error)")
        }
    }
    
    func saveUser(email: String, password: String) -> Bool {
        let context = container.viewContext
        
        // Check if user with the same email already exists
        if let existingUser = fetchUser(email: email) {
            // User already exists, handle accordingly (e.g., show error message)
            print("User with email \(email) already exists")
            return false
        }
        
        let userEntity = UserEntity(context: context)
        userEntity.email = email
        userEntity.password = password
        userEntity.isSuccessfullyLoggedIn = true
        saveContext()
        return true
    }
    
    func fetchUser(email: String) -> UserEntity? {
        let context = container.viewContext
        
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            print("Error fetching user: \(error)")
            return nil
        }
    }
    
    
    
    func logOutUser(email: String) {
        let context = container.viewContext
        
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let users = try context.fetch(fetchRequest)
            users.first?.isSuccessfullyLoggedIn = false
        } catch {
            print("Error fetching user: \(error)")
            return
        }
        saveContext()
    }
    
    func logInUser(email: String) {
        let context = container.viewContext
        
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let users = try context.fetch(fetchRequest)
            users.first?.isSuccessfullyLoggedIn = true
        } catch {
            print("Error fetching user: \(error)")
            return
        }
        saveContext()
    }
    
    func deleteUser(email: String) {
        let context = container.viewContext
        
        if let user = fetchUser(email: email) {
            context.delete(user)
            saveContext()
        } else {
            print("User with email \(email) not found")
        }
    }
    

    func saveBook(_ book: Book) {
        let context = container.viewContext
        let userEmail = UserDefaults.standard.value(forKey: "LoggedInUserEmail") as? String ?? ""
        
        // Check if the book already exists
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@ AND email == %@", book.title, userEmail)
        
        do {
            let results = try context.fetch(fetchRequest)
            let bookEntity: BookEntity
            
            if let existingBook = results.first {
                // Book exists, update it
                bookEntity = existingBook
            } else {
                // Book does not exist, create a new one
                bookEntity = BookEntity(context: context)
            }
            
            bookEntity.title = book.title
            bookEntity.ratingsAverage = book.ratingsAverage ?? 0.0
            bookEntity.ratingsCount = Int32(book.ratingsCount ?? 0)
            bookEntity.coverI = Int32(book.coverI ?? 0)
            bookEntity.email = userEmail
            // Convert array to NSObject
            if let authorNames = book.authorName {
                bookEntity.authorNames = authorNames as NSObject
            }
            
            try context.save()
            // Notify the view of the update
            updateBooks(fetchBooks())
        } catch {
            print("Failed to save book: \(error.localizedDescription)")
        }
    }

    func fetchBooks() -> [Book] {
        let userEmail = UserDefaults.standard.value(forKey: "LoggedInUserEmail") as? String ?? ""
        
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", userEmail)
        
        do {
            let bookEntities = try context.fetch(fetchRequest)
            let books = bookEntities.compactMap { bookEntity in
                Book(
                    title: bookEntity.title ?? "",
                    ratingsAverage: bookEntity.ratingsAverage,
                    ratingsCount: Int(bookEntity.ratingsCount),
                    authorName: bookEntity.authorNames as? [String],
                    coverI: Int(bookEntity.coverI)
                )
            }
            return books
        } catch {
            print("Failed to fetch books: \(error.localizedDescription)")
            return []
        }
    }

    func bookExists(_ book: Book) -> BookEntity? {
        let context = container.viewContext
        let userEmail = UserDefaults.standard.value(forKey: "LoggedInUserEmail") as? String ?? ""
        
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@ AND email == %@", book.title, userEmail)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch book: \(error.localizedDescription)")
            return nil
        }
    }

    func deleteBook(_ book: Book) {
        let context = container.viewContext
        let userEmail = UserDefaults.standard.value(forKey: "LoggedInUserEmail") as? String ?? ""
        
        if let bookEntity = bookExists(book) {
            context.delete(bookEntity)
            
            do {
                try context.save()
                // Notify the view of the update
                updateBooks(fetchBooks())
            } catch {
                print("Failed to delete book: \(error.localizedDescription)")
            }
        } else {
            print("Book does not exist in the database.")
        }
    }

    private func updateBooks(_ books: [Book]) {
        self.updatedBooks = books
    }
}
