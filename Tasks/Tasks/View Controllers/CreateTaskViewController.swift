//
//  CreateTaskViewController.swift
//  Tasks
//
//  Created by Ben Gohlke on 4/20/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class CreateTaskViewController: UIViewController {

    // MARK: - Properties

    var complete: Bool = false
    var taskController: TaskController?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var priorityControl: UISegmentedControl!
    
    //MARK: - IBActions
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        guard let name: String = self.nameTextField.text, !name.isEmpty else { return }
        
        let notes: String? = self.notesTextView.text
        let priorityIndex = self.priorityControl.selectedSegmentIndex
        let priority = TaskPriority.allCases[priorityIndex]
        
        //Create/Add task
        let task = Task(complete: self.complete, name: name, notes: notes, priority: priority)
        taskController?.sendTaskToServer(task: task)
        
        //Save Tasks
        do {
            try CoreDataStack.shared.mainContext.save()
            self.navigationController?.dismiss(animated: true, completion: nil)
            
        } catch {
            NSLog("Error saving managed context \(error)")
        }
    }
    
    @IBAction func toggleComplete(_ sender: UIButton) {
        self.complete.toggle()
        sender.setImage(self.complete  ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle"), for: .normal)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
