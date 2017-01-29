//
//  DataRepo.swift
//  StarWars
//
//  Created by Ephraim Kunz on 1/28/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import Foundation
import Alamofire

private let SwapiBaseUrl = "https://swapi.co/api/"

class DataRepo {
    static func getAllItems(type: EntityType, callback: @escaping ([Item]) -> Void){
        let requestUrl = getRequestUrl(type: type, id: nil)
        
        Alamofire.request(requestUrl).responseJSON{ response in
            switch response.result{
            case .success(let json):
                print(json)
                
                //Begin the somewhat nasty Swift JSON parsing. When will they make this easier?
                var items: [Item] = []
                if let dict = json as? [String: Any]{
                    if let array = dict["results"] as? [Any]{
                        for item in array{
                            if let item = item as? [String: Any]{
                                if let newItemObj = Item(json: item){
                                    items.append(newItemObj)
    
                                }
                            }
                        }
                    }
                }
                callback(items)
                break
                
            case .failure(let error):
                print(error)
                break
            }
        }
    }
    
    private static func getRequestUrl(type: EntityType, id: Int?) -> String {
        var url = SwapiBaseUrl
        
        switch(type){
        case .films:
            url += "films/"
            break;
        case .people:
            url += "people/"
            break;
        case .planets:
            url += "planets/"
            break;
        case .species:
            url += "species/"
            break;
        case .starships:
            url += "starships/"
            break;
        case .vehicles:
            url += "vehicles/"
            break;
        }
        
        if let id = id{
            url += "\(id)/"
        }
        
        return url
    }
}
