//
//  TaskRepresentation.swift
//  Tasks
//
//  Created by Alfredo Colon on 7/18/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

struct TaskRepresentation: Codable {

    //MARK: - Properties

    var complete: Bool
    var identifier: String
    var name: String
    var notes: String?
    var priority: String

    enum CodingKeys: String, CodingKey {
        case complete = "completed"
        case identifier
        case name
        case notes
        case priority
    }
}
