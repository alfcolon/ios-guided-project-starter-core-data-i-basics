//
//  TasksTableViewController.swift
//  Tasks
//
//  Created by Ben Gohlke on 4/20/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import CoreData
import UIKit

class TasksTableViewController: UITableViewController {

    // MARK: - Properties
    
    lazy var fetchedResultsController: NSFetchedResultsController<Task> = {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        //Sorting
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "priority", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        let context = CoreDataStack.shared.mainContext
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                managedObjectContext: context,
                                                                sectionNameKeyPath: "priority",
                                                                cacheName: nil)
        fetchResultsController.delegate = self
        try! fetchResultsController.performFetch()
        return fetchResultsController
    }()
    let taskController = TaskController()
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reuseIdentifier, for: indexPath) as? TaskTableViewCell else { fatalError("Can't deque cell of type \(TaskTableViewCell.reuseIdentifier)") }

        cell.task = self.fetchedResultsController.object(at: indexPath)

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //grab task
            let task = self.fetchedResultsController.object(at: indexPath)
            //try to delete from server
            self.taskController.deleteTaskFromServer(task) { result in
                guard let _ = try? result.get() else { return }
                //delete task from CoreData if task was deleted from server
                let context = CoreDataStack.shared.mainContext
                context.delete(task)
                do {
                    try context.save()
    //                self.tableView.deleteRows(at: [indexPath], with: .fade)
                } catch {
                    
                    //THE TASK WOULD HAVE TO BE RESENT TO SERVER TO AVOID BAD DATA HYGIENE SINCE IT WAS ALREADY DELETED
                    self.taskController.sendTaskToServer(task: task)
                    //THAT SHOULD WORK
                    //AS LONG AS IT WAS SENT TO THE SERVER
                    
                    //Undo the deletion via reset
                    context.reset()
                    NSLog("Error saving managed object context (delete task): \(error)")
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return nil }
        return sectionInfo.name.capitalized
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //inject dependencies
        
        if segue.identifier == "CreateTaskModalSegue" {
            if let navC = segue.destination as? UINavigationController {
                let createTaskVC = navC.viewControllers.first as? CreateTaskViewController
                createTaskVC?.taskController = taskController
            }
        }
    }
}

extension TasksTableViewController: NSFetchedResultsControllerDelegate {
    //Update tableview
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    //Manage Changes
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            guard let indexPath = indexPath else { return }
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            self.tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath else { return }
            guard let newIndexPath = newIndexPath else { return }
            self.tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            self.tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        @unknown default:
            break
        }
    }
}
