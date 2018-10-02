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

protocol WakeupDetectorServiceI {
    
    // Main Wakeup Detector
    var wakeupDetectorType: Observable<WakeupDetectorType> { get }
    
    var moveDetection: Observable<Bool> { get }
    var bigTimerObservable: Observable<Int> { get }
    var smallTimerObservable: Observable<Int> { get }
    
    func startWakupDetection()
    func stopWakupDetection()
}

final class WakupDetectorService {
    
    private let _wakeupDetecterType = PublishSubject<WakeupDetectorType>()
    private let _moveDetection = PublishSubject<Bool>()
    
    private let _bigTimerObservable = PublishSubject<Int>()
    private let _smallTimerObservable = PublishSubject<Int>()
    
    private let motionManager = CMMotionManager()
    private var bigTimer: Repeater?
    private var smallTimer: Repeater?
    
    private var latestPitch: Double?
    private var latestRoll: Double?
    private var latestYaw: Double?
    
    private var latestX: Double = 0
    private var latestY: Double = 0
    private var latestZ: Double = 0
    
    private var latestRotateX: Double = 0
    private var latestRotateY: Double = 0
    private var latestRotateZ: Double = 0
    
    private var _remainingBigSeconds = 0
    private var _remainingSmallSeconds = 0
    
    private func setupDeviceMotion() {
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] deviceMotion, error in
            
            let isMoveDetection = self?.latestPitch != deviceMotion?.attitude.pitch.rounded() ?? 0 ||
                self?.latestYaw != deviceMotion?.attitude.yaw.rounded() ?? 0 ||
                self?.latestRoll != deviceMotion?.attitude.roll.rounded() ?? 0
            
            self?.moved(isMoveDetection: isMoveDetection)
            
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
            
            self?.moved(isMoveDetection: isMoveDetection)
            
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
            
            self?.moved(isMoveDetection: isMoveDetection)
            
            self?.latestRotateX = gyroData?.rotationRate.x.rounded() ?? 0
            self?.latestRotateY = gyroData?.rotationRate.y.rounded() ?? 0
            self?.latestRotateZ = gyroData?.rotationRate.z.rounded() ?? 0
        }
    }
    
    private func moved(isMoveDetection: Bool) {
        _moveDetection.onNext(isMoveDetection)
        if isMoveDetection {
            _remainingSmallSeconds = Constants.smallTimerInterval
        }
    }
    
    private func resetBigTimer() {
        _remainingBigSeconds = Constants.bigTimerInterval
        bigTimer = Repeater.every(
            Repeater.Interval.seconds(1),
            count: Constants.bigTimerInterval,
            tolerance: DispatchTimeInterval.microseconds(100),
            queue: .main, { repeater in
                
                self._remainingBigSeconds -= 1
                self._bigTimerObservable.onNext(self._remainingBigSeconds)
                
                if self._remainingSmallSeconds == 0 &&
                    self._remainingBigSeconds > 0 {
                    self.stopTimers()
                    self._wakeupDetecterType.onNext(.sleep)
                }
        })
    }
    
    private func resetSmallTimer() {
        _remainingSmallSeconds = Constants.smallTimerInterval
        smallTimer = Repeater.every(
            Repeater.Interval.seconds(1),
            count: Constants.smallTimerInterval,
            tolerance: DispatchTimeInterval.microseconds(100),
            queue: .main, { repeater in
                
                self._remainingSmallSeconds -= 1
                self._smallTimerObservable.onNext(self._remainingSmallSeconds)
                
                if self._remainingBigSeconds == 0 &&
                    self._remainingSmallSeconds > 0 {
                    self.stopTimers()
                    self._wakeupDetecterType.onNext(.wakeup)
                }
        })
    }
    
    private func stopTimers() {
        smallTimer?.pause()
        smallTimer = nil
        bigTimer?.pause()
        bigTimer = nil
        _remainingBigSeconds = 0
        _remainingSmallSeconds = 0
        stopWakupDetection()
    }
    
    struct Constants {
        static let bigTimerInterval = 100
        static let smallTimerInterval = 20
    }
}

extension WakupDetectorService: WakeupDetectorServiceI {
    
    var wakeupDetectorType: Observable<WakeupDetectorType> { return _wakeupDetecterType }
    var moveDetection: Observable<Bool> { return _moveDetection }
    var bigTimerObservable: Observable<Int> { return _bigTimerObservable }
    var smallTimerObservable: Observable<Int> { return _smallTimerObservable }
    
    func startWakupDetection() {
        _wakeupDetecterType.onNext(.none)
        motionManager.accelerometerUpdateInterval = 0.5
        setupDeviceMotion()
        setupAccelerometerUpdates()
        setupGyroUpdates()
        resetSmallTimer()
        resetBigTimer()
    }
    
    func stopWakupDetection() {
        motionManager.stopGyroUpdates()
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopAccelerometerUpdates()
    }
}

enum WakeupDetectorType {
    case none
    case sleep
    case wakeup
}
