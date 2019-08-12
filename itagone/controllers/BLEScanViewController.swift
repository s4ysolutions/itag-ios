//
//  BLEScanViewController.swift
//  itagone
//
//  Created by  Sergey Dolin on 07/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import BLE
import CoreBluetooth
import Rasat
import UIKit

class BLEScanViewController: UIViewController {
    static let SCAN_TIMEOUT = 60
    
    @IBOutlet
    weak var progressBar: UIProgressView?
    var disposable: DisposeBag?
    let ble: BLEInterface
    let store: TagStoreInterface

    required init?(coder aDecoder: NSCoder) {
        ble = BLEDefault.shared
        store = TagStoreDefault.shared
        super.init(coder: aDecoder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        disposable?.dispose()
        disposable = DisposeBag()
        disposable?.add(ble.scanner.timerObservable.subscribe(on: DispatchQueue.main, id: "scanningTimer", handler: {timeout in
            self.updateProgress(timeout)
        }))
        progressBar?.isHidden = false
        progressBar?.progress = 1.0
        ble.scanner.start(timeout: BLEScanViewController.SCAN_TIMEOUT, forceCancelIds: store.forgottenIds())
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ble.scanner.stop()
        disposable?.dispose()
        disposable = nil
    }

    
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction
    func back(_ sender: UIView) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - observe scanning
    func updateProgress(_ timeout: Int) {
        progressBar?.isHidden = timeout <= 0
        progressBar?.progress = Float(timeout ) / Float(BLEScanViewController.SCAN_TIMEOUT)
    }
    

}
