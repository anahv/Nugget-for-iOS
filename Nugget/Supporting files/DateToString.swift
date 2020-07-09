//
//  Supporting Functions.swift
//  Nugget
//
//  Created by Ana Hidalgo de la Vega on 13/06/2020.
//  Copyright © 2020 ana. All rights reserved.
//

import Foundation

class DateToString {
    
    func dateToString(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        let convertedDate = dateFormatter.string(from: date)
        return convertedDate
        
    }
    
}


