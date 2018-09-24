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
    let moveDetection = PublishSubject<Bool>()
    
    private let motionManager = CMMotionManager()
    private var timer: Repeater!
    
    private var latestPitch: Double?
    private var latestRoll: Double?
    private var latestYaw: Double?
    
    private var latestX: Double = 0
    private var latestY: Double = 0
    private var latestZ: Double = 0
    
    private var latestRotateX: Double = 0
    private var latestRotateY: Double = 0
    private var latestRotateZ: Double = 0
    
    func startWakupDetection() {
        motionManager.accelerometerUpdateInterval = 0.5
        setupDeviceMotion()
        setupAccelerometerUpdates()
        setupGyroUpdates()
    }
    
    func stopWakupDetection() {
        motionManager.stopGyroUpdates()
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopAccelerometerUpdates()
    }
    
    private func setupTimers() {
        timer = Repeater(interval: Repeater.Interval.minutes(1), observer: { [weak self] repeater in
            self?.wakeupDetected.onNext(())
        })
    }
    
    private func setupDeviceMotion() {
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] deviceMotion, error in
            
            let isMoveDetection = self?.latestPitch != deviceMotion?.attitude.pitch.rounded() ?? 0 ||
                self?.latestYaw != deviceMotion?.attitude.yaw.rounded() ?? 0 ||
                self?.latestRoll != deviceMotion?.attitude.roll.rounded() ?? 0
            
            self?.moveDetection.onNext(isMoveDetection)
            
            self?.latestPitch = deviceMotion?.attitude.pitch.rounded() ?? 0
            self?.latestRoll = deviceMotion?.attitude.roll.rounded() ?? 0
            self?.latestYaw = deviceMotion?.attitude.yaw.rounded() ?? 0
        }
    }
    
    private func setupAccelerometerUpdates() {
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] accelerometerUpdates, error in
            
            let isMoveDetection = self?.latestX != accelerometerUpdates?.acceleration.x.rounded() ?? 0 ||
                self?.latestY != accelerometerUpdates?.acceleration.y.rounded() ?? 0 ||
                self?.latestZ != accelerometerUpdates?.acceleration.z.rounded() ?? 0
            
            self?.moveDetection.onNext(isMoveDetection)
            
            self?.latestX = accelerometerUpdates?.acceleration.x.rounded() ?? 0
            self?.latestY = accelerometerUpdates?.acceleration.y.rounded() ?? 0
            self?.latestZ = accelerometerUpdates?.acceleration.z.rounded() ?? 0
        }
    }
    
    private func setupGyroUpdates() {
        motionManager.startGyroUpdates(to: .main) { [weak self] gyroData, error in
            
            let isMoveDetection = self?.latestRotateX != gyroData?.rotationRate.x.rounded() ?? 0 ||
                self?.latestRotateY != gyroData?.rotationRate.y.rounded() ?? 0 ||
                self?.latestRotateZ != gyroData?.rotationRate.z.rounded() ?? 0
            
            self?.moveDetection.onNext(isMoveDetection)
            
            self?.latestRotateX = gyroData?.rotationRate.x.rounded() ?? 0
            self?.latestRotateY = gyroData?.rotationRate.y.rounded() ?? 0
            self?.latestRotateZ = gyroData?.rotationRate.z.rounded() ?? 0
        }
    }

}
