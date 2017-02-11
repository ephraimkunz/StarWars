//
//  PersonDetailTableViewController.swift
//  StarWars
//
//  Created by Ephraim Kunz on 2/2/17.
//  Copyright © 2017 Ephraim Kunz. All rights reserved.
//

import UIKit
import IDMPhotoBrowser

var images: [URL] = []

private let PHOTOS_SECTION = 6
private let TITLEROW = 0
private let VITALS_SECTION = 0
private let HEIGHTMASS = 1
private let GENDER_BIRTH = 2
private let BODY_COLOR_ROW = 3
private let HOMEWORLD_SECTION = 1
private let SPECIES_SECTION = 2
private let VEHICLES_SECTION = 3
private let FILMS_SECTION = 4
private let STARSHIPS_SECTION = 5


class PersonDetailTableViewController: UITableViewController {
    var name: String = ""
    var id: String = ""
    var photosCollectionView: UICollectionView?
    var person: Person?

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
        
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.title = name
        
        //Start the image fetch
        DataRepo.getImageUrls(name: name){ items in
            images = items
            self.photosCollectionView?.reloadData()
        }
        
        //Fetch the person info
        DataRepo.getPerson(id: id) { person in
            self.person = person
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case PHOTOS_SECTION:
            return 2
        case VITALS_SECTION:
            return 4
        default:
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        switch(indexPath.section){
        case PHOTOS_SECTION:
            if(indexPath.row == TITLEROW) {
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
                cell.textLabel?.text = "Images"
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier: "ScrollablePhotosCell", for: indexPath)
            }

        case VITALS_SECTION:
            if(indexPath.row == TITLEROW){
                cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
                cell.textLabel?.text = "Vital Statistics"
            }
            else if indexPath.row == HEIGHTMASS {
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
        if indexPath.section == PHOTOS_SECTION && indexPath.row != TITLEROW {
            guard let scrollableCell = cell as? ScrollablePhotosTableViewCell else{ return}
            scrollableCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
            photosCollectionView = scrollableCell.getCollectionViewReference()
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
