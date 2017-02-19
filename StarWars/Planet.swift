//
//  Planet.swift
//  StarWars
//
//  Created by Ephraim Kunz on 1/31/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import Foundation
struct Planet: Displayable{
    var name: String
    var id: String
    var mainImageLink: URL?
    var alternateId: String?
    
    var rotationPeriod: String?
    var orbitalPeriod: String?
    var diameter: String?
    var climate: String?
    var gravity: String?
    var terrains: [String] = []
    var surfaceWater: String?
    var population: String?
    var residents: [String] = []
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
    
    mutating func addPlanetProperties(json: [String: Any]){
        self.rotationPeriod = json["rotation_period"] as? String
        self.orbitalPeriod = json["orbital_period"] as? String
        self.diameter = json["diameter"] as? String
        self.climate = json["climate"] as? String
        self.gravity = json["gravity"] as? String
        self.surfaceWater = json["surface_water"] as? String
        self.population = json["population"] as? String
        
        if let terrainArray = json["terrain"] as? String{
            terrains = terrainArray.components(separatedBy: ",")
        }
        
        if let filmsArray = json["films"] as? [Any]{
            for film in filmsArray{
                if let film = film as? String{
                    films.append(DataUtilities.idFromUrl(url: film))
                }
            }
        }
        
        if let residentsArray = json["residents"] as? [Any]{
            for resident in residentsArray{
                if let resident = resident as? String{
                    residents.append(DataUtilities.idFromUrl(url: resident))
                }
            }
        }
    }
}
