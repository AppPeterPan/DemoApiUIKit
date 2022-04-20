//
//  CatApiClientCompletion.swift
//  DemoApiUIKit
//
//  Created by Peter Pan on 2022/4/18.
//

import UIKit

class CatApiClientCompletion {
    static let shared = CatApiClientCompletion()
    let baseURL = URL(string: "https://api.thecatapi.com/v1")!
    let urlSession: URLSession
    let boundary = "Boundary-\(UUID().uuidString)"
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "x-api-key": "DEMO-API-KEY"
        ]
        urlSession = URLSession(configuration: configuration)
    }
    
    func decode<T: Decodable>(data: Data?, response: URLResponse?, completion: @escaping (T?) -> Void) {
        guard let httpResponse = response as? HTTPURLResponse,
              200...201 ~= httpResponse.statusCode else {
            completion(nil)
            return
        }
        
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
            self.decode(data: data, response: response, completion: completion)
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
            self.decode(data: data, response: response, completion: completion)
        }.resume()
    }
    
    func uploadImage(image: UIImage, completion: @escaping (CatImage?) -> Void) {
        guard let userId = User.current?.id else {
            completion(nil)
            return
        }
        let url = baseURL.appendingPathComponent("images/upload")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        
        let parameters: [String: Any] = [
            "sub_id": userId,
            "file": image
        ]
        request.createMultipartFormData(parameters: parameters)
        urlSession.dataTask(with: request) { data, response, error in
            self.decode(data: data, response: response, completion: completion)
        }.resume()
    }
}
