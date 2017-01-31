//
//  Starship.swift
//  StarWars
//
//  Created by Ephraim Kunz on 1/31/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import Foundation
struct Starship: Displayable{
    var name: String
    var id: String
    var mainImageLink: String?
    
    init(json: [String: Any]) {
        self.name = json["name"] as! String
        self.id = json["url"] as! String
    }
    
    func getName() -> String {
        return name
    }
    
    func getId() -> String {
        return id
    }
    
    func getImageLink() -> String? {
        return mainImageLink
    }
    
    mutating func setImageLink(link: String){
        mainImageLink = link
    }
}
