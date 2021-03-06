//
//  OrderedKey.swift
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

extension SION {

    struct OrderedKey: SIONKey, Hashable {
        let key: String
        let order: Int

        init(_ key: String, _ order: Int = 0) {
            self.key = key
            self.order = order
        }

        var hashValue: Int {
            return key.hashValue
        }

        static func == (lhs: OrderedKey, rhs: OrderedKey) -> Bool {
            return lhs.key == rhs.key
        }
    }

}
