//
//  StarshipTableViewController.swift
//  StarWars
//
//  Created by Ephraim Kunz on 2/11/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import UIKit
import IDMPhotoBrowser

private var images: [URL] = []

private let IMAGES = 4
private let FULL_IMAGE_SECTION = 0
private let FULL_IMAGE_ROW = 0
private let INFO_SECTION = 1

private let MODEL = 0
private let CREW_PASSENGERS = 6
private let HYPERDRIVE_MGLT = 4
private let COST_LENGTH = 2
private let CARGO_SPEED = 3
private let CONSUMABLES = 5
private let MANUFACTURER = 1

private let PILOT_SECTION = 2
private let FILMS_SECTION = 3

class StarshipTableViewController: UITableViewController, VCWithName {
    var name: String = ""
    var id: String = ""
    var photosCollectionView: UICollectionView?
    var starship: Starship?
    var fullImageUrl: URL?
    var fullImage: UIImage?
    var scaledImage: UIImage?
    
    var showSection: [Int: Bool] = [INFO_SECTION: false,
                                    PILOT_SECTION: false,
                                    IMAGES: false,
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
                self.showSection[IMAGES] = true
            }
            self.photosCollectionView?.reloadData()
        }
        
        //Fetch the person info
        DataRepo.getStarship(id: id) { starship in
            self.starship = starship
            if starship != nil{
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
        case IMAGES: fallthrough
        case FULL_IMAGE_SECTION:
            return 1
        case INFO_SECTION:
            return 7
        case FILMS_SECTION:
            if let count = starship?.films.count{
                if(count > 0){
                    showSection[FILMS_SECTION] = true
                }
                return count
            } else{
                return 0
            }
        case PILOT_SECTION:
            if let count = starship?.pilots.count{
                if(count > 0){
                    showSection[PILOT_SECTION] = true
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
        case IMAGES:
            cell = tableView.dequeueReusableCell(withIdentifier: "ScrollablePhotosCell", for: indexPath)
        case FULL_IMAGE_SECTION:
            let fiCell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageTableViewCell
            fiCell.fullImage.image = scaledImage
            
            return fiCell
            
        case INFO_SECTION:
            if indexPath.row == MODEL {
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DetailCellStarship", for: indexPath)
                newCell.textLabel?.text = "Model"
                newCell.detailTextLabel?.text = starship?.model
                return newCell
            }
            else if indexPath.row == CREW_PASSENGERS {
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DoubleTextBoxCell", for: indexPath) as! DoubleTextBoxTableViewCell
                if let crew = starship?.crew,
                    let passengers = starship?.passengers{
                    newCell.leftLabel.text = "Crew: \(crew)"
                    newCell.rightLabel.text = "Passengers: \(passengers)"
                }
                return newCell
            }
            else if indexPath.row == COST_LENGTH{
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DoubleTextBoxCell", for: indexPath) as! DoubleTextBoxTableViewCell
                if let cost = starship?.cost,
                    let length = starship?.length{
                    newCell.leftLabel.text = "Cost: \(cost)" + (cost == "unknown" ? "" : " (credits)")
                    newCell.rightLabel.text = "Length: \(length) (m)"
                }
                return newCell
            }
            else if indexPath.row == HYPERDRIVE_MGLT{
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DoubleTextBoxCell", for: indexPath) as! DoubleTextBoxTableViewCell
                if let hyperdrive = starship?.hyperdrive,
                    let mglt = starship?.MGLT{
                    newCell.leftLabel.text = "Hyperdrive: \(hyperdrive)"
                    newCell.rightLabel.text = "MGLT: \(mglt)"
                }
                return newCell
            }
            else if indexPath.row == CARGO_SPEED{
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DoubleTextBoxCell", for: indexPath) as! DoubleTextBoxTableViewCell
                if let cargo = starship?.cargoCapacity,
                    let speed = starship?.speed{
                    newCell.leftLabel.text = "Cargo cap: \(cargo)" + (cargo == "unknown" ? "" : " (kg)")
                    newCell.rightLabel.text = "Speed: \(speed)"
                }
                return newCell
            }
            else if indexPath.row == CONSUMABLES{
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DetailCellStarship", for: indexPath)
                newCell.textLabel?.text = "Consumables"
                newCell.detailTextLabel?.text = starship?.consumables
                return newCell
            }
            else if indexPath.row == MANUFACTURER{
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DetailCellStarship", for: indexPath)
                newCell.textLabel?.text = "Manufacturer"
                newCell.detailTextLabel?.text = starship?.manufacturer
                return newCell
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellStarship", for: indexPath)
                cell.textLabel?.text = "Bad cell"
            }
        case FILMS_SECTION:
            if let filmsArray = starship?.films{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellStarship", for: indexPath)
                let id = filmsArray[indexPath.row]
                DataRepo.getNameForId(id: id, type: .films){ name in
                    cell.textLabel?.text = name
                }
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellStarship", for: indexPath)
                cell.textLabel?.text = "Bad cell"
            }
        case PILOT_SECTION:
            if let pilotArray = starship?.pilots{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellStarship", for: indexPath)
                let id = pilotArray[indexPath.row]
                DataRepo.getNameForId(id: id, type: .people){ name in
                    cell.textLabel?.text = name
                }
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellStarship", for: indexPath)
                cell.textLabel?.text = "Bad cell"
            }
            
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellStarship", for: indexPath)
            cell.textLabel?.text = "Bad cell"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !showSection[section]!{
            return nil
        }
        switch section{
        case IMAGES:
            return "Images"
        case INFO_SECTION:
            return "Starship Information"
        case PILOT_SECTION:
            return "Pilots"
        case FILMS_SECTION:
            return "Films"
        default: return "Bad section title"
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == IMAGES {
            guard let scrollableCell = cell as? ScrollablePhotosTableViewCell else{ return}
            scrollableCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
            photosCollectionView = scrollableCell.getCollectionViewReference()
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return
            indexPath.section == PILOT_SECTION ||
                indexPath.section == FILMS_SECTION
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var nextVC: VCWithName
        var id: String?
        var type: EntityType?
        
        switch indexPath.section{
        case PILOT_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "PersonDetailView") as! VCWithName
            id = starship?.pilots[indexPath.row]
            type = .people
        case FILMS_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "FilmDetailView") as! VCWithName
            id = starship?.films[indexPath.row]
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

extension StarshipTableViewController: UICollectionViewDataSource, UICollectionViewDelegate{
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
