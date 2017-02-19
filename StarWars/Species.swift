//
//  Species.swift
//  StarWars
//
//  Created by Ephraim Kunz on 1/31/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import Foundation
struct Species: Displayable{
    var name: String
    var id: String
    var mainImageLink: URL?
    var alternateId: String?
    
    var classification: String?
    var designation: String?
    var averageHeight: String?
    var skinColors: [String] = []
    var hairColors: [String] = []
    var eyeColors: [String] = []
    var averageLifespan: String?
    var homeworld: String?
    var language: String?
    var people: [String] = []
    var films: [String] = []
    
    init(json: [String: Any]) {
        self.name = json["name"] as! String
        self.id = DataUtilities.idFromUrl(url: json["url"] as! String)
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
    
    mutating func addSpeciesProperties(json: [String: Any]){
        self.classification = json["classification"] as? String
        self.designation = json["designation"] as? String
        self.averageHeight = json["average_height"] as? String
        self.language = json["language"] as? String
        self.averageLifespan = json["average_lifespan"] as? String
        
        if let homeworld = json["homeworld"] as? String{
            self.homeworld = DataUtilities.idFromUrl(url: homeworld)
        }
        
        if let skinArray = json["skin_colors"] as? String{
            skinColors = skinArray.components(separatedBy: ",")
        }
        
        if let hairArray = json["hair_colors"] as? String{
            hairColors = hairArray.components(separatedBy: ",")
        }
        
        if let eyeArray = json["eye_colors"] as? String{
            eyeColors = eyeArray.components(separatedBy: ",")
        }
        
        if let filmsArray = json["films"] as? [Any]{
            for film in filmsArray{
                if let film = film as? String{
                    films.append(DataUtilities.idFromUrl(url: film))
                }
            }
        }
        
        if let peopleArray = json["people"] as? [Any]{
            for person in peopleArray{
                if let person = person as? String{
                    people.append(DataUtilities.idFromUrl(url: person))
                }
            }
        }
    }
}
