//
//  CatApiClientResult.swift
//  DemoApiUIKit
//
//  Created by Peter Pan on 2022/4/18.
//

import Foundation

class CatApiClientResult {
    static let shared = CatApiClientResult()
    let baseURL = URL(string: "https://api.thecatapi.com/v1")!
    let urlSession: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "x-api-key": "DEMO-API-KEY"
        ]
        urlSession = URLSession(configuration: configuration)
    }
    
    func decode<T: Decodable>(data: Data?, error: Error?, response: URLResponse?, completion: @escaping (Result<T, Error>) -> Void) {

        if let data = data {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                
                if let apiErrorResponse = try? decoder.decode(ApiErrorResponse.self, from: data) {
                    completion(.failure(apiErrorResponse))
                } else {
                    completion(.failure(CatApiError.requestFailed))
                }
                return
            }
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        } else if let error = error {
            completion(.failure(error))
        }
    }
    
    func fetchFavorites(completion: @escaping (Result<[Favorite], Error>) -> Void) {
        guard let userId = User.current?.id else {
            completion(.failure(CatApiError.userNotLogin))
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
            self.decode(data: data, error: error, response: response, completion: completion)
        }.resume()
    }
    
    func vote(imageId: String, value: VoteValue, completion: @escaping (Result<UpdateVote, Error>) -> Void) {
        guard let userId = User.current?.id else {
            completion(.failure(CatApiError.userNotLogin))
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
            self.decode(data: data, error: error, response: response, completion: completion)
        }.resume()
    }
}
