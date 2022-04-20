//
//  Data+Extension.swift
//  DemoApiUIKit
//
//  Created by Peter Pan on 2022/4/20.
//

import Foundation

extension Data {
    mutating func appendString(_ string: String) {
        append(string.data(using: .utf8)!)
    }
}
