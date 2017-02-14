//
//  FilmTableViewController.swift
//  StarWars
//
//  Created by Ephraim Kunz on 2/11/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import UIKit
import IDMPhotoBrowser

private var images: [URL] = []

private let FULL_IMAGE_SECTION = 0
private let PHOTOS_SECTION = 7

private let FILM_INFO_SECTION = 1
private let EP_DATE = 0
private let DIRECTOR_PRODUCER = 1
private let OPENING_CRAWL = 2

private let CHARACTERS_SECTION = 2
private let PLANETS_SECTION = 3
private let SPECIES_SECTION = 4
private let VEHICLES_SECTION = 6
private let STARSHIPS_SECTION = 5

class FilmTableViewController: UITableViewController, VCWithName {
    var name: String = ""
    var id: String = ""
    var photosCollectionView: UICollectionView?
    var film: Film?
    var fullImageUrl: URL?
    
    var showSection: [Int: Bool] = [PHOTOS_SECTION: false,
                                    FILM_INFO_SECTION: false,
                                    SPECIES_SECTION: false,
                                    VEHICLES_SECTION: false,
                                    STARSHIPS_SECTION: false,
                                    CHARACTERS_SECTION: false,
                                    FULL_IMAGE_SECTION: false,
                                    PLANETS_SECTION: false]

    override func viewDidLoad() {
        super.viewDidLoad()

        var nib = UINib(nibName: "ScrollablePhotosCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ScrollablePhotosCell")
        
        nib = UINib(nibName: "HeightMassCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HeightMassCell")
        
        nib = UINib(nibName: "GenderBirthyearCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "GenderBirthyearCell")
        
        nib = UINib(nibName: "BodyColorCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "BodyColorCell")
        
        nib = UINib(nibName: "ImageCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ImageCell")
        
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.title = name
        
        self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0); //Show the image aligned with bottom of navigation bar
        
        
        //Start the image fetch
        DataRepo.getImageUrls(name: name){ items in
            images = items
            if items.count > 0{
                self.showSection[PHOTOS_SECTION] = true
            }
            self.photosCollectionView?.reloadData()
        }
        
        //Fetch the person info
        DataRepo.getFilm(id: id) { film in
            self.film = film
            if film != nil{
                self.showSection[FILM_INFO_SECTION] = true
            }
            self.tableView.reloadData()
        }
        
        DataRepo.getImageUrl(name: name, scaledDown: true) { imageUrl in
            self.fullImageUrl = imageUrl
            self.tableView.reloadData()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case PHOTOS_SECTION:
            return 1
        case FILM_INFO_SECTION:
            return 3
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
                    showSection[STARSHIPS_SECTION] = true
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
            if let fullImageUrl = fullImageUrl{
                fiCell.fullImage.sd_setImage(with: fullImageUrl, placeholderImage: UIImage(named: "GenericImagePLaceholder"))
            }
            
            return fiCell
        case PHOTOS_SECTION:
            cell = tableView.dequeueReusableCell(withIdentifier: "ScrollablePhotosCell", for: indexPath)
            
        case FILM_INFO_SECTION:
            if indexPath.row == EP_DATE {
                let hmCell = tableView.dequeueReusableCell(withIdentifier: "HeightMassCell", for: indexPath) as! HeightMassTableViewCell
                
                return hmCell
            }
            else if indexPath.row == DIRECTOR_PRODUCER {
                let gbCell = tableView.dequeueReusableCell(withIdentifier: "GenderBirthyearCell", for: indexPath) as! GenderBirthyearTableViewCell
                
                gbCell.birthyearLabel.text = nil
                gbCell.genderLabel.text = nil
                
                
                gbCell.genderImageView.image = UIImage(named: "UnknownGenderIcon")
            
                
                return gbCell
            }
            else if indexPath.row == OPENING_CRAWL{
                let bcCell = tableView.dequeueReusableCell(withIdentifier: "BodyColorCell", for: indexPath) as! BodyColorTableViewCell
                bcCell.eyecolorLabel.text = nil
                bcCell.skincolorLabel.text = nil
                bcCell.haircolorLabel.text = nil
                
                return bcCell
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellFilm", for: indexPath)
                cell.textLabel?.text = "Bad cell"
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
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellFilm", for: indexPath)
                cell.textLabel?.text = "Bad cell"
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
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellFilm", for: indexPath)
                cell.textLabel?.text = "Bad cell"
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
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellFilm", for: indexPath)
                cell.textLabel?.text = "Bad cell"
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
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellFilm", for: indexPath)
                cell.textLabel?.text = "Bad cell"
            }
            
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellFilm", for: indexPath)
            cell.textLabel?.text = "Bad cell"
        }
        
        return cell

    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == PHOTOS_SECTION {
            guard let scrollableCell = cell as? ScrollablePhotosTableViewCell else{ return}
            scrollableCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
            photosCollectionView = scrollableCell.getCollectionViewReference()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !showSection[section]!{
            return nil
        }
        switch section{
        case PHOTOS_SECTION:
            return "Images"
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
        
        switch indexPath.section{
        case VEHICLES_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "VehicleDetailView") as! VCWithName
            id = film?.vehicles[indexPath.row]
        case STARSHIPS_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "StarshipDetailView") as! VCWithName
            id = film?.starships[indexPath.row]
        case SPECIES_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "SpeciesDetailView") as! VCWithName
            id = film?.species[indexPath.row]
        case CHARACTERS_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "PersonDetailView") as! VCWithName
            id = film?.characters[indexPath.row]
        case PLANETS_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "PlanetDetailView") as! VCWithName
            id = film?.planets[indexPath.row]
        default:
            return //Don't try to go anywhere
        }
        
        if let film = film,
            let id = id{
            nextVC.name = film.getName()
            nextVC.id = id
            navigationController?.pushViewController(nextVC as! UIViewController, animated: true)
            
        }
    }
}

extension FilmTableViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        cell.image.sd_setImage(with: images[indexPath.row], placeholderImage: UIImage(named: "GenericImagePlaceholder"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let browser = IDMPhotoBrowser(photoURLs: images.rotate(shift: indexPath.row))!
        self.present(browser, animated: true, completion: nil)
    }
}

