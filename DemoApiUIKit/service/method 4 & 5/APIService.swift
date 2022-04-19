//
// APIService.swift
// Habits
//


import UIKit

struct GetFavoritesRequest: APIRequest {
    var path = "/favourites"
    var method: HTTPMethod { .get }
    typealias Response = [Favorite]
    var queryItems: [URLQueryItem]? {
        if let userId = User.current?.id {
            return [URLQueryItem(name: "sub_id", value: userId)]
        } else {
            return nil
        }
    }
}

struct UpdateVoteRequest: APIRequest {
    var path = "/votes"
    let updateVoteBody: UpdateVoteBody
    var method: HTTPMethod { .post }
    typealias Response = UpdateVote
    var data: Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try? encoder.encode(updateVoteBody)
    }
}
