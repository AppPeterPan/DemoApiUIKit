//
//  User.swift
//  DemoApiUIKit
//
//  Created by Peter Pan on 2022/4/19.
//

import Foundation

struct User {
    let id: String
    static var current: User? = User(id: "123")
}
