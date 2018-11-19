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
    
    private func detectActivity(activities: [CMMotionActivity], smallTimePeriodInSec: Int, forLastMins minutes: Int) -> Bool {
        
        var timesIntervalsInSecForChek: [Int] = []
        
        var startDatePeriod: Date?
        var endDatePeriod: Date?
        
        activities.forEach { activity in
            
            if activity.stationary == true && startDatePeriod == nil && endDatePeriod == nil {
                startDatePeriod = activity.startDate
            } else if startDatePeriod != nil {
                endDatePeriod = activity.startDate
                let delta = Int(endDatePeriod?.timeIntervalSince1970 ?? 0) - Int(startDatePeriod?.timeIntervalSince1970 ?? 0)
                timesIntervalsInSecForChek.append(delta)
                startDatePeriod = nil
                endDatePeriod = nil
            }
        }
        
        if timesIntervalsInSecForChek.isEmpty {
            return false
        }
        
        for timeIntervalInSecForCheck in timesIntervalsInSecForChek {
            if timeIntervalInSecForCheck > smallTimePeriodInSec {
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
                if self?.detectActivity(activities: activities, smallTimePeriodInSec: smallTimePeriodInSec, forLastMins: minutes) ?? false {
                    return Single.just(())
                } else {
                    return Single.error(ActivityHistoryCore.MotionActivityHistoryError.motionActivityNotEnable)
                }
            }
    }
}
