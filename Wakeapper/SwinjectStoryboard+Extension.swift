//
//  SwinjectStoryboard+Extension.swift
//  Wakeapper
//
//  Created by Sergey Borovikov on 9/30/18.
//  Copyright © 2018 Sergey Borovikov. All rights reserved.
//

import SwinjectStoryboard

extension SwinjectStoryboard {
    
    @objc class func setup() {
        
        // MARK: - Services
        defaultContainer.register(WakeupDetectorServiceI.self) { _ in WakupDetectorService() }
        
        // MARK: - Routers
        defaultContainer.register(StartRouterI.self) { _ in StartRouter() }
        defaultContainer.register(MainScreenRouterI.self) { _ in MainScreenRouter() }
        
        // MARK: - ViewModels
        defaultContainer.register(MainScreenViewModelI.self) { resolver in
            MainScreenViewModel(wakeUpDetectorService: resolver.resolve(WakeupDetectorServiceI.self)!)
        }
        
        // MARK: - ViewControllers
        defaultContainer.storyboardInitCompleted(StartViewController.self) { resolver, controller in
            controller.router = resolver.resolve(StartRouterI.self)
        }
        defaultContainer.storyboardInitCompleted(MainScreenViewController.self) { resolver, controller in
            controller.viewModel = resolver.resolve(MainScreenViewModelI.self)
            controller.router = resolver.resolve(MainScreenRouterI.self)
        }
    }
}
