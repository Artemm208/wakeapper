//
//  TimersCore.swift
//  Wakeapper
//
//  Created by Sergey Borovikov on 10/9/18.
//  Copyright © 2018 Sergey Borovikov. All rights reserved.
//

import Foundation
import Repeat
import RxSwift
import RxCocoa
import SwinjectStoryboard

extension SwinjectStoryboard {
    
    static func setupTimersCoreFactory() {
        defaultContainer.register(TimersCoreI.self) { _ in
            TimersCore()
        }
    }
}

protocol TimersCoreI {
    
    func startTimers(with inputConfiguration: TimersCore.Configuration)
    func resetSmallTimer()
    func stopTimers()
}

final class TimersCore {
    
    struct Configuration {
        let bigTimerStartInterval: Int
        let smallTimerStartInterval: Int
        let bigTimerObservable: PublishSubject<Int>
        let smallTimerObservable: PublishSubject<Int>
    }
    
    private var timersCoreConfiguration: TimersCore.Configuration!
    
    private var _remainingBigSeconds = 0
    private var _remainingSmallSeconds = 0
    
    private var bigTimer: Repeater?
    private var smallTimer: Repeater?
    
    private func resetBigTimer() {
        _remainingBigSeconds = timersCoreConfiguration.bigTimerStartInterval
        bigTimer = Repeater.every(
            Repeater.Interval.seconds(1),
            count: timersCoreConfiguration?.bigTimerStartInterval,
            tolerance: DispatchTimeInterval.microseconds(100),
            queue: .main, { repeater in
                
                self._remainingBigSeconds -= 1
                self.timersCoreConfiguration.bigTimerObservable.onNext(self._remainingBigSeconds)
        })
    }
}

extension TimersCore: TimersCoreI {
    
    func startTimers(with inputConfiguration: TimersCore.Configuration) {
        timersCoreConfiguration = inputConfiguration
        resetBigTimer()
        resetSmallTimer()
    }
    
    func resetSmallTimer() {
        _remainingSmallSeconds = timersCoreConfiguration.smallTimerStartInterval
        smallTimer = Repeater.every(
            Repeater.Interval.seconds(1),
            count: timersCoreConfiguration.smallTimerStartInterval,
            tolerance: DispatchTimeInterval.microseconds(100),
            queue: .main, { repeater in
                
                self._remainingSmallSeconds -= 1
                self.timersCoreConfiguration.smallTimerObservable.onNext(self._remainingSmallSeconds)
        })
    }
    
    func stopTimers() {
        smallTimer?.pause()
        smallTimer = nil
        bigTimer?.pause()
        bigTimer = nil
        _remainingBigSeconds = 0
        _remainingSmallSeconds = 0
    }
}
