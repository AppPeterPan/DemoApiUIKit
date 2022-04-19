//
//  Favorite.swift
//  DemoApi
//
//  Created by Peter Pan on 2022/4/18.
//

import Foundation

struct Favorite: Decodable {
    let id: Int
    let subId: String
    let image: CatImage
}

