//
//  CharacterSet+Utils.swift
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

extension CharacterSet {

    func hasMember(_ character: Character) -> Bool {
        var found = true
        for ch in String(character).utf16 {
            if !(self as NSCharacterSet).characterIsMember(ch) {
                found = false
            }
        }
        return found
    }

}

extension String {

    func containsMember(of characterSet: CharacterSet) -> Bool {
        for char in self.utf16 {
            if (characterSet as NSCharacterSet).characterIsMember(char) {
                return true
            }
        }
        return false
    }

}
