//
//  DataModel.swift
//  DemoMemoryBook
//
//  Created by Denis Senichkin on 15/5/17.
//

let kDataModel = DataModel.instance

class DataModel: NSObject {
    
    static let instance = DataModel()
    
    let managedObjectContext = AppDelegate.shared().managedObjectContext
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    //MARK: Books
    func getAllBooks() -> Array<BookEntity> {
        let request:NSFetchRequest = BookEntity.fetchRequest()
        let sort = NSSortDescriptor.init(key: "creationDate", ascending: false)
        request.sortDescriptors = [sort]
        
        do {
            let items = try managedObjectContext.fetch(request)
            return items 
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    
        return []
    }
    
    func getBooksCount() -> Int {
        let request:NSFetchRequest = BookEntity.fetchRequest()

        do {
            let count = try managedObjectContext.count(for: request)
            return count
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
        
        return 0
    }
    
    func createBook(params: [String : Any]) -> BookEntity {
        let count = getBooksCount() + 1
        
        let record = NSEntityDescription.insertNewObject(forEntityName: "BookEntity", into: managedObjectContext) as! BookEntity
        
        if let pagesCount = params["pagesCount"] as? Int, let bookFolderName = params["bookFolderName"] as? String {
            record.title = String(format: "Book number %zd", count)
            record.creationDate = NSDate()
            record.pageCount = NSNumber(integerLiteral: pagesCount)
            record.folderName = bookFolderName
        }
        saveContext()
        return record
    }
    
    func deleteBook(deletedBook: BookEntity) {
        managedObjectContext.delete(deletedBook)
        saveContext()
    }
    
}
