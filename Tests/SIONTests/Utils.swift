//
//  File.swift
//  
//
//  Created by Karim Nassar on 3/18/21.
//

import Foundation

func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ min: Int = 0, _ sec: Int = 0) -> Date? {
    var date = DateComponents()
    date.calendar = Calendar.current
    date.timeZone = TimeZone(abbreviation: "GMT")
    date.year = year
    date.month = month
    date.day = day
    date.hour = hour
    date.minute = min
    date.second = sec

    return date.date
}
