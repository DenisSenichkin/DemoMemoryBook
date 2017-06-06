//
//  PreviewContentVC.swift
//  DemoMemoryBook
//
//  Created by Denis Senichkin on 5/29/17.
//

class PreviewContentVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    var currentIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let image = image {
            self.imageView.image = image
        }
    }
}
