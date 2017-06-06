//
//  Utils
//  DemoMemoryBook
//
//  Created by Denis Senichkin on 5/29/17.
//

class Utils {
    
    class func getTopVC() -> UIViewController {
        if let window = UIApplication.shared.keyWindow {
            var alertVC : UIViewController = window.rootViewController!
            var done = false
            while (!done) {
                if let tabbar = alertVC as? UITabBarController {
                    if (tabbar.selectedIndex < tabbar.viewControllers!.count) {
                        alertVC = tabbar.viewControllers![tabbar.selectedIndex]
                    }
                } else if let navBar = alertVC as? UINavigationController {
                    alertVC = navBar.viewControllers.last!
                } else if (alertVC.presentedViewController != nil) {
                    alertVC = alertVC.presentedViewController!
                } else {
                    done = true
                }
            }
            return alertVC
        }
        return UIViewController()
    }
    
    class func imageFromAsset(asset: PHAsset, size: CGSize, block: @escaping ((_ image: UIImage) -> Void)) {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.resizeMode = .exact
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: size.width, height: size.height), contentMode: .aspectFit, options: requestOptions, resultHandler: { (image, _) in
            block(image!)
        })
    }
    
    class func saveImageDocumentDirectory(image: UIImage, filePath: String) {
        if let imageData = UIImageJPEGRepresentation(image, 1.0) {
            let url = URL(fileURLWithPath: filePath)
            try! imageData.write(to: url, options: [.atomic])
        }
    }
    
    class func getDocumentsPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths.first
        return documentsDirectory!
    }
    
    //MARK: Tutorial
    static let kTutorialKey = "tutorialKey"
    class func showTutorial() -> Bool {
        let defaults = UserDefaults.standard
        let showed = defaults.bool(forKey: kTutorialKey)
        if (!showed){
            defaults.set(true, forKey: kTutorialKey)
        }
        return !showed
    }
}

//MARK: - PendingOperations
let kOperationsCount = 4

class PendingOperations: NSObject {
    static let observedKeyPath = "operationCount"
    var finishedBlock: (() -> ())?
    
    lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Fetching queue"
        queue.maxConcurrentOperationCount = kOperationsCount
        return queue
    }()
    
    override init() {
        super.init()
        downloadQueue.addObserver(self, forKeyPath: PendingOperations.observedKeyPath, options: .new, context: nil)
    }
    
    deinit {
        downloadQueue.removeObserver(self, forKeyPath: PendingOperations.observedKeyPath)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let newValue = change?[.newKey] as? NSNumber, let oldValue = change?[.kindKey] as? NSNumber {
            if newValue.intValue != oldValue.intValue, newValue.intValue == 0  {
                self.finishedQueue()
            }
        }
    }
    
    func addOperation(_ operation: Operation) {
        downloadQueue.addOperation(operation)
    }
    
    func finishedQueue () {
        
        if let callback = finishedBlock {
            callback()
        }
    }
}

//MARK: - ImageFetcher
class ImageFetcher: Operation {
    
    let asset: PHAsset
    let path: String
    let size: CGSize
    
    var taskFinished: Bool = false
    
    init(asset: PHAsset, path: String, size: CGSize) {
        self.asset = asset
        self.path = path
        self.size = size
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isFinished: Bool {
        return taskFinished
    }
    
    override var isExecuting: Bool {
        return !taskFinished
    }
    
    func finishTask() {
        self.willChangeValue(forKey: "isFinished")
        self.willChangeValue(forKey: "isExecuting")
        self.taskFinished = true
        self.didChangeValue(forKey: "isFinished")
        self.didChangeValue(forKey: "isExecuting")
    }
    
    override func main() {
        if self.isCancelled {
            finishTask()
            return
        }
        
        Utils.imageFromAsset(asset: asset, size: size) { image in
            Utils.saveImageDocumentDirectory(image: image, filePath: self.path)
            self.finishTask()
        }
    }
}
