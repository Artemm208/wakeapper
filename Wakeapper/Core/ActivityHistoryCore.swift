//
//  MotionActivityHistoryCore.swift
//  Wakeapper
//
//  Created by Sergey Borovikov on 10/25/18.
//  Copyright © 2018 Sergey Borovikov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import CoreMotion
import SwinjectStoryboard

extension SwinjectStoryboard {
    
    static func setupMotionActivityHistoryCoreFactory() {
        defaultContainer.register(ActivityHistoryCoreI.self) { _ in
            ActivityHistoryCore()
        }
    }
}

protocol ActivityHistoryCoreI {
    func getTrackingActivityHistory(forLastMins minutes: Int) -> Single<[CMMotionActivity]>
}

final class ActivityHistoryCore {
    private let activityManager = CMMotionActivityManager()
    
    enum MotionActivityHistoryError: Error {
        case motionActivityNotEnable
    }
}

extension ActivityHistoryCore: ActivityHistoryCoreI {
    
    func getTrackingActivityHistory(forLastMins minutes: Int) -> Single<[CMMotionActivity]> {
        
        return Single.create { [weak self] single in
            
            let startDate = Calendar.current.date(byAdding: .minute, value: (minutes * -1), to: Date())!
            self?.activityManager.queryActivityStarting(from: startDate, to: Date(), to: OperationQueue.main) { (motionActivity, error) in
                if (error != nil) {
                    single(.error(MotionActivityHistoryError.motionActivityNotEnable))
                } else if let motions = motionActivity {
                    print(motions)
                    single(.success(motions))
                }
            }
            return Disposables.create()
        }
    }
}
