//
//  ActivityHistoryService.swift
//  Wakeapper
//
//  Created by Sergey Borovikov on 10/25/18.
//  Copyright © 2018 Sergey Borovikov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreMotion
import SwinjectStoryboard

extension SwinjectStoryboard {
    
    static func setupActivityHistoryServiceFactory() {
        defaultContainer.register(ActivityHistoryServiceI.self) { resolver in
            ActivityHistoryService(motionActivityHistoryCore: resolver.resolve(ActivityHistoryCoreI.self)!)
        }
    }
}

protocol ActivityHistoryServiceI {
    
    func activityHistorySingle(forLastMins minutes: Int,
                               smallTimePeriodInSec: Int) -> Single<Void>
}

final class ActivityHistoryService {
    
    let activityHistoryCore: ActivityHistoryCoreI!
    
    init(motionActivityHistoryCore: ActivityHistoryCoreI) {
        self.activityHistoryCore = motionActivityHistoryCore
    }
    
    private func detectActivity(activities: [CMMotionActivity], smallTimePeriodInSec: Int) -> Bool {
        for index in 0...activities.count - 1 {
            let pair = activities.pair(at: index)
            let firstActivitySec = pair.0.startDate.timeIntervalSince1970
            let secondActivitySec = pair.1?.startDate.timeIntervalSince1970 ?? 0
            let delta = Int(secondActivitySec - firstActivitySec)
            if delta > smallTimePeriodInSec {
                return false
            }
        }
        return true
    }
}

extension ActivityHistoryService: ActivityHistoryServiceI {
    
    func activityHistorySingle(forLastMins minutes: Int, smallTimePeriodInSec: Int) -> Single<Void> {
        return activityHistoryCore.getTrackingActivityHistory(forLastMins: minutes)
            .flatMap { [weak self] activities in
                if self?.detectActivity(activities: activities, smallTimePeriodInSec: smallTimePeriodInSec) ?? false {
                    return Single.just(())
                } else {
                    return Single.error(ActivityHistoryCore.MotionActivityHistoryError.motionActivityNotEnable)
                }
            }
    }
}
