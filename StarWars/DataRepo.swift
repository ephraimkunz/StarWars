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
private let WookieBaseUrl = "https://starwars.wikia.com/api.php?"
private let SWAPI_ITEMS_PER_PAGE = 10 //SWAPI gives us maximum 10 items at a time
private let thumbWidth = 300 //Width in pixels of a thumbnail image

class DataRepo {
    //Get all swapi items of type, walking through the paginated results and sorting the returned array
    static func getAllSwapiItems(type: EntityType, callback: @escaping ([Displayable]) -> Void){
        let requestUrl = getRequestUrl(type: type, id: nil)
        
        Alamofire.request(requestUrl).responseJSON{ response in
            switch response.result{
            case .success(let json):
                //print(json)
                
                //Begin the somewhat nasty Swift JSON parsing. When will they make this easier?
                var items: [Displayable] = [] //Hold the items that will be returned
                
                // Use a dispatch group to synchronize them all finishing
                let allPagesFetched = DispatchGroup()
                
                if let dict = json as? [String: Any]{
                    let count = dict["count"] as! Int
                    let pagesToFetch = count / SWAPI_ITEMS_PER_PAGE
                    
                    //Go get the other pages if any
                    if(pagesToFetch > 0){ // Don't fetch any pages if there are none to fetch
                        for page in 2...pagesToFetch + 1{
                            allPagesFetched.enter() //Enter the dispatch group
                            let url = requestUrl + "?page=\(page)"
                            
                            Alamofire.request(url).responseJSON{ response in
                                switch response.result{
                                case .success(let json):
                                    //print(json)
                                    
                                    if let dict = json as? [String: Any]{
                                        if let array = dict["results"] as? [Any]{
                                            items.append(contentsOf: unpackJSONArray(array: array, type: type))
                                        }
                                    }
                                case .failure(let error):
                                    print(error)
                                }
                                
                                allPagesFetched.leave() //Leave the group now
                            }
                        }
                    }
    
                    
                    if let array = dict["results"] as? [Any]{
                        items.append(contentsOf: unpackJSONArray(array: array, type: type))
                    }
                }
                
                allPagesFetched.notify(queue: DispatchQueue.main) {
                    callback(items.sorted{$1.getName() > $0.getName() })
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //Get menu items for first collectionView
    static func getAllTopLevelItems() -> [Displayable]{
        let menuItems = [
            TopLevelItem(EntityType.planets),
            TopLevelItem(EntityType.people),
            TopLevelItem(EntityType.films),
            TopLevelItem(EntityType.species),
            TopLevelItem(EntityType.starships),
            TopLevelItem(EntityType.vehicles)]
        
        return menuItems
    }
    
    //Instantiate and return a set of structs corresponding to a json array
    static func unpackJSONArray(array: [Any], type: EntityType) -> [Displayable]{
        var items: [Displayable] = []
        
        for item in array{
            if let item = item as? [String: Any]{
                
                //Seems like there should be a better way to do this
                var obj: Displayable
                switch(type){
                case .films:
                    obj = Film(json: item)
                case .people:
                    obj = Person(json: item)
                case .planets:
                    obj = Planet(json: item)
                case .species:
                    obj = Species(json: item)
                case .starships:
                    obj = Starship(json: item)
                case.vehicles:
                    obj = Vehicle(json: item)
                }
                items.append(obj)
            }
        }
        return items
    }
    
    //Get the basic url for an image (no thumbnail)
    private static func getUrlForImageUrl(name: String) -> String{
        var url = WookieBaseUrl
        let urlEncoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        url += "action=imageserving&wisTitle=\(urlEncoded)&format=json"
        return url
    }
    
    //Gets the thumbnail image url for a given item name
    static func getImageUrl(name: String, callback: @escaping (URL?) -> Void){

        let url = getUrlForImageUrl(name: name)
        Alamofire.request(url).responseJSON{ response in
            var url: URL?
            
            switch response.result{
            case .success(let json):
                if let dict = json as? [String: Any],
                let imgObj = dict["image"] as? [String: Any],
                let imageUrl = imgObj["imageserving"] as? String {
                    
                    var components = URLComponents(string: imageUrl)
                    components?.scheme = "https"
                    components?.path += "/scale-to-width-down/\(thumbWidth)"
                    url = try! components?.asURL()
                }
                
            case .failure(let error):
                print(error)
            }
            callback(url)
        }
    }
    
    //Gets the base swapi url for a given EntityType
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
