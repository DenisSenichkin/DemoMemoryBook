//
//  AddPhotosVC.swift
//  DemoMemoryBook
//
//  Created by Denis Senichkin on 5/29/17.
//

class AddPhotosVC: BaseVC, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let imgManager = PHImageManager.default()
    var items : (PHFetchResult<PHAsset>)?
    var selectedItems:[PHAsset] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTitle()
        let addBtn = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(btnCreateClicked))
        navigationItem.rightBarButtonItem = addBtn
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (items == nil) {
            self.requestAccess()
        }
    }
    
    func btnCreateClicked() {
        guard selectedItems.count != 0 else {
            let alert = UIAlertController(title: "Alert", message: "Please select at least one photo", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        ToastView.show(text: "Preparing...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.createBook()
        }
    }
    
    func createBook() {
        kBookModel.createBook(assets: selectedItems) { newBook in
            ToastView.hide() {
                let bookViewerSB = UIStoryboard(name: "BookViewer", bundle: nil)
                let bookPreviewVC = bookViewerSB.instantiateViewController(withIdentifier: "BookPreviewVC") as! BookPreviewVC
                bookPreviewVC.currentBook = newBook
                
                let memoriesSB = UIStoryboard(name: "Memories", bundle: nil)
                let memoriesVC = memoriesSB.instantiateViewController(withIdentifier: "MemoriesVC") as! MemoriesVC
                self.navigationController?.setViewControllers([memoriesVC, bookPreviewVC], animated: true)
            }
        }
    }
    
    //MARK: - images routine
    func requestAccess () {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .notDetermined) {
            PHPhotoLibrary.requestAuthorization { status in
                 DispatchQueue.main.async {
                    self.parseAccessStatus(status: status)
                 }
            }
        } else {
            self.parseAccessStatus(status: status)
        }
    }
    
    func parseAccessStatus(status: PHAuthorizationStatus) {
        switch (status) {
            case .authorized:
                self.fetchPhotos()
                break;
            
            case .restricted, .denied:
                let alert = UIAlertController(title: "Alert", message: "You disabled access to photos, you should change this in settings to be able create a memory book", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
                let openSettingsAction = UIAlertAction(title: "Open", style: .default, handler: { action in
                    let settingsURL = URL(string: UIApplicationOpenSettingsURLString)
                    UIApplication.shared.openURL(settingsURL!)
                })
                alert.addAction(openSettingsAction)
                self.present(alert, animated: true, completion: nil)
                break;
            
            default: break
        }
    }
    
    func fetchPhotos () {
        
        let limit = 100
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptions.fetchLimit = limit
        
        items = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        #if DEBUG //auto select photos in debug mode for testing purposes
            for index in 0..<50 {
                if index < (items?.count)!, let asset = items?[index] {
                    selectedItems.append(asset)
                }
            }
            updateTitle()
        #endif

        collectionView.reloadData()
    }
    
    func updateTitle() {
        if selectedItems.count > 0 {
            self.title = String(format: "Selected %zd image(s)", selectedItems.count)
        }
        else {
            self.title = String(format: "Select photos", selectedItems.count)
        }
    }
    
    //MARK: Collection
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/3 - 1, height: collectionView.frame.size.height/5)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectPhotoCell", for: indexPath) as! SelectPhotoCell
        
        if indexPath.row < items?.count ?? 0 {
            let asset = items!.object(at: indexPath.row) as PHAsset
            let selected = selectedItems.contains(asset)
            cell.item = asset
            cell.customInit(selected: selected)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.row < items?.count ?? 0 {
            let asset = items!.object(at: indexPath.row) as PHAsset
            if let index = selectedItems.index(of: asset) {
                selectedItems.remove(at: index)
            } else {
                selectedItems.append(asset)
            }
            updateTitle()
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

class SelectPhotoCell : UICollectionViewCell {
    
    @IBOutlet weak var imImage: UIImageView!
    let imgManager = PHImageManager.default()
    var item:PHAsset?
    
    func customInit(selected: Bool) {
        
        imImage.image = nil
        imImage.layer.borderWidth = 0
        
        if let item = item {

            let retinaSize = CGSize(width: self.frame.size.width*2, height: self.frame.size.height*2)
            Utils.imageFromAsset(asset: item, size: retinaSize, block: { (image) in
                self.imImage.image = image
            })
            
            //selected cell
            if selected {
                imImage.layer.borderWidth = 2
                imImage.layer.borderColor = UIColor.green.cgColor
            } else {
                imImage.layer.borderWidth = 0
            }
        }
    }
}

