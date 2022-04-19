//
//  ApiErrorResponse.swift
//  DemoApiUIKit
//
//  Created by Peter Pan on 2022/4/19.
//

import Foundation

struct ApiErrorResponse: Decodable, Error {
    let message: String
    let status: Int
}
