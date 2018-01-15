//
//  SION+Comparison.swift
//  SION
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

extension SION: Hashable {

    public var hashValue: Int {
        switch type {
        case .string:
            return (value as? String)?.hashValue ?? 0
        case .bool:
            return (value as? Bool)?.hashValue ?? 0
        case .number:
            return (value as? Double)?.hashValue ?? 0
        case .date:
            return (value as? Date)?.hashValue ?? 0
        case .array:
            let hash = arrayValue.map { $0.hashValue } .reduce(0) { $0 ^ $1 }
            return "array:\(hash)".hashValue
        case .dictionary:
            let v = dictionaryValue
            let hash = v.keys.map { "\($0):\(v[$0]?.hashValue ?? 0)".hashValue } .reduce(0) { $0 ^ $1 }
            return "dict:\(hash)".hashValue
        case .undefined, .null:
            return 0
        }
    }

    public static func ==(l: SION, r: SION) -> Bool {
        switch (l.type, r.type) {
        case (.string, .string):
            return l.string == r.string
        case (.bool, .bool):
            return l.bool == r.bool
        case (.number, .number):
            return l.number == r.number
        case (.date, .date):
            return l.date == r.date
        case (.array, .array):
            guard
                let lArr = l.array,
                let rArr = r.array,
                lArr.count == rArr.count
                else { return false }
            for (a, b) in zip(lArr, rArr) {
                guard a == b else { return false }
            }
            return true
        case (.dictionary, .dictionary):
            guard
                let lDict = l.dictionary,
                let rDict = r.dictionary,
                lDict.keys.count == rDict.keys.count
                else { return false }

            for key in lDict.keys {
                guard lDict[key] == rDict[key] else { return false }
            }
            return true
        case (.null, .null):
            return true
        case (.undefined, .undefined):
            return false
        default:
            return false
        }
    }

    /**
     Compare a dictionary or array SION value for order.

     - returns:
    `true` if the values of the receiver and the `other` SION are equal and in the same order

     - parameters:
         - other: The other SION value to compare against
     */
    public func isOrderedSame(as other: SION) -> Bool {
        if isArray {
            return self == other
        }

        guard let l = keyValuePairs, let r = other.keyValuePairs else {
            return false
        }

        for (kv1, kv2) in zip(l, r) {
            if kv1.0 != kv2.0 || kv1.1 != kv2.1 {
                return false
            }
        }
        return true
    }

}

