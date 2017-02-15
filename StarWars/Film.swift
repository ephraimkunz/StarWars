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
    
    var episodeId: String?
    var openingCrawl: String?
    var director: String?
    var producers: [String] = []
    var releaseDate: Date?
    var characters: [String] = []
    var planets: [String] = []
    var starships: [String] = []
    var vehicles: [String] = []
    var species: [String] = []

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
    
    mutating func addFilmProperties(json: [String: Any]){
        self.episodeId = String(describing: (json["episode_id"] as! Int))
        self.openingCrawl = json["opening_crawl"] as? String
        self.director = json["director"] as? String
        if let producersCSV = json["producer"] as? String{
            self.producers = producersCSV.components(separatedBy: ",")
        }
        
        if let releaseDateString = json["release_date"] as? String{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            self.releaseDate = dateFormatter.date(from: releaseDateString)
        }
        
        
        if let speciesArray = json["species"] as? [Any]{
            for specie in speciesArray{
                if let specie = specie as? String{
                    species.append(DataUtilities.idFromUrl(url: specie))
                }
            }
        }
        
        if let planetsArray = json["planets"] as? [Any]{
            for planet in planetsArray{
                if let planet = planet as? String{
                    planets.append(DataUtilities.idFromUrl(url: planet))
                }
            }
        }
        
        if let peopleArray = json["characters"] as? [Any]{
            for person in peopleArray{
                if let person = person as? String{
                    characters.append(DataUtilities.idFromUrl(url: person))
                }
            }
        }

        
        if let vehiclesArray = json["vehicles"] as? [Any]{
            for vehicle in vehiclesArray{
                if let vehicle = vehicle as? String{
                    vehicles.append(DataUtilities.idFromUrl(url: vehicle))
                }
            }
        }
        
        if let starshipsArray = json["starships"] as? [Any]{
            for starship in starshipsArray{
                if let starship = starship as? String{
                    starships.append(DataUtilities.idFromUrl(url: starship))
                }
            }
        }
    }
}
