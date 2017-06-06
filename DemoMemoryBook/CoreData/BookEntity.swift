//
//  BookEntity.swift
//  DemoMemoryBook
//
//  Created by Denis Senichkin on 5/29/17.
//

import Foundation
import CoreData
import UIKit

class BookEntity: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookEntity> {
        return NSFetchRequest<BookEntity>(entityName: "BookEntity")
    }
    
    @NSManaged public var title: String?
    @NSManaged public var folderName: String?
    @NSManaged public var creationDate: NSDate?
    @NSManaged public var pageCount: NSNumber?
    
    func getPageCount() -> Int {
        if  let pageCount = pageCount {
            let lastPageExist = pageCount.intValue % 2 == 0 ? 1 : 0
            return pageCount.intValue + 1 + lastPageExist //add first and last empty pages
        }
        return 0
    }
    
    func getImageBy(index: Int, isThumb: Bool) -> UIImage {
        
        let count = getPageCount()
        if index == 0 || (count % 2 == 0 && index == count) { //first and last pages
            return UIImage()
        }
        
        let imageIndex = index - 1 //for empty page
        let filePath = getImagePathBy(index: imageIndex, isThumb: isThumb)
        if FileManager.default.fileExists(atPath: filePath), let image = UIImage(contentsOfFile: filePath) {
            return image
        }
        return UIImage()
    }
    
    func getCoverImage(isThumb: Bool) -> UIImage {
        return getImageBy(index: 1, isThumb: isThumb)
    }
    
    func getBookPath(isThumb: Bool) -> String {
        let path = getDocumentsPath()
        let prefix = isThumb ? "thumbs/" : ""
        let fullPath = String(format: "%@/%@/%@", path, folderName ?? "", prefix)
        
        if  !FileManager.default.fileExists(atPath: fullPath) {
            try! FileManager.default.createDirectory(atPath: fullPath, withIntermediateDirectories: true, attributes: nil)
        }
        return fullPath
    }
    
    private func getImagePathBy(index: Int, isThumb: Bool) -> String {
        let path = getBookPath(isThumb: isThumb)
        let imageName = String(format: "%zd.jpg", index)
        let fullPath = String(format: "%@%@", path, imageName)
        return fullPath
    }
    
    private func getDocumentsPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths.first
        return documentsDirectory!
    }

}
