//
//  ReminderSettingsViewController.swift
//  Nugget
//
//  Created by Ana Hidalgo de la Vega on 13/06/2020.
//  Copyright © 2020 ana. All rights reserved.
//

import Foundation
import UIKit

class ReminderSettingsViewController: UITableViewController {
    
    let frequencyOptions = ["3 months", "6 months", "9 months", "1 year", "Some time in 3 to 9 months", "7 seconds (demo)"]
    var selectedNugget : Nugget? = nil
    let saveNugget = SaveNugget()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // To remove separators in unused rows
        tableView.tableFooterView = UIView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frequencyOptions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FrequencyOptions", for: indexPath)
        cell.textLabel?.text = frequencyOptions[indexPath.row]
        
        if let selectedNugget = selectedNugget {
            cell.accessoryType = selectedNugget.frequency == frequencyOptions[indexPath.row] ? .checkmark : .none
        }
        else {
            print("Error retrieving selected nugget")
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectedNugget!.body != nil {
            selectedNugget!.frequency = frequencyOptions[indexPath.row]
            saveNugget.saveNugget()
            tableView.reloadData()
        }
        else {
            print("Error changing the frequency because the nugget is empty")
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

}
