//
//  TaskController.swift
//  Tasks
//
//  Created by Alfredo Colon on 7/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import CoreData
import Foundation

enum NetworkError: Error {
    case noIdentifier
    case otherError
    case noData
    case failedDecode
    case failedEncode
}

class TaskController {
    typealias CompletetionHandler = (Result<Bool, NetworkError>) -> Void

    //MARK: - Properties
    
    let baseURL: URL! = URL(string: "https://tasks-3f211.firebaseio.com/")

    //MARK: - Init

    init() {
        self.fetchTasksFromServer()
    }

    //MARK: - Methods

    func fetchTasksFromServer(completion: @escaping CompletetionHandler = { _ in }) {
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { data, _, error in
            //Handle Errors
            if let error = error {
                NSLog("Error fetching tasks: \(error)")
                return completion(.failure(.otherError))
            }
            
            //Make sure data exists
            guard let data = data else {
                NSLog("No data returned from Firebase (fetching tasks).")
                return completion(.failure(.noData))
            }
            
            //Decode data
            do {
                let taskRepresentations: [TaskRepresentation] = Array(try JSONDecoder().decode([String: TaskRepresentation].self, from: data).values)
                try self.updateTasks(with: taskRepresentations)
            } catch {
                NSLog("Error decoding tasks from Firebase: \(error)")
                return completion(.failure(.failedDecode))
            }
        }.resume()
    }

    /*
     take managed object, if it can be encoded encode it into the body the the json request
     */
    func sendTaskToServer(task: Task, completion: @escaping CompletetionHandler = { _ in })
    {
        //the identifier is being unwrapped because it is set as optional to satisfy compile time constraints regardless of whether of not it was set as optional although the optional setting will be satified at runtime.
        guard let uuid = task.identifier else { return completion(.failure(.noIdentifier)) }
        
        //https://tasks-3f211.firebaseio.com/[uuid].json
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        
        //1.Create a request
        var request = URLRequest(url: requestURL)
        //a. set the method: delete, get, post(adds new record), put(replaces or adds a new record)
        request.httpMethod = "PUT"
        
        //2.Encode task representation, add to request
        do {
            guard let representation = task.taskRepresentation else { return completion(.failure(.failedEncode)) }
            
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding task \(task): \(error)")
            return completion(.failure(.failedEncode))
        }
        
        //Reponse handling
        URLSession.shared.dataTask(with: request) { data, _, error in
            //Handle error
            if let error = error {
                NSLog("Error sending task to server \(task): \(error)")
                return completion(.failure(.otherError))
            }
            //Else call true on completion and resume
            completion(.success(true))
        }.resume()
    }

    func deleteTaskFromServer(_ task: Task, completion: @escaping CompletetionHandler = { _ in }) {
        guard let uuid = task.identifier else { return completion(.failure(.noIdentifier)) }
        
        //https://tasks-3f211.firebaseio.com/[uuid].json
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        //Reponse handling
        URLSession.shared.dataTask(with: request) { _, _, error in
            //Handle error
            if let error = error {
                NSLog("Error deleting task to server \(task): \(error)")
                return completion(.failure(.otherError))
            }
            //Else call true on completion and resume
            completion(.success(true))
        }.resume()
    }

    private func updateTasks(with representations: [TaskRepresentation]) throws {
        //get an array of identifiers for tasks in core data
        let identifiersToFetch = representations.compactMap { UUID(uuidString: $0.identifier) }
        //create dictionary of identifier -> task representation
        let representationsByID: [UUID : TaskRepresentation] = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var tasksToCreate = representationsByID
        
        
        //Set-up fetch taskRepresentations that have the same uuid
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.mainContext
        
        let existingTasks = try context.fetch(fetchRequest)
        
        for task in existingTasks {
            guard let id = task.identifier,
                  let representation = representationsByID[id] else { continue }
            self.update(task: task, with: representation)
            tasksToCreate.removeValue(forKey: id)
        }
        
        //tasksToCreate should now contain FireBase Tasks that we don't have in CoreData
        for representation in tasksToCreate.values {
            Task(taskRepresentation: representation, context: context)
        }
        
        //Save to CoreData
        try context.save()
    }

    private func update(task: Task, with representation: TaskRepresentation) {
        task.complete = representation.complete
        task.name = representation.name
        task.notes = representation.notes
        task.priority = representation.priority
    }

}

