//
//  PlanetTableViewController.swift
//  StarWars
//
//  Created by Ephraim Kunz on 2/11/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import UIKit
import IDMPhotoBrowser

private var images: [URL] = []

private let FULL_IMAGE_SECTION = 0
private let PHOTOS_SECTION = 4
private let INFO_SECTION = 1

private let ROTATION_ORBITAL = 0
private let DIAMETER_CLIMATE = 1
private let GRAVITY_WATER = 2
private let POPULATION = 3
private let TERRAIN = 4

private let RESIDENTS_SECTION = 2
private let FILMS_SECTION = 3


class PlanetTableViewController: UITableViewController, VCWithName {
    var name: String = ""
    var id: String = ""
    var photosCollectionView: UICollectionView?
    var planet: Planet?
    var fullImageUrl: URL?
    
    var showSection: [Int: Bool] = [PHOTOS_SECTION: false,
                                    INFO_SECTION: false,
                                    RESIDENTS_SECTION: false,
                                    FILMS_SECTION: false,
                                    FULL_IMAGE_SECTION: false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var nib = UINib(nibName: "ScrollablePhotosCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ScrollablePhotosCell")
        
        nib = UINib(nibName: "HeightMassCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HeightMassCell")
        
        nib = UINib(nibName: "DoubleTextBoxCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "DoubleTextBoxCell")
        
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
        DataRepo.getPlanet(id: id) { planet in
            self.planet = planet
            if planet != nil{
                self.showSection[INFO_SECTION] = true
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
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case FULL_IMAGE_SECTION: fallthrough
        case PHOTOS_SECTION:
            return 1
        case INFO_SECTION:
            return 5
        case FILMS_SECTION:
            if let count = planet?.films.count{
                if(count > 0){
                    showSection[FILMS_SECTION] = true
                }
                return count
            } else{
                return 0
            }
        case RESIDENTS_SECTION:
            if let count = planet?.residents.count{
                if(count > 0){
                    showSection[RESIDENTS_SECTION] = true
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
            
        case INFO_SECTION:
            if indexPath.row == ROTATION_ORBITAL {
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DoubleTextBoxCell", for: indexPath) as! DoubleTextBoxTableViewCell
                
                if let rotation = planet?.rotationPeriod,
                    let orbital = planet?.orbitalPeriod{
                    newCell.leftLabel.text = "Rotation: \(rotation)" + (rotation == "unknown" ? "" : " (km)")
                    newCell.rightLabel.text = "Orbit: \(orbital)" + (orbital == "unknown" ? "" : " (km)")
                }
                return newCell
            }
            else if indexPath.row == DIAMETER_CLIMATE {
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DoubleTextBoxCell", for: indexPath) as! DoubleTextBoxTableViewCell
                
                if let diameter = planet?.diameter,
                    let climate = planet?.climate{
                    newCell.leftLabel.text = "Diameter: \(diameter)" + (diameter == "unknown" ? "" : " (km)")
                    newCell.rightLabel.text = "Climate: \(climate)"
                }
                return newCell
            }
            else if indexPath.row == GRAVITY_WATER{
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DoubleTextBoxCell", for: indexPath) as! DoubleTextBoxTableViewCell
                
                if let gravity = planet?.gravity,
                    let water = planet?.surfaceWater{
                    newCell.leftLabel.text = "Gravity: \(gravity)"
                    newCell.rightLabel.text = "Water: \(water)%"
                }
                return newCell            }
            else if indexPath.row == POPULATION{
                cell = tableView.dequeueReusableCell(withIdentifier: "DetailCellPlanet", for: indexPath)
                cell.textLabel?.text = "Population"
                
                cell.detailTextLabel?.text = planet?.population
            }
            else if indexPath.row == TERRAIN{
                cell = tableView.dequeueReusableCell(withIdentifier: "DetailCellPlanet", for: indexPath)
                cell.textLabel?.text = "Terrain"
                
                cell.detailTextLabel?.text = planet?.terrains.joined(separator: ",")
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellPlanet", for: indexPath)
                cell.textLabel?.text = "Bad cell"
            }
        case FILMS_SECTION:
            if let filmsArray = planet?.films{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellPlanet", for: indexPath)
                let id = filmsArray[indexPath.row]
                DataRepo.getNameForId(id: id, type: .films){ name in
                    cell.textLabel?.text = name
                }
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellPlanet", for: indexPath)
                cell.textLabel?.text = "Bad cell"
            }
        case RESIDENTS_SECTION:
            if let residentsArray = planet?.residents{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellPlanet", for: indexPath)
                let id = residentsArray[indexPath.row]
                DataRepo.getNameForId(id: id, type: .people){ name in
                    cell.textLabel?.text = name
                }
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellPlanet", for: indexPath)
                cell.textLabel?.text = "Bad cell"
            }
            
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellPlanet", for: indexPath)
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
        case INFO_SECTION:
            return "Planet Information"
        case RESIDENTS_SECTION:
            return "Residents"
        case FILMS_SECTION:
            return "Films"
        default: return "Bad section title"
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return
            indexPath.section == RESIDENTS_SECTION ||
            indexPath.section == FILMS_SECTION
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var nextVC: VCWithName
        var id: String?
        var type: EntityType?
        
        switch indexPath.section{
        case RESIDENTS_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "PersonDetailView") as! VCWithName
            id = planet?.residents[indexPath.row]
            type = .people
        case FILMS_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "FilmDetailView") as! VCWithName
            id = planet?.films[indexPath.row]
            type = .films
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
}

extension PlanetTableViewController: UICollectionViewDataSource, UICollectionViewDelegate{
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
