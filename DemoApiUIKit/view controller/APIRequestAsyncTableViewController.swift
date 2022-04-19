//
//  APIRequestAsyncTableViewController.swift
//  DemoApiUIKit
//
//  Created by Peter Pan on 2022/4/19.
//

import UIKit
import Nuke

class APIRequestAsyncTableViewController: UITableViewController {
    
    var favorites = [Favorite]()
    var getFavoritesRequestTask: Task<Void, Never>? = nil
    
    deinit {
        getFavoritesRequestTask?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update()
    }
    
    func update() {
        getFavoritesRequestTask?.cancel()
        getFavoritesRequestTask = Task {
            do {
                let favorites = try await GetFavoritesRequest().send()
                updateUI(with: favorites)
            } catch {
                print(error)
            }
            getFavoritesRequestTask = nil
        }
    }
    
    func updateUI(with favorites: [Favorite]) {
        self.favorites = favorites
        self.tableView.reloadData()
    }
    
    
    @IBAction func upVote(_ sender: Any) {
        guard let userId = User.current?.id else { return }
        let body = UpdateVoteBody(imageId: "9ccXTANkb", subId: userId, value: .up)
        Task {
            try? await UpdateVoteRequest(updateVoteBody: body).send()
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
