//
//  PeripheralsTableViewController.swift
//  itagone
//
//  Created by  Sergey Dolin on 08/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import BLE
import CoreBluetooth
import Rasat
import UIKit

class PeripheralsTableViewController: UITableViewController {
    var disposable: DisposeBag?
    var peripherals = [] as [CBPeripheral]
    let ble: BLEInterface
    let store: TagStoreInterface
    
    required init?(coder aDecoder: NSCoder) {
        ble = BLEDefault.shared
        store = TagStoreDefault.shared
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "PeripheralTableViewCell", bundle: nil), forCellReuseIdentifier: "peripheralCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        disposable?.dispose()
        disposable = DisposeBag()
        disposable?.add(ble.scanner.peripheralsObservable.subscribe(on: DispatchQueue.main, id: "scanning", handler: {peripheral in
            self.updatePeripheral(peripheral)
        }))
        disposable?.add(store.observable.subscribe(on: DispatchQueue.main, id: "scaning store", handler: {op in
            print("peripherals got notification store changed")
            self.tableView.reloadData()
        }))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        disposable?.dispose()
        disposable = nil
    }
    
    func updatePeripheral(_ peripheral: CBPeripheral) {
        for p in peripherals {
            if (p.identifier == peripheral.identifier) {
                return
            }
        }
        print("add peripheral into tableview", peripheral)
        peripherals.append(peripheral)
        tableView.reloadData()
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peripheralCell", for: indexPath) as! PeripheralTableViewCell

        let peripheral = peripherals[indexPath.row]
        cell.peripheral = peripheral
        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
