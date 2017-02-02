//
//  Displayable.swift
//  StarWars
//
//  Created by Ephraim Kunz on 1/31/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import Foundation

protocol Displayable {
    func getName() -> String
    func getImageLink() -> URL?
    func getId() -> String
    mutating func setImageLink(link: URL)
    mutating func setAlternateId(id: String)
}
