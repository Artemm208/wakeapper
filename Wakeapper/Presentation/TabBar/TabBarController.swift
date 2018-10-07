//
//  TabBarController.swift
//  Wakeapper
//
//  Created by Sergey Borovikov on 10/3/18.
//  Copyright © 2018 Sergey Borovikov. All rights reserved.
//

import UIKit
import SwinjectStoryboard
import RAMAnimatedTabBarController

class TabBarController: RAMAnimatedTabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    private func setupViewControllers() {
        
        if let mainNavigationController = self.viewControllers?[0] as? UINavigationController {
            mainNavigationController.viewControllers = [mainScreenViewController]
        }
        
        if let profileNavigationController = self.viewControllers?[1] as? UINavigationController {
            profileNavigationController.viewControllers = [profileScreenViewController]
        }
        
        if let alarmsNavigationController = self.viewControllers?[2] as? UINavigationController {
            alarmsNavigationController.viewControllers = [alarmsScreenViewController]
        }
        
        if let settingsNavigationController = self.viewControllers?[3] as? UINavigationController {
            settingsNavigationController.viewControllers = [settingsScreenViewController]
        }
    }
    
    lazy var mainScreenViewController: MainScreenViewController = {
        
        let firstViewController = R.storyboard.mainScreen().instantiateViewController(withIdentifier: "MainScreenViewController") as! MainScreenViewController
        firstViewController.title = "Main"
        firstViewController.view.backgroundColor = .red
        return firstViewController
    }()
    
    lazy var profileScreenViewController: ProfileViewController = {

        let profileScreenViewController = SwinjectStoryboard.create(name: "Profile", bundle: nil)
            .instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileScreenViewController.title = "Profile"
        return profileScreenViewController
    }()
    
    lazy var alarmsScreenViewController: UIViewController = {
        let alarmsScreenViewController = SwinjectStoryboard.create(name: "Alarms", bundle: nil)
            .instantiateViewController(withIdentifier: "AlarmsViewController") as! AlarmsViewController
        alarmsScreenViewController.title = "Alarms"
        alarmsScreenViewController.view.backgroundColor = UIColor.blue
        return alarmsScreenViewController
    }()
    
    lazy var settingsScreenViewController: UIViewController = {
        let settingsScreenViewController = SwinjectStoryboard.create(name: "Settings", bundle: nil)
        .instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        settingsScreenViewController.title = "Settings"
        settingsScreenViewController.view.backgroundColor = UIColor.yellow
        return settingsScreenViewController
    }()

}
