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
    var mainImageLink: URL?
    var alternateId: String?
    
    init(json: [String: Any]) {
        self.title = json["title"] as! String
        self.id = DataUtilities.idFromUrl(url: json["url"] as! String)
    }
    
    func getName() -> String {
        return title
    }
    
    func getId() -> String {
        return id
    }
    
    func getImageLink() -> URL? {
        return mainImageLink
    }
    
    mutating func setImageLink(link: URL){
        mainImageLink = link
    }
    
    mutating func setAlternateId(id: String){
        alternateId = id
    }
}
