//
//  Person.swift
//  StarWars
//
//  Created by Ephraim Kunz on 1/31/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import Foundation
struct Person: Displayable{
    var name: String
    var id: String
    var mainImageLink: URL?
    var alternateId: String?
    
    var height: String?
    var mass: String?
    var hairColor: String?
    var skinColor: String?
    var eyeColor: String?
    var birthYear: String?
    var gender: String?
    var homeworldId: String?
    var speciesId: String?
    
    var films: [String] = []
    var vehicles: [String] = []
    var starships: [String] = []
    
    
    init(json: [String: Any]) {
        self.name = json["name"] as! String
        self.id = DataUtilities.idFromUrl(url: json["url"] as! String)
    }
    
    mutating func addPersonProperties(json: [String: Any]){
        self.height = json["height"] as? String
        self.mass = json["mass"] as? String
        self.hairColor = json["hair_color"] as? String
        self.eyeColor = json["eye_color"] as? String
        self.skinColor = json["skin_color"] as? String
        self.birthYear = json["birth_year"] as? String
        self.gender = json["gender"] as? String
        
        if let homeworldPath = json["homeworld"] as? String{
            self.homeworldId = DataUtilities.idFromUrl(url: homeworldPath)
        }
    }
    
    func getName() -> String {
        return name
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
