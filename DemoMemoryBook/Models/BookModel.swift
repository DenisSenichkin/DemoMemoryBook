//
//  BookModel.swift
//  DemoMemoryBook
//
//  Created by Denis Senichkin on 5/29/17.
//

typealias bookEntityBlock = ((_ newBook: BookEntity) -> ())

let thumbScale = 5
let origScale = 3

let kBookModel = BookModel.shared

class BookModel: NSObject {
    
    static let shared = BookModel()
    let pendingOperations = PendingOperations()
    var photos: [PHAsset] = []
    
    func createBook(assets: [PHAsset], block: @escaping (_ newBook: BookEntity) -> ()) {
        
        let bookFolderName = String(Int(Date().timeIntervalSince1970))
        let pagesCount = assets.count
        
        pendingOperations.downloadQueue.isSuspended = true
        pendingOperations.finishedBlock = { //all operation was finished
            DispatchQueue.main.async {
                let params: [String : Any] = ["pagesCount" : pagesCount, "bookFolderName" : bookFolderName]
                self.endCreating(params: params, block: block)
            }
        }
        
        for index in 0..<assets.count {
            let asset = assets[index]
            
            //save thumbs
            let thumbFilePath = getImagePathBy(bookFolderName: bookFolderName, index: index, isThumb: true)
            let thumbSize = CGSize(width: CGFloat(asset.pixelWidth / thumbScale), height: CGFloat(asset.pixelHeight / thumbScale))
            
            //save original
            let origFilePath = getImagePathBy(bookFolderName: bookFolderName, index: index, isThumb: false)
            let origSize = CGSize(width: CGFloat(asset.pixelWidth / origScale), height: CGFloat(asset.pixelHeight / origScale))
            
            //operations
            let thumbOperation = ImageFetcher(asset: asset, path: thumbFilePath, size: thumbSize)
            pendingOperations.addOperation(thumbOperation)
            
            let origOperation = ImageFetcher(asset: asset, path: origFilePath, size: origSize)
            pendingOperations.addOperation(origOperation)
        }
        pendingOperations.downloadQueue.isSuspended = false
    }
    
    func endCreating(params: [String: Any], block: bookEntityBlock) {
        let bookEntity = kDataModel.createBook(params: params)
        block(bookEntity)
    }
    
    func getBookPath(bookFolderName: String, isThumb: Bool) -> String {
        let path = Utils.getDocumentsPath()
        let prefix = isThumb ? "thumbs/" : ""
        let fullPath = String(format: "%@/%@/%@", path, bookFolderName, prefix)
        
        if  !FileManager.default.fileExists(atPath: fullPath) {
            try! FileManager.default.createDirectory(atPath: fullPath, withIntermediateDirectories: true, attributes: nil)
        }
        return fullPath
    }
    
    private func getImagePathBy(bookFolderName: String ,index: Int, isThumb: Bool) -> String {
        let path = getBookPath(bookFolderName: bookFolderName, isThumb: isThumb)
        let imageName = String(format: "%zd.jpg", index)
        let fullPath = String(format: "%@%@", path, imageName)
        return fullPath
    }

}
