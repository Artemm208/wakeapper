//
//  StartFactory.swift
//  Wakeapper
//
//  Created by Sergey Borovikov on 10/7/18.
//  Copyright © 2018 Sergey Borovikov. All rights reserved.
//

import SwinjectStoryboard

extension SwinjectStoryboard {
    
    class func setupStartFactory() {
        
        defaultContainer.register(StartRouterI.self) { _ in StartRouter() }
        defaultContainer.storyboardInitCompleted(StartViewController.self) { resolver, controller in
            controller.router = resolver.resolve(StartRouterI.self)
        }
    }
}
