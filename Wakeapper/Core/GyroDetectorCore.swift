//
//  GeroDetectorCore.swift
//  Wakeapper
//
//  Created by Sergey Borovikov on 10/8/18.
//  Copyright © 2018 Sergey Borovikov. All rights reserved.
//

import Foundation
import CoreMotion
import RxSwift
import SwinjectStoryboard

extension SwinjectStoryboard {
    
    static func setupGyroDetectorCoreFactory() {
        defaultContainer.register(GyroDetectorCoreI.self) { _ in
            GyroDetectorCore()
        }
    }
}

protocol GyroDetectorCoreI {
    
    func startUpdateGyro(with moveObservable: PublishSubject<Void>)
    func stopUpdateGyro()
}

final class GyroDetectorCore {
    
    private var latestRotateX: Double = 0
    private var latestRotateY: Double = 0
    private var latestRotateZ: Double = 0
    
    private let motionManager = CMMotionManager()
}

extension GyroDetectorCore: GyroDetectorCoreI {
    
    func startUpdateGyro(with moveObservable: PublishSubject<Void>) {
        
        motionManager.startGyroUpdates(to: .main) { [weak self] gyroData, error in
            
            let isMoveDetection = self?.latestRotateX != gyroData?.rotationRate.x.rounded() ?? 0 ||
                self?.latestRotateY != gyroData?.rotationRate.y.rounded() ?? 0 ||
                self?.latestRotateZ != gyroData?.rotationRate.z.rounded() ?? 0
            
            if isMoveDetection {
                moveObservable.onNext(())
            }
            
            self?.latestRotateX = gyroData?.rotationRate.x.rounded() ?? 0
            self?.latestRotateY = gyroData?.rotationRate.y.rounded() ?? 0
            self?.latestRotateZ = gyroData?.rotationRate.z.rounded() ?? 0
        }
    }
    
    func stopUpdateGyro() {
        motionManager.stopGyroUpdates()
    }
}
