//
//  Entity.swift
//  StarWars
//
//  Created by Ephraim Kunz on 1/28/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import Foundation

enum EntityType{
    case starships
    case people
    case films
    case species
    case planets
    case vehicles
    
    func getName() -> String{
        switch self {
        case .starships:
            return "Starships"
        case .people:
            return "People"
        case .films:
            return "Films"
        case .species:
            return "Species"
        case .planets:
            return "Planets"
        case .vehicles:
            return "Vehicles"
        }
    }
}
