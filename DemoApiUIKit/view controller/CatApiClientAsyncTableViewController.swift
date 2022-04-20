//
//  CatApiClientAsyncTableViewController.swift
//  DemoApiUIKit
//
//  Created by Peter Pan on 2022/4/18.
//

import UIKit
import Nuke

class CatApiClientAsyncTableViewController: UITableViewController {
    
    var favorites = [Favorite]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        update()
    }
    
    func update() {
        Task {
            do {
                let favorites = try await CatApiClient.shared.fetchFavorites()
                updateUI(with: favorites)
            } catch {
                print(error)
            }
        }
    }
    
    func updateUI(with favorites: [Favorite]) {
        self.favorites = favorites
        self.tableView.reloadData()
    }
    
    @IBAction func upVote(_ sender: Any) {
        Task {
            try? await CatApiClient.shared.vote(imageId: "9ccXTANkb", value: .up)
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
