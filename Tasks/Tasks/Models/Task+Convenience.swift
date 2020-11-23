//
//  Task+Convenience.swift
//  Tasks
//
//  Created by Alfredo Colon on 7/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import CoreData
import Foundation

enum TaskPriority: String, CaseIterable {
    case low
    case normal
    case high
    case critical
}

extension Task {
    
    var taskRepresentation: TaskRepresentation? {
        guard let id = identifier,
              let name = name,
              let priority = priority else { return nil }
        return TaskRepresentation(complete: complete,
                                  identifier: id.uuidString,
                                  name: name,
                                  notes: notes,
                                  priority: priority)
    }
    
    @discardableResult convenience init(complete: Bool = false,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext,
                                        identifier: UUID = UUID(),
                                        name: String,
                                        notes: String? = nil,
                                        priority: TaskPriority = .normal
    ) {
        self.init(context: context)
        self.complete = complete
        self.identifier = identifier
        self.name = name
        self.notes = notes
        self.priority = priority.rawValue
    }
    
    @discardableResult convenience init?(taskRepresentation: TaskRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext
    ) {
        guard let identifier = UUID(uuidString: taskRepresentation.identifier),
              let priority = TaskPriority(rawValue: taskRepresentation.priority) else { return nil }
        
        self.init(complete: taskRepresentation.complete,
                  context: context,
                  identifier: identifier,
                  name: taskRepresentation.name,
                  notes: taskRepresentation.notes,
                  priority: priority)
    }
}
