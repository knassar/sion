//
//  Numeric.swift
//  SION
//
//  Created by Karim Nassar on 3/18/21.
//  Copyright © 2017 Hungry Melon Studio LLC. All rights reserved.
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

enum Numeric: ASTValue, Hashable {

    case double(Double)
    case cgFloat(CGFloat)
    case float(Float)
    case int(Int)

    var sionValueType: SION.ValueType { .number }

    var debugDescription: String {
        switch self {
        case let .double(double):
            return "\(double)"
        case let .cgFloat(cgFloat):
            return "\(cgFloat)"
        case let .float(float):
            return "\(float)"
        case let .int(int):
            return "\(int)"
        }
    }

    var doubleValue: Double {
        switch self {
        case let .double(double):
            return double
        case let .cgFloat(cgFloat):
            return Double(cgFloat)
        case let .float(float):
            return Double(float)
        case let .int(int):
            return Double(int)
        }
    }

    var intValue: Int {
        switch self {
        case let .double(double):
            return Int(double)
        case let .cgFloat(cgFloat):
            return Int(cgFloat)
        case let .float(float):
            return Int(float)
        case let .int(int):
            return int
        }
    }

    static func == (lhs: Numeric, rhs: Numeric) -> Bool {
        switch (lhs, rhs) {
        case let (.double(left), .double(right)):
            return left == right
        case let (.cgFloat(left), .cgFloat(right)):
            return left == right
        case let (.float(left), .float(right)):
            return left == right
        case let (.int(left), .int(right)):
            return left == right
        default:
            return lhs.doubleValue == rhs.doubleValue || lhs.intValue == rhs.intValue
        }
    }

}
