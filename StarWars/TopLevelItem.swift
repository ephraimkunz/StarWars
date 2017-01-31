//
//  CollectionItem.swift
//  StarWars
//
//  Created by Ephraim Kunz on 1/31/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import Foundation

private let ID = "CollectionItem"

struct TopLevelItem: Displayable{
    var type: EntityType
    let id = ID
    
    init(_ type: EntityType) {
        self.type = type
    }
    
    func getName() -> String {
        return type.getName()
    }
    
    func getImageLink() -> String? {
        return nil
    }
    
    func getId() -> String {
        return id
    }
    
    mutating func setImageLink(link: String){
        //Don't think this will ever be called
    }
}
