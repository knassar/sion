//
//  Utils.swift
//  SIONTests
//
//  Created by Karim Nassar on 1/14/18.
//  Copyright © 2018 Hungry Melon Studio LLC. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
