//
//  AccelerometerDetectorCore.swift
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
    
    static func setupAccelerometerDetectorCoreFactory() {
        defaultContainer.register(AccelerometerDetectorCoreI.self) { _ in
            AccelerometerDetectorCore()
        }
    }
}


protocol AccelerometerDetectorCoreI {
    
    func startUpdateAccelerometer(with moveObservable: PublishSubject<Void>)
    func stopUPdateAccelerometer()
}

final class AccelerometerDetectorCore {
    
    private var latestX: Double = 0
    private var latestY: Double = 0
    private var latestZ: Double = 0
    
    private let motionManager = CMMotionManager()
}

extension AccelerometerDetectorCore: AccelerometerDetectorCoreI {
    
    func startUpdateAccelerometer(with moveObservable: PublishSubject<Void>) {
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] accelerometerUpdates, error in
            
            let isMoveDetection = self?.latestX != accelerometerUpdates?.acceleration.x.rounded() ?? 0 ||
                self?.latestY != accelerometerUpdates?.acceleration.y.rounded() ?? 0 ||
                self?.latestZ != accelerometerUpdates?.acceleration.z.rounded() ?? 0
            
            if isMoveDetection {
                moveObservable.onNext(())
            }
            
            self?.latestX = accelerometerUpdates?.acceleration.x.rounded() ?? 0
            self?.latestY = accelerometerUpdates?.acceleration.y.rounded() ?? 0
            self?.latestZ = accelerometerUpdates?.acceleration.z.rounded() ?? 0
        }
    }
    
    func stopUPdateAccelerometer() {
        motionManager.stopAccelerometerUpdates()
    }
}
