//
//  SideMenuTableView.swift
//  DemoMemoryBook
//
//  Created by Denis Senichkin on 25/5/17.
//
//

enum kMenuItems: Int {
    case memories, createMemory
}

import Foundation
import UIKit

class SideMenuTableView: UITableViewController {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.textColor = .black
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let menuItem = kMenuItems(rawValue: indexPath.row)!
        
        switch menuItem {
        case .memories:
            let navCon = SideMenuManager.menuLeftNavigationController!
            let menuSB = UIStoryboard(name: "Memories", bundle: nil)
            let vc = menuSB.instantiateViewController(withIdentifier: "MemoriesVC")
            navCon.pushViewController(vc, animated: true)
            
        case .createMemory:
            let navCon = SideMenuManager.menuLeftNavigationController!
            let menuSB = UIStoryboard(name: "CreateMemory", bundle: nil)
            let vc = menuSB.instantiateViewController(withIdentifier: "CreateMemoryVC")
            navCon.pushViewController(vc, animated: true)
        }
        
    }
    
}
