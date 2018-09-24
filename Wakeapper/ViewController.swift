//
//  ViewController.swift
//  Wakeapper
//
//  Created by Sergey Borovikov on 9/18/18.
//  Copyright © 2018 Sergey Borovikov. All rights reserved.
//

import UIKit
import RxSwift
import Repeat

class ViewController: UIViewController {

    private let diposeBag = DisposeBag()
    
    @IBOutlet weak var moveLabel: UILabel!
    @IBOutlet weak var smallTimerLabel: UILabel!
    @IBOutlet weak var bigTimerLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    private var bigTimer: Repeater?
    private var smallTimer: Repeater?
    
    private var remainingBigSeconds = 0
    private var remainingSmallSeconds = 0
    private var wakupType: WakeupType = .none {
        didSet { self.markupView() }
    }
    
    let wakeUpDetectorService = WakupDetectorService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moveLabel.text = "Moved!"
        moveLabel.alpha = 0
        
        wakeUpDetectorService.startWakupDetection()
        wakeUpDetectorService.moveDetection
            .filter { $0 == true }
            .subscribe(onNext: { [weak self] isMovedDetection in
                self?.fadeAnimateLabel()
                self?.resetSmallTimer()
        }).disposed(by: diposeBag)
        
        resetBigTimer()
    }
    
    private func resetBigTimer() {
        remainingBigSeconds = Constants.bigTimerInterval
        bigTimer = Repeater.every(
            Repeater.Interval.seconds(1),
            count: Constants.bigTimerInterval,
            tolerance: DispatchTimeInterval.microseconds(100),
            queue: .main, { repeater in
                self.remainingBigSeconds -= 1
                self.bigTimerLabel.text = "\(self.remainingBigSeconds)"
                if self.remainingSmallSeconds == 0 &&
                    self.remainingBigSeconds > 0 {
                    self.wakupType = .sleep
                }
        })
    }
    
    private func resetSmallTimer() {
        remainingSmallSeconds = Constants.smallTimerInterval
        smallTimer = Repeater.every(
            Repeater.Interval.seconds(1),
            count: Constants.smallTimerInterval,
            tolerance: DispatchTimeInterval.microseconds(100),
            queue: .main, { repeater in
                self.remainingSmallSeconds -= 1
                self.smallTimerLabel.text = "\(self.remainingSmallSeconds)"
                if self.remainingBigSeconds == 0 &&
                    self.remainingSmallSeconds > 0 {
                    self.wakupType = .wakeup
                }
        })
    }
    
    private func stopTimvers() {
        smallTimer?.pause()
        smallTimer = nil
        bigTimer?.pause()
        bigTimer = nil
        remainingBigSeconds = 0
        remainingSmallSeconds = 0
        wakeUpDetectorService.stopWakupDetection()
    }
    
    private func fadeAnimateLabel() {
        self.moveLabel.alpha = 1
        UIView.animate(withDuration: TimeInterval(Constants.smallTimerInterval)) {
            self.moveLabel.alpha = 0
        }
    }
    
    private func markupView() {
        switch wakupType {
        case .none:
            self.view.backgroundColor = .white
        case .sleep:
            self.view.backgroundColor = .red
            self.infoLabel.text = "You fell asleep"
            self.stopTimvers()
        case .wakeup:
            self.view.backgroundColor = .green
            self.infoLabel.text = "You're awake!"
            self.stopTimvers()
        }
    }
    
    struct Constants {
        static let bigTimerInterval = 100
        static let smallTimerInterval = 20
    }
    
}

enum WakeupType {
    case none
    case sleep
    case wakeup
}
