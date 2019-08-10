//
//  PeripheralTableViewCell.swift
//  itagone
//
//  Created by  Sergey Dolin on 08/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import CoreBluetooth
import UIKit

class PeripheralTableViewCell: UITableViewCell {
    @IBOutlet weak var uuid: UILabel?
    @IBOutlet weak var name: UILabel?
    @IBOutlet weak var button: UIButton?

    let factory: TagFactoryInterface
    let imagePlus = UIImage(named: "btnPlus")
    let imageMinus = UIImage(named: "btnMinus")
    let store: TagStoreInterface

    var _peripheral: CBPeripheral?

    var peripheral: CBPeripheral? {
        set (it) {
            _peripheral = it
            uuid?.text = it?.identifier.uuidString
            name?.text = it?.name
            let remembered = it != nil && store.remembered(id: it!.identifier.uuidString)
            button?.setImage(remembered ? imageMinus : imagePlus, for: .normal)
        }
        get {
            return _peripheral
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        store = TagStoreDefault.shared
        factory = TagFactoryDefault.shared
        
        super.init(coder: aDecoder)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onButton(_ sender: UIView) {
        guard let peripheral = peripheral else { return }
        if store.remembered(id: peripheral.identifier.uuidString) {
            store.forget(id: peripheral.identifier.uuidString)
        } else {
            store.remember(tag: createTag(fromPeripheral: peripheral))
        }
    }
    
    private func createTag(fromPeripheral: CBPeripheral) -> TagInterface {
        let id = fromPeripheral.identifier.uuidString
        let existing = store.by(id: id)
        if existing == nil {
            return TagDefault(id: id, name: fromPeripheral.name?.trimmingCharacters(in: .whitespacesAndNewlines), color: nil, alert: nil)
        } else {
            return TagDefault(id: id, name: existing!.name, color: existing!.color, alert: existing!.alert)
        }
    }
    
}
