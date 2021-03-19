//
//  Comment.swift
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

enum Comment: ASTNode, Hashable {
    case block(String)
    case inline(String)

    var debugDescription: String {
        switch self {
        case let .block(text):
            return "<SION:BlockComment: '\(text)'>"
        case let .inline(text):
            return "<SION:InlineComment: '\(text)'>"
        }

    }

}
