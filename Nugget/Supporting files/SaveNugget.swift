//
//  SaveNugget.swift
//  Nugget
//
//  Created by Ana Hidalgo de la Vega on 19/06/2020.
//  Copyright © 2020 ana. All rights reserved.
//

import Foundation
import UIKit

//added hasChanges.

class SaveNugget {
    func saveNugget() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            try context.save()
        }
        catch {
            print("Error saving context \(error)")
        }
        print("Nugget saved")
    }
    
}
