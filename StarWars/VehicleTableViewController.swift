//
//  VehicleTableViewController.swift
//  StarWars
//
//  Created by Ephraim Kunz on 2/11/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import UIKit
private let FULL_IMAGE_SECTION = 0
private let INFO_SECTION = 1

private let MODEL = 0
private let CREW_PASSENGERS = 5
private let COST_LENGTH = 2
private let CARGO_SPEED = 3
private let CONSUMABLES = 4
private let MANUFACTURER = 1

private let PILOT_SECTION = 2
private let FILMS_SECTION = 3

class VehicleTableViewController: UITableViewController, VCWithName {
    var name: String = ""
    var id: String = ""
    var photosCollectionView: UICollectionView?
    var vehicle: Vehicle?
    var fullImageUrl: URL?
    
    var showSection: [Int: Bool] = [INFO_SECTION: false,
                                    PILOT_SECTION: false,
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
        
        //Fetch the person info
        DataRepo.getVehicle(id: id) { vehicle in
            self.vehicle = vehicle
            if vehicle != nil{
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
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case FULL_IMAGE_SECTION:
            return 1
        case INFO_SECTION:
            return 6
        case FILMS_SECTION:
            if let count = vehicle?.films.count{
                if(count > 0){
                    showSection[FILMS_SECTION] = true
                }
                return count
            } else{
                return 0
            }
        case PILOT_SECTION:
            if let count = vehicle?.pilots.count{
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
        case FULL_IMAGE_SECTION:
            let fiCell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageTableViewCell
            if let fullImageUrl = fullImageUrl{
                fiCell.fullImage.sd_setImage(with: fullImageUrl, placeholderImage: UIImage(named: "GenericImagePlaceholder"))
            }
            
            return fiCell
            
        case INFO_SECTION:
            if indexPath.row == MODEL {
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DetailCellVehicle", for: indexPath)
                newCell.textLabel?.text = "Model"
                newCell.detailTextLabel?.text = vehicle?.model
                return newCell
            }
            else if indexPath.row == CREW_PASSENGERS {
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DoubleTextBoxCell", for: indexPath) as! DoubleTextBoxTableViewCell
                if let crew = vehicle?.crew,
                    let passengers = vehicle?.passengers{
                    newCell.leftLabel.text = "Crew: \(crew)"
                    newCell.rightLabel.text = "Passengers: \(passengers)"
                }
                return newCell
            }
            else if indexPath.row == COST_LENGTH{
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DoubleTextBoxCell", for: indexPath) as! DoubleTextBoxTableViewCell
                if let cost = vehicle?.cost,
                    let length = vehicle?.length{
                    newCell.leftLabel.text = "Cost: \(cost)" + (cost == "unknown" ? "" : " (credits)")
                    newCell.rightLabel.text = "Length: \(length) (m)"
                }
                return newCell
            }
            else if indexPath.row == CARGO_SPEED{
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DoubleTextBoxCell", for: indexPath) as! DoubleTextBoxTableViewCell
                if let cargo = vehicle?.cargoCapacity,
                    let speed = vehicle?.speed{
                    newCell.leftLabel.text = "Cargo cap: \(cargo)" + (cargo == "unknown" ? "" : " (kg)")
                    newCell.rightLabel.text = "Speed: \(speed)"
                }
                return newCell
            }
            else if indexPath.row == CONSUMABLES{
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DetailCellVehicle", for: indexPath)
                newCell.textLabel?.text = "Consumables"
                newCell.detailTextLabel?.text = vehicle?.consumables
                return newCell
            }
            else if indexPath.row == MANUFACTURER{
                let newCell = tableView.dequeueReusableCell(withIdentifier: "DetailCellVehicle", for: indexPath)
                newCell.textLabel?.text = "Manufacturer"
                newCell.detailTextLabel?.text = vehicle?.manufacturer
                return newCell
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellVehicle", for: indexPath)
                cell.textLabel?.text = "Bad cell"
            }
        case FILMS_SECTION:
            if let filmsArray = vehicle?.films{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellVehicle", for: indexPath)
                let id = filmsArray[indexPath.row]
                DataRepo.getNameForId(id: id, type: .films){ name in
                    cell.textLabel?.text = name
                }
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellVehicle", for: indexPath)
                cell.textLabel?.text = "Bad cell"
            }
        case PILOT_SECTION:
            if let pilotArray = vehicle?.pilots{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellVehicle", for: indexPath)
                let id = pilotArray[indexPath.row]
                DataRepo.getNameForId(id: id, type: .people){ name in
                    cell.textLabel?.text = name
                }
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellVehicle", for: indexPath)
                cell.textLabel?.text = "Bad cell"
            }
            
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "BasicCellVehicle", for: indexPath)
            cell.textLabel?.text = "Bad cell"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !showSection[section]!{
            return nil
        }
        switch section{
        case INFO_SECTION:
            return "Vehicle Information"
        case PILOT_SECTION:
            return "Pilots"
        case FILMS_SECTION:
            return "Films"
        default: return "Bad section title"
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
            id = vehicle?.pilots[indexPath.row]
            type = .people
        case FILMS_SECTION:
            nextVC = storyboard?.instantiateViewController(withIdentifier: "FilmDetailView") as! VCWithName
            id = vehicle?.films[indexPath.row]
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
