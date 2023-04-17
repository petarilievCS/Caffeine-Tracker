//
//  DateCell.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 27.2.23.
//

import UIKit

class DateCell: UITableViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .secondarySystemBackground
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
