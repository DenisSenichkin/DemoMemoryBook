//
//  LandscapePreviewVC.swift
//  DemoMemoryBook
//
//  Created by Denis Senichkin on 5/29/17.
//

class LandscapePreviewVC: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var slider: UISlider!
    
    var pageController = UIPageViewController()
    var currentBook: BookEntity?
    var currentIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPageController()
        self.setupSlider()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.pageController.view.frame = self.bgView.frame
    }
    
    func setupPageController() {
        
        self.pageController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        self.pageController.dataSource = self
        self.pageController.delegate = self
        
        let vc1: PreviewContentVC = self.viewControllerAtIndex(index: currentIndex)!
        
        self.pageController.setViewControllers([vc1], direction: .forward, animated: true, completion: nil)
        
        self.addChildViewController(self.pageController)
        self.bgView.addSubview(self.pageController.view)
        self.pageController.didMove(toParentViewController: self)
    }
    
    func setupSlider() {
        if let book = currentBook {
            slider.maximumValue = Float(book.getPageCount() / 2 - 1)
        }
        slider.value = Float(currentIndex)
    }

    @IBAction func sliderAction(_ sender: UISlider) {
        
        let roundedValue = Int(slider.value * 2)
        if (roundedValue == currentIndex || roundedValue % 2 == 1) {
            return
        }
        
        if let count = currentBook?.getPageCount(), roundedValue == count {
            return
        }
        
        let direction: UIPageViewControllerNavigationDirection = currentIndex > roundedValue ? .reverse : .forward
        currentIndex = roundedValue
        
        self.showPhoto(index: roundedValue, direction: direction)
    }
    
    func updateSlider(_ value: Int) {
        slider.value = Float(value / 2)
    }
    
    func showPhoto(index: Int, direction: UIPageViewControllerNavigationDirection) {
        
        let vc: PreviewContentVC = self.viewControllerAtIndex(index: index)!
        let vc2: PreviewContentVC = self.viewControllerAtIndex(index: index + 1)!
        self.pageController.setViewControllers([vc, vc2], direction: direction, animated: true, completion: nil)
    }
    
    func viewControllerAtIndex(index: Int) -> PreviewContentVC? {
        
        if currentBook == nil {
            return PreviewContentVC()
        }
        let dataViewController = self.storyboard?.instantiateViewController(withIdentifier: "PreviewContentVC") as! PreviewContentVC
        let image = currentBook?.getImageBy(index: index, isThumb: true)
        dataViewController.image = image
        dataViewController.currentIndex = index
        return dataViewController
    }
    
    //MARK: - UIPageViewController
    
    func indexOfViewController(viewController: PreviewContentVC) -> Int {
        if let index = viewController.currentIndex {
            return index
        } else {
            return NSNotFound
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = indexOfViewController(viewController: viewController
            as! PreviewContentVC)
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        index -= 1
        updateSlider(index)
        return viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = indexOfViewController(viewController: viewController as! PreviewContentVC)
        
        if index == NSNotFound {
            return PreviewContentVC()
        }
        index += 1
        if index == currentBook?.getPageCount() {
            return nil
        }
        updateSlider(index)
        return viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        
        let vc1: PreviewContentVC = self.viewControllerAtIndex(index: currentIndex)!
        let vc2: PreviewContentVC = self.viewControllerAtIndex(index: currentIndex + 1)!
        
        self.pageController.setViewControllers([vc1, vc2], direction: .forward, animated: true, completion: nil)
        self.pageController.isDoubleSided = true
        
        return .mid
    }
    
}

