//
//  SpeciesTableViewController.swift
//  StarWars
//
//  Created by Ephraim Kunz on 2/11/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import UIKit
import IDMPhotoBrowser

private var images: [URL] = []

private let FULL_IMAGE_SECTION = 0
private let FULL_IMAGE_ROW = 0
private let PHOTOS_SECTION = 4
private let INFO_SECTION = 1

private let CLASSIFICATION_DESIGNATION = 0
private let HEIGHT = 1
private let HAIR = 2
private let EYES = 3
private let SKIN = 4
private let LANGUAGE_LIFESPAN = 5
private let HOMEWORLD = 6

private let PEOPLE_SECTION = 2
private let FILMS_SECTION = 3

class SpeciesTableViewController: UITableViewController, VCWithName{
    var name: String = ""
    var id: String = ""
    var photosCollectionView: UICollectionView?
    var species: Species?
    var fullImageUrl: URL?
    var fullImage: UIImage?
    var scaledImage: UIImage?
    
    var showSection: [Int: Bool] = [PHOTOS_SECTION: false,
                                    INFO_SECTION: false,
                                    PEOPLE_SECTION: false,
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
        DataRepo.getSpecies(id: id) { species in
            self.species = species
            if species != nil{
                self.showSection[INFO_SECTION] = true
            }
            self.tableView.reloadData()
        }
        
        DataRepo.getImageUrl(name: name, scaledDown: false) { imageUrl in
            self.fullImageUrl = imageUrl
            
            if let fullImageUrl = imageUrl{
                SDWebImageManager.shared().loadImage(
                    with: fullImageUrl,
                    options: .avoidAutoSetImage,
                    progress: nil){
                        image, _, _, _, _, _ in
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
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case FULL_IMAGE_SECTION: fallthrough
        case PHOTOS_SECTION:
            return 1
        case INFO_SECTION:
            return 7
        case FILMS_SECTION:
            if let count = species?.films.count{
                if(count > 0){
                    showSection[FILMS_SECTION] = true
                }
                return count
            } else{
                return 0
            }
        case PEOPLE_SECTION:
            if let count = species?.people.count{
                if(count > 0){
                    showSection[PEOPLE_SECTION] = true
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
        case PHOTOS_SECTION:
            cell = tableView.dequeueReusableCell(withIdentifier: "ScrollablePhotosCell", for: indexPath)
            
        case INFO_SECTION:
            if indexPath.row == CLASSIFICATION_DESIGNATION {
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DetailCellSpecies", for: indexPath)
                
                if let classification = species?.classification,
                    let designation = species?.designation {
                    newCell.textLabel?.text = "Classification"
                    newCell.detailTextLabel?.text = designation.capitalized + " " + classification
                }
                return newCell
            }
            else if indexPath.row == HEIGHT {
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DetailCellSpecies", for: indexPath)
                newCell.textLabel?.text = "Height"
                if let height = species?.averageHeight{
                    newCell.detailTextLabel?.text = height + (height == "unknown" ? "" : " (cm)")
                }
                return newCell
            }
            else if indexPath.row == HAIR{
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DetailCellSpecies", for: indexPath)
                if let species = species{
                    newCell.textLabel?.text = "Hair color" + (species.hairColors.count > 1 ? "s" : "")
                    newCell.detailTextLabel?.text = species.hairColors.joined(separator: ",")
                }
                
                return newCell
            }
            else if indexPath.row == EYES{
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DetailCellSpecies", for: indexPath)
                if let species = species{
                    newCell.textLabel?.text = "Eye color" + (species.hairColors.count > 1 ? "s" : "")
                    newCell.detailTextLabel?.text = species.eyeColors.joined(separator: ",")
                }
                
                return newCell
            }
            else if indexPath.row == SKIN{
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DetailCellSpecies", for: indexPath)
                if let species = species{
                    newCell.textLabel?.text = "Skin color" + (species.hairColors.count > 1 ? "s" : "")
                    newCell.detailTextLabel?.text = species.skinColors.joined(separator: ",")
                }
                
                return newCell
            }
            else if indexPath.row == LANGUAGE_LIFESPAN{
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DoubleTextBoxCell", for: indexPath) as! DoubleTextBoxTableViewCell
                if let language = species?.language,
                    let lifespan = species?.averageLifespan{
                    newCell.leftLabel.text = "Lang: \(language.capitalized)"
                    newCell.rightLabel.text = "Lifespan: \(lifespan)" + (lifespan == "unknown" ? "" : " (yrs)")
                }
                
                return newCell
            }
            else if indexPath.row == HOMEWORLD{
                cell = tableView.dequeueReusableCell(withIdentifier: "DetailCellSpecies", for: indexPath)
                if let homeworld = species?.homeworld{
                    DataRepo.getNameForId(id: homeworld, type: .planets){ name in
                        cell.textLabel?.text = "Homeworld"
                        cell.detailTextLabel?.text = name
                        cell.accessoryType = .disclosureIndicator
                    }
                }
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellSpecies", for: indexPath)
                cell.textLabel?.text = "Bad cell"
            }
        case FILMS_SECTION:
            if let filmsArray = species?.films{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellSpecies", for: indexPath)
                let id = filmsArray[indexPath.row]
                DataRepo.getNameForId(id: id, type: .films){ name in
                    cell.textLabel?.text = name
                }
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellSpecies", for: indexPath)
                cell.textLabel?.text = "Bad cell"
            }
        case PEOPLE_SECTION:
            if let peopleArray = species?.people{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellSpecies", for: indexPath)
                let id = peopleArray[indexPath.row]
                DataRepo.getNameForId(id: id, type: .people){ name in
                    cell.textLabel?.text = name
                }
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellSpecies", for: indexPath)
                cell.textLabel?.text = "Bad cell"
            }
            
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellSpecies", for: indexPath)
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
            return "Species Information"
        case PEOPLE_SECTION:
            return "People"
        case FILMS_SECTION:
            return "Films"
        default: return "Bad section title"
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return
            (indexPath.section == INFO_SECTION && indexPath.row == HOMEWORLD) ||
            indexPath.section == PEOPLE_SECTION ||
            indexPath.section == FILMS_SECTION
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var nextVC: VCWithName
        var id: String?
        var type: EntityType?
        
        switch indexPath.section{
        case INFO_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "PlanetDetailView") as! VCWithName
            id = species?.homeworld
            type = .planets

        case PEOPLE_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "PersonDetailView") as! VCWithName
            id = species?.people[indexPath.row]
            type = .people
        case FILMS_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "FilmDetailView") as! VCWithName
            id = species?.films[indexPath.row]
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

extension SpeciesTableViewController: UICollectionViewDataSource, UICollectionViewDelegate{
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
