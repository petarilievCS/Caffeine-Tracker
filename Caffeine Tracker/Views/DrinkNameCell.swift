//
//  TableViewCell.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 2.1.23.
//

import UIKit

class DrinkNameCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.textColor = .secondaryLabel
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
