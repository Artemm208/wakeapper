//  Generated by Generamba
//
//  AlarmsAlarmsViewController.swift
//  Wakeapper
//
//  Created by Sergey Borovikov on 07/10/2018.
//  Copyright © 2018 Company. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class AlarmsViewController: UIViewController {

    var viewModel: AlarmsViewModelI!
    var router: AlarmsRouterI!

    private let bag = DisposeBag()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModelInput()
        bindViewModelOutput()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        setupUI()
    }

    private func setupUI() {
        self.title = "Alarms"
        self.view.backgroundColor = UIColor.green
    }

    private func bindViewModelInput() {
        
    }
    
    private func bindViewModelOutput() {
        
    }
}
