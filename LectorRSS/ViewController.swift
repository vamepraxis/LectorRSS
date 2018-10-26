//
//  ViewController.swift
//  LectorRSS
//
//  Created by MacBook Pro on 19/10/18.
//  Copyright © 2018 ccc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshRSS = false
        ViewsDesign.settingsNavigationItem(self, navItem: navigationItem)

        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
        let navigationController = UINavigationController.init(rootViewController: viewController!)
        
        self.present(navigationController, animated: true, completion: nil)
        
    }

}

