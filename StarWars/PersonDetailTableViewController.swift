//
//  PersonDetailTableViewController.swift
//  StarWars
//
//  Created by Ephraim Kunz on 2/2/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import UIKit
import IDMPhotoBrowser

private var images: [URL] = []

private let FULL_IMAGE_SECTION = 0
private let PHOTOS_SECTION = 6
private let VITALS_SECTION = 1

private let HEIGHTMASS = 0
private let GENDER_BIRTH = 1
private let BODY_COLOR_ROW = 2
private let HOMEWORLD_ROW = 3
private let MORE_INFO = 4

private let SPECIES_SECTION = 2
private let VEHICLES_SECTION = 5
private let FILMS_SECTION = 3
private let STARSHIPS_SECTION = 4

class PersonDetailTableViewController: UITableViewController, VCWithName {
    var name: String = ""
    var id: String = ""
    var photosCollectionView: UICollectionView?
    var person: Person?
    var fullImageUrl: URL?
    
    var showSection: [Int: Bool] = [PHOTOS_SECTION: false,
                                    VITALS_SECTION: false,
                                    SPECIES_SECTION: false,
                                    VEHICLES_SECTION: false,
                                    STARSHIPS_SECTION: false,
                                    FILMS_SECTION: false,
                                    FULL_IMAGE_SECTION: false]

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
        DataRepo.getPerson(id: id) { person in
            self.person = person
            if person != nil{
                self.showSection[VITALS_SECTION] = true
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
        return 7
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case PHOTOS_SECTION:
            return 1
        case VITALS_SECTION:
            return 5
        case STARSHIPS_SECTION:
            if let count = person?.starships.count{
                if(count > 0){
                    showSection[STARSHIPS_SECTION] = true
                }
                return count
            } else{
                return 0
            }
        case FILMS_SECTION:
            if let count = person?.films.count{
                if(count > 0){
                    showSection[FILMS_SECTION] = true
                }
                return count
            } else{
                return 0
            }
        case VEHICLES_SECTION:
            if let count = person?.vehicles.count{
                if(count > 0){
                    showSection[VEHICLES_SECTION] = true
                }
                return count
            } else{
                return 0
            }
        case SPECIES_SECTION:
            if let count = person?.species.count{
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

        case VITALS_SECTION:
            if indexPath.row == HEIGHTMASS {
                let hmCell = tableView.dequeueReusableCell(withIdentifier: "HeightMassCell", for: indexPath) as! HeightMassTableViewCell
                
                if let mass = person?.mass,
                let height = person?.height{
                    hmCell.massLabel.text = mass + " (kg)"
                    hmCell.heightLabel.text = height + " (cm)"
                }
                return hmCell
            }
            else if indexPath.row == GENDER_BIRTH {
                let gbCell = tableView.dequeueReusableCell(withIdentifier: "GenderBirthyearCell", for: indexPath) as! GenderBirthyearTableViewCell
                
                gbCell.birthyearLabel.text = person?.birthYear
                gbCell.genderLabel.text = person?.gender
                
                //Pick the correct image
                if person?.gender == "male"{
                    gbCell.genderImageView.image = UIImage(named: "MaleIcon")
                }
                else if person?.gender == "female"{
                    gbCell.genderImageView.image = UIImage(named: "FemaleIcon")
                }
                else{
                    gbCell.genderImageView.image = UIImage(named: "UnknownGenderIcon")
                }
                
                return gbCell
            }
            else if indexPath.row == BODY_COLOR_ROW{
                let bcCell = tableView.dequeueReusableCell(withIdentifier: "BodyColorCell", for: indexPath) as! BodyColorTableViewCell
                bcCell.eyecolorLabel.text = person?.eyeColor
                bcCell.skincolorLabel.text = person?.skinColor
                bcCell.haircolorLabel.text = person?.hairColor
                
                return bcCell
            }
            else if indexPath.row == MORE_INFO{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "More Information"
            }
            else if indexPath.row == HOMEWORLD_ROW{
                cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath)
                cell.textLabel?.text = "Homeworld"
                cell.accessoryType = .disclosureIndicator
                
               if let person = person,
                let homeworld = person.homeworld{
                    DataRepo.getNameForId(id: homeworld, type: .planets) { name in
                        cell.detailTextLabel?.text = name
                    }
                }
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
                cell.textLabel?.text = "Bad cell"
            }
        case SPECIES_SECTION:
            if let speciesArray = person?.species{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                let id = speciesArray[indexPath.row]
                DataRepo.getNameForId(id: id, type: .species){ name in
                    cell.textLabel?.text = name
                }
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
                cell.textLabel?.text = "Bad cell"
            }
        case VEHICLES_SECTION:
            if let vehiclesArray = person?.vehicles{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                let id = vehiclesArray[indexPath.row]
                DataRepo.getNameForId(id: id, type: .vehicles){ name in
                    cell.textLabel?.text = name
                }
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
                cell.textLabel?.text = "Bad cell"
            }
        case FILMS_SECTION:
            if let filmsArray = person?.films{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                let id = filmsArray[indexPath.row]
                DataRepo.getNameForId(id: id, type: .films){ name in
                    cell.textLabel?.text = name
                }
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
                cell.textLabel?.text = "Bad cell"
            }
        case STARSHIPS_SECTION:
            if let starshipsArray = person?.starships{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                let id = starshipsArray[indexPath.row]
                DataRepo.getNameForId(id: id, type: .starships){ name in
                    cell.textLabel?.text = name
                }
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
                cell.textLabel?.text = "Bad cell"
            }
            
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
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
        case VITALS_SECTION:
            return "Vital Statistics"
        case STARSHIPS_SECTION:
            return "Starships"
        case VEHICLES_SECTION:
            return "Vehicles"
        case SPECIES_SECTION:
            return "Species"
        case FILMS_SECTION:
            return "Films"
        default: return "Bad section title"
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.section == VITALS_SECTION && (indexPath.row == HOMEWORLD_ROW || indexPath.row == MORE_INFO)) ||
            indexPath.section == SPECIES_SECTION ||
            indexPath.section == FILMS_SECTION ||
            indexPath.section == VEHICLES_SECTION ||
            indexPath.section == STARSHIPS_SECTION
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var nextVC: VCWithName
        var id: String?
        var type: EntityType?
        
        switch indexPath.section{
        case VITALS_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "PlanetDetailView") as! VCWithName
            id = person?.homeworld
            type = .planets
        case VEHICLES_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "VehicleDetailView") as! VCWithName
            id = person?.vehicles[indexPath.row]
            type = .vehicles
        case STARSHIPS_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "StarshipDetailView") as! VCWithName
            id = person?.starships[indexPath.row]
            type = .starships
        case SPECIES_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "SpeciesDetailView") as! VCWithName
            id = person?.species[indexPath.row]
            type = .species
        case FILMS_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "FilmDetailView") as! VCWithName
            id = person?.films[indexPath.row]
            type = .films
        default:
            return //Don't try to go anywhere
        }
        
        if indexPath.section == VITALS_SECTION && indexPath.row == MORE_INFO{
            if let name = person?.getName(),
            let url = DataRepo.getInfoUrl(name: name){
                UIApplication.shared.openURL(url)
            }
        }
        
        else{
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
    }
}

extension PersonDetailTableViewController: UICollectionViewDataSource, UICollectionViewDelegate{
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
