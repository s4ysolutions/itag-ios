//
//  PeripheralTableViewCell.swift
//  itagone
//
//  Created by  Sergey Dolin on 08/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import UIKit

class PeripheralTableViewCell: UITableViewCell {
    @IBOutlet
    weak var uuid: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
