//
//  PostsTableViewController.swift
//  CoreDataTest
//
//  Created by Alexandre Giguere on 2018-06-12.
//  Copyright © 2018 Alexandre Giguere. All rights reserved.
//

import UIKit
import CoreData

class PostsTableViewController: UITableViewController {
    
    lazy var coreDataController: CoreDataController = {
        (UIApplication.shared.delegate as! AppDelegate).coreDataController
    }()
    
    lazy var privateContext: NSManagedObjectContext = {
        self.coreDataController.newPrivateContext()
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Post> = {
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        
        fetchRequest.entity = Post.entity()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Post.id), ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.coreDataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()

        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSave), name: Notification.Name.NSManagedObjectContextDidSave, object: privateContext)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Detail" {
            guard let vc = segue.destination as? PostTableViewController,
                let indexPath = tableView.indexPathForSelectedRow else { return }
            
            vc.post = fetchedResultsController.object(at: indexPath)
            vc.viewContext = coreDataController.viewContext
        }
    }
    
    // for testing purposes
    @objc func managedObjectContextDidSave(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            print(inserts)
            
            coreDataController.viewContext.mergeChanges(fromContextDidSave: notification)
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            print(updates)
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            print(deletes)
        }
    }
}

// MARK: - PostsTableViewController
extension PostsTableViewController {
    
    func fetchData() {
        do {
            try fetchedResultsController.performFetch()
            
            tableView.reloadData()
            
        } catch {
            print(error)
        }
    }
}

// MARK: - UITableViewDataSource
extension PostsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath)
        
        let post = fetchedResultsController.object(at: indexPath)
        
        cell.textLabel?.text = post.id
        cell.detailTextLabel?.text = post.title
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PostsTableViewController { }

// MARK: - NSFetchedResultsControllerDelegate
extension PostsTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            
        case .update:
            guard let indexPath = indexPath else { return }
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            // not needed yet since comment is not display in the cell
//            if let cell = tableView.cellForRow(at: indexPath) as? Cell {
//                configureTableViewCell(cell, at: indexPath)
//            }
            
        case .delete:
            guard let indexPath = indexPath else { return }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
            
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
            
        default: ()
        }
    }
}
