//
//  CatApiClientCompletion.swift
//  DemoApiUIKit
//
//  Created by Peter Pan on 2022/4/18.
//

import Foundation

class CatApiClientCompletion {
    static let shared = CatApiClientCompletion()
    let baseURL = URL(string: "https://api.thecatapi.com/v1")!
    let urlSession: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "x-api-key": "DEMO-API-KEY"
        ]
        urlSession = URLSession(configuration: configuration)
    }
    
    func decode<T: Decodable>(data: Data?, completion: @escaping (T?) -> Void) {

        if let data = data {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                completion(decodedData)
            } catch {
                completion(nil)
            }
        } else  {
            completion(nil)
        }
    }
    
    func fetchFavorites(completion: @escaping ([Favorite]?) -> Void) {
        guard let userId = User.current?.id else {
            completion(nil)
            return
        }
        let baseCategoriesURL = baseURL.appendingPathComponent("favourites")
        var components = URLComponents(url: baseCategoriesURL, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "sub_id", value: userId)
        ]
        let categoriesURL = components.url!
        let request = URLRequest(url: categoriesURL)
        urlSession.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(nil)
                return
            }
            self.decode(data: data, completion: completion)
        }.resume()
    }
    
    func vote(imageId: String, value: VoteValue, completion: @escaping (UpdateVote?) -> Void) {
        guard let userId = User.current?.id else {
            completion(nil)
            return
        }
        let url = baseURL.appendingPathComponent("votes")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        let body = UpdateVoteBody(imageId: imageId, subId: userId, value: value)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? encoder.encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlSession.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(nil)
                return
            }
            self.decode(data: data, completion: completion)
        }.resume()
    }
}
