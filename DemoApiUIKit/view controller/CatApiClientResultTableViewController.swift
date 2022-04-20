//
//  CatApiClientResultTableViewController.swift
//  DemoApiUIKit
//
//  Created by Peter Pan on 2022/4/18.
//

import UIKit
import Nuke

class CatApiClientResultTableViewController: UITableViewController {
    
    var favorites = [Favorite]()

    override func viewDidLoad() {
        super.viewDidLoad()
      
        update()
    }
    
    func update() {
        CatApiClientResult.shared.fetchFavorites { result in
            switch result {
            case .success(let favorites):
                self.updateUI(with: favorites)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func updateUI(with favorites: [Favorite]) {
        self.favorites = favorites
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func upVote(_ sender: Any) {
        CatApiClientResult.shared.vote(imageId: "9ccXTANkb", value: .up) { result in
            switch result {
            case .success(let updateVote):
                print(updateVote)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func uploadPhoto(_ sender: Any) {
        guard let image = UIImage(named: "cat") else { return }
        CatApiClientResult.shared.uploadImage(image: image) { result in
            switch result {
            case .success(let catImage):
                print(catImage.url)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CatTableViewCell.reuseIdentifier, for: indexPath) as! CatTableViewCell
        configureCell(cell, forFavoriteAt: indexPath)
        return cell
    }
    
    func configureCell(_ cell: CatTableViewCell, forFavoriteAt indexPath: IndexPath) {
        let favorite = favorites[indexPath.row]
        cell.favoriteIdLabel.text = "\(favorite.id)"
        Nuke.loadImage(with: favorite.image.url, into: cell.photoImageView)
    }
    
}
