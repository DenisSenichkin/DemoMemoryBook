//
//  BookPreviewVC.swift
//  DemoMemoryBook
//
//  Created by Denis Senichkin on 5/29/17.
//

class BookPreviewVC: UIViewController {
    
    
    @IBOutlet weak var horizontalContainer: UIView!
    @IBOutlet weak var verticalContainer: UIView!
    
    var currentBook: BookEntity?
    var portraitVC: PortraitPreviewVC?
    var landscapeVC: LandscapePreviewVC?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let book = currentBook {
            self.title = book.title
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Utils.showTutorial() { //show tutorial once
            let alert = UIAlertController(title: "", message: "You can rotate your device to see the book preview in different style", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let isLandscape = (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight)
        setupContainers(landscape: isLandscape)
    }

    func setupContainers(landscape: Bool) {
        
        self.navigationController?.setNavigationBarHidden(landscape, animated: false)
        horizontalContainer.isHidden = !landscape
        verticalContainer.isHidden = landscape
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPortrait" {
            portraitVC = segue.destination as? PortraitPreviewVC
            portraitVC?.currentBook = currentBook
        } else {
            landscapeVC = segue.destination as? LandscapePreviewVC
            landscapeVC?.currentBook = currentBook
        }
    }
}
