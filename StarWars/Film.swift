//
//  Film.swift
//  StarWars
//
//  Created by Ephraim Kunz on 1/31/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import Foundation
struct Film: Displayable{
    var title: String
    var id: String
    var mainImageLink: String?
    
    init(json: [String: Any]) {
        self.title = json["title"] as! String
        self.id = json["url"] as! String
    }
    
    func getName() -> String {
        return title
    }
    
    func getId() -> String {
        return id
    }
    
    func getImageLink() -> String? {
        return mainImageLink
    }
}
