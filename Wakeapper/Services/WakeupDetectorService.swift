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
import SwinjectStoryboard

extension SwinjectStoryboard {
    
    static func setupWakeupDetectorServiceFactory() {
        defaultContainer.register(WakeupDetectorServiceI.self) { resolver in
            WakupDetectorService(
                deviceMotionDetectorCore: resolver.resolve(DeviceMotionDetectorCoreI.self)!,
                accelerometerDetectorCore: resolver.resolve(AccelerometerDetectorCoreI.self)!,
                gyroDetectorCore: resolver.resolve(GyroDetectorCoreI.self)!,
                timersCore: resolver.resolve(TimersCoreI.self)!)
        }
    }
}

protocol WakeupDetectorServiceI {
    
    // Main Wakeup Detector
    var wakeupDetectorType: Observable<WakeupDetectorType> { get }
    
    var moveDetection: Observable<Void> { get }
    var bigTimerObservable: Observable<Int> { get }
    var smallTimerObservable: Observable<Int> { get }
    
    func startWakupDetection()
    func stopWakupDetection()
}

final class WakupDetectorService {
    
    private let _wakeupDetecterType = PublishSubject<WakeupDetectorType>()
    private let _moveDetection = PublishSubject<Void>()
    
    private let _bigTimerObservable = PublishSubject<Int>()
    private let _smallTimerObservable = PublishSubject<Int>()
    
    private let deviceMotionDetectorCore: DeviceMotionDetectorCoreI!
    private let accelerometerDetectorCore: AccelerometerDetectorCoreI!
    private let gyroDetectoryCore: GyroDetectorCoreI!
    private let timersCore: TimersCoreI!
    
    init(deviceMotionDetectorCore: DeviceMotionDetectorCoreI,
         accelerometerDetectorCore: AccelerometerDetectorCoreI,
         gyroDetectorCore: GyroDetectorCoreI,
         timersCore: TimersCoreI) {
        self.deviceMotionDetectorCore = deviceMotionDetectorCore
        self.accelerometerDetectorCore = accelerometerDetectorCore
        self.gyroDetectoryCore = gyroDetectorCore
        self.timersCore = timersCore
    }
    
    private var timersConfiguration: TimersCore.Configuration {
        return TimersCore.Configuration(
        bigTimerStartInterval: 60,
        smallTimerStartInterval: 10,
        bigTimerObservable: _bigTimerObservable,
        smallTimerObservable: _smallTimerObservable
        )
    }
}

extension WakupDetectorService: WakeupDetectorServiceI {
    
    var wakeupDetectorType: Observable<WakeupDetectorType> { return _wakeupDetecterType }
    var moveDetection: Observable<Void> { return _moveDetection }
    var bigTimerObservable: Observable<Int> { return _bigTimerObservable }
    var smallTimerObservable: Observable<Int> { return _smallTimerObservable }
    
    func startWakupDetection() {
        _wakeupDetecterType.onNext(.none)
        deviceMotionDetectorCore.startUpdateDeviceMotion(with: _moveDetection)
        accelerometerDetectorCore.startUpdateAccelerometer(with: _moveDetection)
        gyroDetectoryCore.startUpdateGyro(with: _moveDetection)
        timersCore.startTimers(with: self.timersConfiguration)
    }
    
    func stopWakupDetection() {
        deviceMotionDetectorCore.stopUpdateDeviceMotion()
        accelerometerDetectorCore.stopUPdateAccelerometer()
        gyroDetectoryCore.stopUpdateGyro()
        timersCore.stopTimers()
    }
}

enum WakeupDetectorType {
    case none
    case sleepWasDetected
    case wakeupWasDetected
}
