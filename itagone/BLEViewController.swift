//
//  ViewController.swift
//  itagone
//
//  Created by  Sergey Dolin on 06/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import UIKit
import Rasat

class BLEViewController: UIViewController {
    static let TIMEOUT = 60
    @IBOutlet
    weak var progressBar: UIProgressView?
    var ble: BLE?
    var disposable: DisposeBag?
    
    required init?(coder aDecoder: NSCoder) {
//        ble = BLEDefault.shared
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ble = BLEDefault.shared
    }
    
    override func viewWillAppear(_ animated: Bool) {
        progressBar?.isHidden = !( ble!.isScanning )
        progressBar?.progress = Float(ble!.scanningTimeout ) / Float(BLEViewController.TIMEOUT)
        disposable?.dispose()
        disposable = DisposeBag()
        disposable?.add(ble!.scannerTimerObservable.subscribe(on: DispatchQueue.main, id: "scanningTimer", handler: {timeout in
            self.progressBar?.isHidden = timeout <= 0
            self.progressBar?.progress = Float(timeout ) / Float(BLEViewController.TIMEOUT)
        }))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        disposable?.dispose()
        disposable = nil
    }

    @IBAction
    func onStartScan(_ :UIView) {
        progressBar?.progress = 1.0
        progressBar?.isHidden = false
        ble!.startScan(timeout: BLEViewController.TIMEOUT)
    }
}

