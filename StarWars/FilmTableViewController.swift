//
//  FilmTableViewController.swift
//  StarWars
//
//  Created by Ephraim Kunz on 2/11/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import UIKit
import IDMPhotoBrowser

private let FULL_IMAGE_SECTION = 0
private let FULL_IMAGE_ROW = 0

private let FILM_INFO_SECTION = 1
private let EP_DATE = 0
private let DIRECTOR = 1
private let PRODUCER = 2
private let OPENING_CRAWL = 3

private let CHARACTERS_SECTION = 2
private let PLANETS_SECTION = 3
private let SPECIES_SECTION = 4
private let VEHICLES_SECTION = 6
private let STARSHIPS_SECTION = 5

class FilmTableViewController: UITableViewController, VCWithName {
    var name: String = ""
    var id: String = ""
    var film: Film?
    var fullImageUrl: URL?
    var fullImage: UIImage?
    var scaledImage: UIImage?
    
    var showSection: [Int: Bool] = [FILM_INFO_SECTION: false,
                                    SPECIES_SECTION: false,
                                    VEHICLES_SECTION: false,
                                    STARSHIPS_SECTION: false,
                                    CHARACTERS_SECTION: false,
                                    FULL_IMAGE_SECTION: false,
                                    PLANETS_SECTION: false]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var nib = UINib(nibName: "HeightMassCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HeightMassCell")
        
        nib = UINib(nibName: "GenderBirthyearCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "GenderBirthyearCell")
        
        nib = UINib(nibName: "TextBlockCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TextBlockCell")
        
        nib = UINib(nibName: "BodyColorCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "BodyColorCell")
        
        nib = UINib(nibName: "ImageCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ImageCell")
        
        nib = UINib(nibName: "DoubleTextBoxCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "DoubleTextBoxCell")
        
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.title = name
        
        self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0); //Show the image aligned with bottom of navigation bar
        
        //Fetch the person info
        DataRepo.getFilm(id: id) { film in
            self.film = film
            if film != nil{
                self.showSection[FILM_INFO_SECTION] = true
            }
            self.tableView.reloadData()
        }
        
        DataRepo.getImageUrl(name: name, scaledDown: false) { imageUrl in
            self.fullImageUrl = imageUrl
            
            if let fullImageUrl = imageUrl{
                SDWebImageManager.shared().downloadImage(
                    with: fullImageUrl,
                    options: .avoidAutoSetImage,
                    progress: {recievedSize, expectedSize in }){
                        image, _, _, _, _ in
                        if let image = image{
                            self.fullImage = image //Set the unscaled
                            self.scaledImage = DataUtilities.imageScaledToWidth(image: image, width: self.tableView.frame.size.width)   //Set the scaled
                            self.tableView.reloadData()
                        }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let imageIndexPath = IndexPath(row: FULL_IMAGE_ROW, section: FULL_IMAGE_SECTION)
        scaledImage = DataUtilities.imageScaledToWidth(image: fullImage, width: size.width)
        tableView.reloadRows(at: [imageIndexPath], with: UITableViewRowAnimation.none)
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case FILM_INFO_SECTION:
            return 4
        case STARSHIPS_SECTION:
            if let count = film?.starships.count{
                if(count > 0){
                    showSection[STARSHIPS_SECTION] = true
                }
                return count
            } else{
                return 0
            }
        case PLANETS_SECTION:
            if let count = film?.planets.count{
                if(count > 0){
                    showSection[PLANETS_SECTION] = true
                }
                return count
            } else{
                return 0
            }

        case CHARACTERS_SECTION:
            if let count = film?.characters.count{
                if(count > 0){
                    showSection[CHARACTERS_SECTION] = true
                }
                return count
            } else{
                return 0
            }
        case VEHICLES_SECTION:
            if let count = film?.vehicles.count{
                if(count > 0){
                    showSection[VEHICLES_SECTION] = true
                }
                return count
            } else{
                return 0
            }
        case SPECIES_SECTION:
            if let count = film?.species.count{
                if(count > 0){
                    showSection[SPECIES_SECTION] = true
                }
                return count
            } else{
                return 0
            }
        default:
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        switch(indexPath.section){
        case FULL_IMAGE_SECTION:
            let fiCell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageTableViewCell
            fiCell.fullImage.image = scaledImage
            return fiCell
            
        case FILM_INFO_SECTION:
            if indexPath.row == EP_DATE {
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DoubleTextBoxCell", for: indexPath) as! DoubleTextBoxTableViewCell
                
                if let film = film,
                    let episodeId = film.episodeId,
                    let releaseDate = film.releaseDate{
                    newCell.leftLabel.text = "Episode: \(episodeId)"
                    
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    newCell.rightLabel.text = formatter.string(from: releaseDate)
                }
                return newCell
            }
            else if indexPath.row == DIRECTOR {
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DetailCellFilm", for: indexPath)
                newCell.textLabel?.text = "Director"
                newCell.detailTextLabel?.text = film?.director
                
                return newCell
            }
            else if indexPath.row == PRODUCER {
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DetailCellFilm", for: indexPath)
                if let film = film{
                    newCell.textLabel?.text = film.producers.count > 1 ? "Producers: " : "Producer: "
                }
                newCell.detailTextLabel?.text = film?.producers.joined(separator: ",")
                
                return newCell
            }
            else if indexPath.row == OPENING_CRAWL{
                let newCell = tableView.dequeueReusableCell(withIdentifier: "TextBlockCell", for: indexPath) as! TextBlockTableViewCell
                newCell.blockTextLabel.text = film?.openingCrawl
                return newCell
            }
            else{
                cell = getDefaultCell(indexPath)
            }
        case SPECIES_SECTION:
            if let speciesArray = film?.species{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellFilm", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                let id = speciesArray[indexPath.row]
                DataRepo.getNameForId(id: id, type: .species){ name in
                    cell.textLabel?.text = name
                }
            }
            else{
                cell = getDefaultCell(indexPath)
            }
        case VEHICLES_SECTION:
            if let vehiclesArray = film?.vehicles{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellFilm", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                let id = vehiclesArray[indexPath.row]
                DataRepo.getNameForId(id: id, type: .vehicles){ name in
                    cell.textLabel?.text = name
                }
            }
            else{
                cell = getDefaultCell(indexPath)
            }
        case PLANETS_SECTION:
            if let vehiclesArray = film?.planets{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellFilm", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                let id = vehiclesArray[indexPath.row]
                DataRepo.getNameForId(id: id, type: .planets){ name in
                    cell.textLabel?.text = name
                }
            }
            else{
                cell = getDefaultCell(indexPath)
            }

        case CHARACTERS_SECTION:
            if let filmsArray = film?.characters{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellFilm", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                let id = filmsArray[indexPath.row]
                DataRepo.getNameForId(id: id, type: .people){ name in
                    cell.textLabel?.text = name
                }
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellFilm", for: indexPath)
                cell.textLabel?.text = "Bad cell"
            }
        case STARSHIPS_SECTION:
            if let starshipsArray = film?.starships{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellFilm", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                let id = starshipsArray[indexPath.row]
                DataRepo.getNameForId(id: id, type: .starships){ name in
                    cell.textLabel?.text = name
                }
            }
            else{
                cell = getDefaultCell(indexPath)
            }
            
        default:
            cell = getDefaultCell(indexPath)
        }
        
        return cell

    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !showSection[section]!{
            return nil
        }
        switch section{
        case PLANETS_SECTION:
            return "Planets"
        case FILM_INFO_SECTION:
            return "Film Information"
        case STARSHIPS_SECTION:
            return "Starships"
        case VEHICLES_SECTION:
            return "Vehicles"
        case SPECIES_SECTION:
            return "Species"
        case CHARACTERS_SECTION:
            return "Characters"
        default: return "Bad section title"
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return
            indexPath.section == SPECIES_SECTION ||
            indexPath.section == PLANETS_SECTION ||
            indexPath.section == VEHICLES_SECTION ||
            indexPath.section == STARSHIPS_SECTION ||
            indexPath.section == CHARACTERS_SECTION
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var nextVC: VCWithName
        var id: String?
        var type: EntityType?
        
        switch indexPath.section{
        case PLANETS_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "PlanetDetailView") as! VCWithName
            id = film?.planets[indexPath.row]
            type = .planets
        case VEHICLES_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "VehicleDetailView") as! VCWithName
            id = film?.vehicles[indexPath.row]
            type = .vehicles
        case STARSHIPS_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "StarshipDetailView") as! VCWithName
            id = film?.starships[indexPath.row]
            type = .starships
        case SPECIES_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "SpeciesDetailView") as! VCWithName
            id = film?.species[indexPath.row]
            type = .species
        case CHARACTERS_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "PersonDetailView") as! VCWithName
            id = film?.characters[indexPath.row]
            type = .people
        default:
            return //Don't try to go anywhere
        }
        
        if let id = id, let type = type{
            nextVC.id = id
            DataRepo.getNameForId(id: id, type: type){ name in
                if let name = name{
                    nextVC.name = name
                }
                self.navigationController?.pushViewController(nextVC as! UIViewController, animated: true)
            }
        }
    }
    
    func getDefaultCell(_ indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellFilm", for: indexPath)
        cell.textLabel?.text = "Bad cell"
        return cell
    }
}
