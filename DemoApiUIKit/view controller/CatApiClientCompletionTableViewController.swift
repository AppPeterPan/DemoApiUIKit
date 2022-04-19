//
//  CatApiClientCompletionTableViewController.swift
//  DemoApiUIKit
//
//  Created by Peter Pan on 2022/4/18.
//

import UIKit
import Nuke

class CatApiClientCompletionTableViewController: UITableViewController {
    
    var favorites = [Favorite]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        update()
    }
    
    func update() {
        CatApiClientCompletion.shared.fetchFavorites { favorites in
            if let favorites = favorites {
                self.updateUI(with: favorites)
            } else {
                print("error")

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
        CatApiClientCompletion.shared.vote(imageId: "9ccXTANkb", value: .up) { updateVote in
            if let updateVote = updateVote {
                print(updateVote)
            } else {
                print("updateVote error")
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
