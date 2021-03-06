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
        
        SwinjectStoryboard.setupCoreComponentsFactory()
        setupServiciesFactory()
        setupPresentationFactory()
    }
}
