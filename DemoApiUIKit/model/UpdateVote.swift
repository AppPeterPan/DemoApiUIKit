//
//  UpdateVote.swift
//  DemoApiUIKit
//
//  Created by Peter Pan on 2022/4/19.
//

import Foundation

enum VoteValue: Int, Encodable {
    case up = 1, donw = 0
}
struct UpdateVoteBody: Encodable {
    let imageId: String
    let subId: String
    let value: VoteValue
}

struct UpdateVote: Decodable {
    let message: String
    let id: Int
}
