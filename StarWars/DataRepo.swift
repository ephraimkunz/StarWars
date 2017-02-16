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

/*
 The api we use to get all the images for a given person or thing unfortunately returns a lot of images
 that are not pertinant (i.e. logos for the webpage). We will filter these out here until we find something
 better.
 */
private let badImageNames: Set<String> = [
    "http://vignette3.wikia.nocookie.net/starwars/images/8/83/Encyclopedia-Logo.jpg/revision/latest?cb=20110914173933",
    "http://vignette2.wikia.nocookie.net/starwars/images/3/3c/Eras-canon.png/revision/latest?cb=20140430172811",
    "http://vignette4.wikia.nocookie.net/starwars/images/d/db/StarWars-DatabankII.png/revision/latest?cb=20140701201231",
    "http://vignette3.wikia.nocookie.net/starwars/images/c/c8/TCW_mini_logo.jpg/revision/latest?cb=20081006205514",
    "http://vignette1.wikia.nocookie.net/starwars/images/7/7d/Tab-canon-white.png/revision/latest?cb=20140430180745",
    "http://vignette1.wikia.nocookie.net/starwars/images/2/28/Tab-legends-black.png/revision/latest?cb=20140430180745",
    "http://vignette4.wikia.nocookie.net/starwars/images/2/28/SWCustom-2011.png/revision/latest?cb=20110915020525",
    "http://vignette2.wikia.nocookie.net/starwars/images/f/f8/30px-Era-Sprotect.png/revision/latest?cb=20081224180022",
    "http://vignette4.wikia.nocookie.net/starwars/images/7/7e/Droid_Tales_mini_logo.jpg/revision/latest?cb=20160521045748",
    "http://vignette4.wikia.nocookie.net/starwars/images/c/ca/The_Freemakers_mini_logo.png/revision/latest?cb=20160521052417",
    "http://vignette1.wikia.nocookie.net/starwars/images/b/b9/Rebels-mini-logo.png/revision/latest?cb=20140812005323",
    "http://vignette1.wikia.nocookie.net/starwars/images/a/a6/Gnome-speakernotes.png/revision/latest?cb=20050614200519",
    "http://vignette2.wikia.nocookie.net/starwars/images/5/53/HasbroInverted.png/revision/latest?cb=20151007232731",
    "http://vignette4.wikia.nocookie.net/starwars/images/4/4c/30px-Era-imp.png/revision/latest?cb=20070930172639",
    "http://vignette2.wikia.nocookie.net/starwars/images/d/d3/30px-Era-reb.png/revision/latest?cb=20070930172814",
    "http://vignette2.wikia.nocookie.net/starwars/images/2/26/30px-FormerGAicon.png/revision/latest?cb=20081006233608",
    "http://vignette2.wikia.nocookie.net/starwars/images/d/dc/SWRM.png/revision/latest?cb=20151003201234",
    "http://vignette1.wikia.nocookie.net/starwars/images/8/83/SWInsider.png/revision/latest?cb=20150108044956",
    "http://vignette3.wikia.nocookie.net/starwars/images/b/bf/LEGO.png/revision/latest?cb=20140302164226",
    "http://vignette1.wikia.nocookie.net/starwars/images/4/46/New_HNN.png/revision/latest?cb=20140729143503"
    
]

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
    static func getAllTopLevelItems() -> [TopLevelItem]{
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
    
    private static func getUrlForAllImages(name: String) -> String{
        var urlString = WookieBaseUrl
        let urlEncoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        urlString += "action=query&generator=images&titles=\(urlEncoded)&indexpageids=&prop=imageinfo&iiprop=url&iiurlwidth=300&format=json"
        return urlString
    }
    
    //Gets the thumbnail image url for a given item name
    static func getImageUrl(name: String, scaledDown: Bool, callback: @escaping (URL?) -> Void){

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
                    if scaledDown{
                        components?.path += "/scale-to-width-down/\(thumbWidth)"
                    }
                    url = try! components?.asURL()
                }
                
            case .failure(let error):
                print(error)
            }
            callback(url)
        }
    }
    
    //Gets all images (full size) for a given item name
    static func getImageUrls(name: String, callback: @escaping ([URL]) -> Void){
        let url = getUrlForAllImages(name: name)
        
        Alamofire.request(url).responseJSON{ response in
            var urls: [URL] = []
            
            switch response.result{
            case .success(let json):
                if let dict = json as? [String: Any],
                    let query = dict["query"] as? [String: Any],
                    let pageids = query["pageids"] as? [String],
                    let pages = query["pages"] as? [String: Any] {
                    
                    for pageid in pageids{
                        if let page = pages[pageid] as? [String: Any],
                        let imageinfo = (page["imageinfo"] as? [Any])? [0] as? [String: Any],
                            let thumburl = imageinfo["url"] as? String{
                            if badImageNames.contains(thumburl){ continue} //Filter out irrelevant images
                            
                            var components = URLComponents(string: thumburl)!
                            components.scheme = "https"
                            urls.append(try! components.asURL())
                        }
                    }
                }
                
            case .failure(let error):
                print(error)
            }
            callback(urls)
        }
    }
    
    //Gets the base swapi url for a given EntityType
    private static func getRequestUrl(type: EntityType, id: String?) -> String {
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
    
    static func getNameForId(id: String, type: EntityType, callback: @escaping (String?) -> Void){
        let requestUrl = getRequestUrl(type: type, id: id)
        
        Alamofire.request(requestUrl).responseJSON{ response in
            switch response.result{
            case .success(let json):
                //print(json)
                
                var name: String?
                
                if let dict = json as? [String: Any]{
                    let jsonName = type == EntityType.films ? "title" : "name"
                    name = dict[jsonName] as? String
                }
                callback(name)
                
            case .failure(let error):
                print(error)
                callback(nil)
            }
        }

    }
    
    //MARK: Individual Items
    static func getPerson(id: String, callback: @escaping (Person?) -> Void){
        let requestUrl = getRequestUrl(type: .people, id: id)
        
        Alamofire.request(requestUrl).responseJSON{ response in
            switch response.result{
            case .success(let json):
                //print(json)
                
                var item: Person?
                
                if let dict = json as? [String: Any]{
                    item = Person(json: dict)
                    item!.addPersonProperties(json: dict)
                }
                callback(item)
                
            case .failure(let error):
                print(error)
                callback(nil)
            }
        }
    }
    
    static func getFilm(id: String, callback: @escaping (Film?) -> Void){
        let requestUrl = getRequestUrl(type: .films, id: id)
        
        Alamofire.request(requestUrl).responseJSON{ response in
            switch response.result{
            case .success(let json):
                //print(json)
                
                var item: Film?
                
                if let dict = json as? [String: Any]{
                    item = Film(json: dict)
                    item!.addFilmProperties(json: dict)
                }
                callback(item)
                
            case .failure(let error):
                print(error)
                callback(nil)
            }
        }
    }

    static func getPlanet(id: String, callback: @escaping (Planet?) -> Void){
        let requestUrl = getRequestUrl(type: .planets, id: id)
        
        Alamofire.request(requestUrl).responseJSON{ response in
            switch response.result{
            case .success(let json):
                //print(json)
                
                var item: Planet?
                
                if let dict = json as? [String: Any]{
                    item = Planet(json: dict)
                    item!.addPlanetProperties(json: dict)
                }
                callback(item)
                
            case .failure(let error):
                print(error)
                callback(nil)
            }
        }
    }
    
    static func getSpecies(id: String, callback: @escaping (Species?) -> Void){
        let requestUrl = getRequestUrl(type: .species, id: id)
        
        Alamofire.request(requestUrl).responseJSON{ response in
            switch response.result{
            case .success(let json):
                //print(json)
                
                var item: Species?
                
                if let dict = json as? [String: Any]{
                    item = Species(json: dict)
                    item!.addSpeciesProperties(json: dict)
                }
                callback(item)
                
            case .failure(let error):
                print(error)
                callback(nil)
            }
        }
    }
    
    static func getVehicle(id: String, callback: @escaping (Vehicle?) -> Void){
        let requestUrl = getRequestUrl(type: .vehicles, id: id)
        
        Alamofire.request(requestUrl).responseJSON{ response in
            switch response.result{
            case .success(let json):
                //print(json)
                
                var item: Vehicle?
                
                if let dict = json as? [String: Any]{
                    item = Vehicle(json: dict)
                    item!.addVehicleProperties(json: dict)
                }
                callback(item)
                
            case .failure(let error):
                print(error)
                callback(nil)
            }
        }
    }
    
    static func getStarship(id: String, callback: @escaping (Starship?) -> Void){
        let requestUrl = getRequestUrl(type: .starships, id: id)
        
        Alamofire.request(requestUrl).responseJSON{ response in
            switch response.result{
            case .success(let json):
                //print(json)
                
                var item: Starship?
                
                if let dict = json as? [String: Any]{
                    item = Starship(json: dict)
                    item!.addStarshipProperties(json: dict)
                }
                callback(item)
                
            case .failure(let error):
                print(error)
                callback(nil)
            }
        }
    }
}
