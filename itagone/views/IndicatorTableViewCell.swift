//
//  IndicatorTableViewCell.swift
//  itagone
//
//  Created by  Sergey Dolin on 12/08/2019.
//  Copyright © 2019  Sergey Dolin. All rights reserved.
//

import UIKit

class IndicatorTableViewCell: UITableViewCell {
    @IBOutlet weak var indicator: UIActivityIndicatorView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        indicator?.startAnimating()
        // Initialization code
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        indicator?.startAnimating()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
