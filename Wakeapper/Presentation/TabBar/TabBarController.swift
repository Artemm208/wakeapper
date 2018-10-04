//
//  TabBarController.swift
//  Wakeapper
//
//  Created by Sergey Borovikov on 10/3/18.
//  Copyright © 2018 Sergey Borovikov. All rights reserved.
//

import UIKit
import SwinjectStoryboard

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewControllers()
    }
    
    private func setupViewControllers() {
        
        let mainScreenViewController = SwinjectStoryboard.create(name: "MainScreen", bundle: nil)
            .instantiateViewController(withIdentifier: "MainScreenController")
//        mainScreenViewController.tabBarItem = UITabBarItem(title: "Main", image: R.image., selectedImage: <#T##UIImage?#>)
    }

}
