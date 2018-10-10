//
//  DeviceMotionDetectorCore.swift
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
    
    static func setupDeviceMotionDetectorCoreFactory() {
        defaultContainer.register(DeviceMotionDetectorCoreI.self) { _ in
            DeviceMotionDetectorCore()
        }
    }
}

protocol DeviceMotionDetectorCoreI {
    
    func startUpdateDeviceMotion(with moveObservable: PublishSubject<Void>)
    func stopUpdateDeviceMotion()
}

final class DeviceMotionDetectorCore {
    
    private var latestPitch: Double?
    private var latestRoll: Double?
    private var latestYaw: Double?
    
    private let motionManager = CMMotionManager()
}

extension DeviceMotionDetectorCore: DeviceMotionDetectorCoreI {
    
    func startUpdateDeviceMotion(with moveObservable: PublishSubject<Void>) {
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] deviceMotion, error in
            
            let isMoveDetection = self?.latestPitch != deviceMotion?.attitude.pitch.rounded() ?? 0 ||
                self?.latestYaw != deviceMotion?.attitude.yaw.rounded() ?? 0 ||
                self?.latestRoll != deviceMotion?.attitude.roll.rounded() ?? 0
            
            if isMoveDetection {
                moveObservable.onNext(())
            }
            
            self?.latestPitch = deviceMotion?.attitude.pitch.rounded() ?? 0
            self?.latestRoll = deviceMotion?.attitude.roll.rounded() ?? 0
            self?.latestYaw = deviceMotion?.attitude.yaw.rounded() ?? 0
        }
    }
    
    func stopUpdateDeviceMotion() {
        motionManager.stopDeviceMotionUpdates()
    }
}
