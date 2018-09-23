//
//  WakeupDetectorService.swift
//  Wakeapper
//
//  Created by Sergey Borovikov on 9/23/18.
//  Copyright © 2018 Sergey Borovikov. All rights reserved.
//

import Foundation
import CoreMotion
import RxSwift
import Repeat

final class WakupDetectorService {
    
    let wakeupDetected = PublishSubject<Void>()
    
    private let motionManager = CMMotionManager()
    private var latestPitch: Double = 0
    private var latestRoll: Double = 0
    private var latestYaw: Double = 0
    
    func startWakupDetection() {
        
        motionManager.accelerometerUpdateInterval = 0.5
        
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] deviceMotion, error in
            
            if self?.latestPitch == deviceMotion?.attitude.pitch.rounded() ?? 0 ||
                self?.latestYaw == deviceMotion?.attitude.yaw.rounded() ?? 0 ||
                self?.latestRoll == deviceMotion?.attitude.roll.rounded() ?? 0 {
                
            }
            
            self?.latestPitch = deviceMotion?.attitude.pitch.rounded() ?? 0
            self?.latestRoll = deviceMotion?.attitude.roll.rounded() ?? 0
            self?.latestYaw = deviceMotion?.attitude.yaw.rounded() ?? 0
        }
    }

}
