//
//  URLSession+Extension.swift
//  DemoApiUIKit
//
//  Created by Peter Pan on 2022/4/19.
//

import Foundation

extension URLSession {
    static let catAPI: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "x-api-key": "DEMO-API-KEY"
        ]
        return URLSession(configuration: configuration)
    }()
}
