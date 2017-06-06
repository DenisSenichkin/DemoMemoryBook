//
//  RootMenuVC.swift
//  DemoMemoryBook
//
//  Created by Denis Senichkin on 25/5/17.
//  
//

import UIKit

class RootMenuVC: BaseVC {
    
    let menuSB = UIStoryboard(name: "Menu", bundle: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuItem = UIBarButtonItem.init(title: "Menu", style: .done, target: self, action: #selector(openMenu))
        navigationItem.leftBarButtonItem = menuItem
        
        setupSideMenu()
    }

    func openMenu() {
    
        let navVC = menuSB.instantiateViewController(withIdentifier: "MenuNavigationController") as! UISideMenuNavigationController
        self.present(navVC, animated: true, completion: nil)
    }
    
    fileprivate func setupSideMenu() {
        
        if (SideMenuManager.menuLeftNavigationController != nil) {
            return
        }
        
        // Define the menus
        SideMenuManager.menuLeftNavigationController = menuSB.instantiateViewController(withIdentifier: "MenuNavigationController") as? UISideMenuNavigationController
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        //SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        // Set up a cool background image for demo purposes
        SideMenuManager.menuAnimationBackgroundColor = .white
        SideMenuManager.menuPushStyle = .replace
    }
}
