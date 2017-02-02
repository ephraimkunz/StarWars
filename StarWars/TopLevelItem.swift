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
    
    func getImageLink() -> URL? {
        return nil
    }
    
    func getId() -> String {
        return id
    }
    
    mutating func setImageLink(link: URL){
        //Don't think this will ever be called
    }
    
    mutating func setAlternateId(id: String){
        //Don't think this will ever be called
    }
}
