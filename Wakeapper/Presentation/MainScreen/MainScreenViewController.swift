//  Generated by Generamba
//
//  MainScreenMainScreenViewController.swift
//  Wakeapper
//
//  Created by Sergey Borovikov on 30/09/2018.
//  Copyright © 2018 Company. All rights reserved.
//

/*
 1. Сработал локальный пуш (нужно понять на сколько длинную мелодию можно вставить на звук пуша)
 2. Тап на пуш, запуск приложения.
 З. Запускается детектор просыпания (WakeupDetectorService для UI отображения процесса отслеживания).
 4. Регистрируется новая локальная Push нотификация, через время просыпания (+ 10 секунд, для возможности отозвать локальную нотификацию).
 5. Если приложение не сворачивается все время просыпания, ориентируемся на WakeupDetectorService, отменяем локальную нотификацию.
 6. Если приложение свернули, то при обработке нажатия на нотификацию используем ActivityHistoryService
 */

import UIKit
import RxCocoa
import RxSwift
import Repeat

class MainScreenViewController: UIViewController {

    var viewModel: MainScreenViewModelI!
    var router: MainScreenRouterI!
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var moveLabel: UILabel!
    @IBOutlet weak var smallTimerLabel: UILabel!
    @IBOutlet weak var bigTimerLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var moveDetectorView: UIView!
    
    private var wakeupType: WakeupDetectorType = .none {
        didSet { self.markupView() }
    }
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moveLabel.text = "Moved!"
        moveLabel.alpha = 0
        
        bindViewModelInput()
        bindViewModelOutput()
        setupBackgroundEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        setupUI()
    }
    
    private func setupUI() {
        moveDetectorView.layer.cornerRadius = moveDetectorView.frame.size.height/2
    }
    
    private func bindViewModelInput() {
        button.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.onButton()
        }).disposed(by: disposeBag)
    }
    
    private func bindViewModelOutput() {
        
        viewModel.moveDetection
            .subscribe(onNext: { [weak self] isMovedDetection in
                self?.fadeAnimateLabel()
                self?.fadeAnimateMoveDetectorView()
            }).disposed(by: disposeBag)

        viewModel.bigTimerObservable.asObservable()
            .subscribe(onNext: { sec in
                self.bigTimerLabel.text = String(sec)
            }).disposed(by: disposeBag)

        viewModel.wakeupDetectorType
            .subscribe(onNext: { [weak self] wakeupType in
                self?.wakeupType = wakeupType
            }).disposed(by: disposeBag)
        
        viewModel.activityHistory
            .subscribe(onSuccess: { _ in
                print("activityHistory SUCCESS!")
            }) { _ in
                print("activityHistory FAILE!")
        }.disposed(by: disposeBag)
    }
    
    private func setupBackgroundEvents() {
        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
            .subscribe(onNext: { event in
//            print(event)
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification)
            .subscribe(onNext: { event in
//                print(event)
            }).disposed(by: disposeBag)
    }
    
    private func fadeAnimateLabel() {
        self.moveLabel.alpha = 1
        UIView.animate(withDuration: TimeInterval(10)) {
            self.moveLabel.alpha = 0
        }
    }
    
    private func fadeAnimateMoveDetectorView() {
        self.moveDetectorView.alpha = 1
        UIView.animate(withDuration: TimeInterval(0.5)) {
            self.moveDetectorView.alpha = 0
        }
    }
    
    private func markupView() {
        switch wakeupType {
        case .none:
            self.view.backgroundColor = .white
        case .sleepWasDetected:
            self.view.backgroundColor = .red
            self.infoLabel.text = "You fell asleep"
            
        case .wakeupWasDetected:
            self.view.backgroundColor = .green
            self.infoLabel.text = "You're awake!"

        }
    }
}

// test
extension MainScreenViewController {
    
    
    
    
}
