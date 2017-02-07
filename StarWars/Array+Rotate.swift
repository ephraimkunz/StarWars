//
//  Array+Rotate.swift
//  StarWars
//
//  Created by Ephraim Kunz on 2/6/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import Foundation

extension Array {
    func rotate(shift:Int) -> Array {
        var array = Array()
        if (self.count > 0) {
            array = self
            if (shift > 0) {
                for _ in 1...shift {
                    array.append(array.remove(at: 0))
                }
            }
            else if (shift < 0) {
                for _ in 1...abs(shift) {
                    array.insert(array.remove(at: array.count-1),at:0)
                }
            }
        }
        return array
    }
}
