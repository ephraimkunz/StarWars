//
//  Vehicle.swift
//  StarWars
//
//  Created by Ephraim Kunz on 1/31/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import Foundation
struct Vehicle: Displayable {
    var name: String
    var id: String
    var alternateId: String?
    var mainImageLink: URL?
    
    var model: String?
    var manufacturer: String?
    var cost: String?
    var length: String?
    var speed: String?
    var crew: String?
    var passengers: String?
    var cargoCapacity: String?
    var consumables: String?
    var vehicleClass: String?
    var pilots: [String] = []
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

    mutating func addVehicleProperties(json: [String: Any]){
        self.model = json["model"] as? String
        self.manufacturer = json["manufacturer"] as? String
        self.cost = json["cost_in_credits"] as? String
        self.length = json["length"] as? String
        self.speed = json["max_atmosphering_speed"] as? String
        self.crew = json["crew"] as? String
        self.passengers = json["passengers"] as? String
        self.cargoCapacity = json["cargo_capacity"] as? String
        self.consumables = json["consumables"] as? String
        self.vehicleClass = json["vehicle_class"] as? String
        
        if let pilotsArray = json["pilots"] as? [Any]{
            for pilot in pilotsArray{
                if let pilot = pilot as? String{
                    pilots.append(DataUtilities.idFromUrl(url: pilot))
                }
            }
        }
        
        if let filmsArray = json["films"] as? [Any]{
            for film in filmsArray{
                if let film = film as? String{
                    films.append(DataUtilities.idFromUrl(url: film))
                }
            }
        }
    }
}
