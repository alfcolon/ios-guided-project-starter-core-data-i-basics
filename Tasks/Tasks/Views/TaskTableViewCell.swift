//
//  TaskTableViewCell.swift
//  Tasks
//
//  Created by Ben Gohlke on 4/20/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    var task: Task? { didSet { self.updateViews() } }
    static var reuseIdentifier: String = "TaskCell"
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var completedButton: UIButton!
    @IBOutlet weak var taskNameLabel: UILabel!
    
    //MARK: - IBActions
    
    @IBAction func toggleComplete(_ sender: UIButton) {
        guard let task = task else { return }
        
        task.complete.toggle()
        
        sender.setImage(task.complete ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"), for: .normal)
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            CoreDataStack.shared.mainContext.reset()
            NSLog("Error saving context )changing task complete boolean): \(error)")
        }
    }
    
    //MARK: - Methods
    
    private func updateViews() {
        guard let task = task else { return }
        
        self.taskNameLabel.text = task.name
        
        self.completedButton.setImage(task.complete ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"), for: .normal)
        
    }
}
