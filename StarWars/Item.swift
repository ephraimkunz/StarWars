//
//  Item.swift
//  StarWars
//
//  Created by Ephraim Kunz on 1/28/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import Foundation
struct Item{
    var name: String
    
    init?(json: [String: Any]) {
        //People, species, planets, starships and vehicles have names
        if let name = json["name"] as? String {
           self.name = name
        }
        else{
            //Films have titles
            if let title = json["title"] as? String{
                self.name = title
            }
            else{
                return nil
            }
        }
        
    }
}
