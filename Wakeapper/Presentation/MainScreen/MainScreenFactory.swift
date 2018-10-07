//
//  MainScreenFactory.swift
//  Wakeapper
//
//  Created by Sergey Borovikov on 10/7/18.
//  Copyright © 2018 Sergey Borovikov. All rights reserved.
//

import SwinjectStoryboard

extension SwinjectStoryboard {
    
    class func setupMainScreenFactory() {
        defaultContainer.register(MainScreenRouterI.self) { _ in MainScreenRouter() }
        defaultContainer.register(MainScreenViewModelI.self) { resolver in
            MainScreenViewModel(wakeUpDetectorService: resolver.resolve(WakeupDetectorServiceI.self)!)
        }
        defaultContainer.storyboardInitCompleted(MainScreenViewController.self) { resolver, controller in
            controller.viewModel = resolver.resolve(MainScreenViewModelI.self)
            controller.router = resolver.resolve(MainScreenRouterI.self)
        }
    }
}
