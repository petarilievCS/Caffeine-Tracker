//
//  SettingsCellTableViewCell.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 13.2.23.
//

import UIKit

class SettingsCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        notificationSwitch.isOn = UserDefaults.standard.bool(forKey: K.notificationPermission)
        notificationSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func switchChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        if value {
            UserDefaults.standard.set(true, forKey: K.notificationPermission)
        } else {
            UserDefaults.standard.set(false, forKey: K.notificationPermission)
        }
    }
    
}

