//
//  JSONPrinter.swift
//  SION
//
//  Created by Karim Nassar on 1/23/19.
//  Copyright © 2019 HungryMelonStudios LLC. All rights reserved.
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

class JSONPrinter: Printer {

    let options: StringifyOptions

    private(set) var depth = 0
    private var currentPath = ""

    required init(options: StringifyOptions) {
        self.options = options
    }

    func print(_ node: SION) -> String {
        switch node.value {
        case let unkeyed as UnkeyedContainer:
            return printUnkeyedContainer(unkeyed)
        case let keyed as KeyedContainer:
            return printKeyedContainer(keyed)
        case let bool as Bool:
            return print(bool)
        case let date as Date:
            return print(date)
        case is Null:
            return printNull()
        case let string as String:
            return print(string)
        default:
            if node.isNumber {
                return print(node.doubleValue)
            } else {
                return ""
            }
        }
    }

    func printUnkeyedContainer(_ unkeyed: UnkeyedContainer) -> String {
        let lEnd = lineEnd()

        depth += 1
        let values = unkeyed.values.map { indent() + print($0) } .joined(separator: "," + lEnd )
        depth -= 1

        return ["[", values, indent() + "]"].joined(separator: lEnd)
    }

    func printKeyedContainer(_ keyed: KeyedContainer) -> String {
        let spc = space()
        let lEnd = lineEnd()

        depth += 1
        let keypairs = options.contains(.sortKeys) ? keyed.keyValuePairs.sorted() : keyed.keyValuePairs
        let values = (keypairs.map { keypair in
            return indent() + printKey(keypair.key) + ":\(spc)" + print(keypair.value)
            }).joined(separator: ",\(lEnd)")
        depth -= 1

        return ["{", values, indent() + "}"].joined(separator: lEnd)
    }

    func printKey(_ key: Key) -> String {
        return "\"\(escapeDoubleQuotes(key.name))\""
    }

}
