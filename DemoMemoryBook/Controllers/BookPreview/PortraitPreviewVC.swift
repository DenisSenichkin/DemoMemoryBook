//
//  PortraitPreviewVC.swift
//  DemoMemoryBook
//
//  Created by Denis Senichkin on 5/29/17.
//

class PortraitPreviewVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collection: UICollectionView!
    
    var currentBook: BookEntity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - collection view data source

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let book = currentBook {
            return book.getPageCount()
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width / 2, height: collectionView.frame.size.width / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewPhotoCell", for: indexPath) as! PreviewPhotoCell
        
        if let book = currentBook {
            let image = book.getImageBy(index: indexPath.row, isThumb: true)
            cell.item = image
            cell.customInit()
        }
        return cell
    }
}

class PreviewPhotoCell : UICollectionViewCell {
    
    @IBOutlet weak var imImage: UIImageView!
    var item:UIImage?
    
    func customInit() {
        
        imImage.image = nil
        if let item = item {
            imImage.image = item
        }
    }
}
