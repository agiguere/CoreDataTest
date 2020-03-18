//
//  PostTableViewController.swift
//  CoreDataTest
//
//  Created by Alexandre Giguere on 2018-06-14.
//  Copyright © 2018 Alexandre Giguere. All rights reserved.
//

import UIKit
import CoreData

class PostTableViewController: UITableViewController {

    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var commentTextField: UITextField!
    
    lazy var coreDataController: CoreDataController = {
        return (UIApplication.shared.delegate as! AppDelegate).coreDataController
    }()
    
    var viewContext: NSManagedObjectContext!
    var post: Post!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureOutlets()
        
        navigationItem.rightBarButtonItem = editButtonItem

        // for testing purposes - not really used
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSave), name: Notification.Name.NSManagedObjectContextDidSave, object: viewContext)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        commentTextField.isEnabled = editing
        
        if editing {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelButtonTapped(_:)))
        } else {
            navigationItem.leftBarButtonItem = nil
            
            if viewContext.hasChanges {
                do {
                    viewContext.name = "Saving comment"
                    viewContext.transactionAuthor = "Alexandre Giguere"
                
                    try viewContext.save()
                    
                    viewContext.name = nil
                    viewContext.transactionAuthor = nil
                    
                    navigationController?.popViewController(animated: true)
                    
                } catch {
                    print(error)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

// MARK: - Private API
private extension PostTableViewController {
    
    func configureOutlets() {
        idLabel.text = post.id
        titleLabel.text = post.title
        subtitleLabel.text = post.subTitle
        commentTextField.text = post.comment
        commentTextField.isEnabled = isEditing
    }
    
    @objc func cancelButtonTapped(_ sender: UIBarButtonItem) {
        if viewContext.hasChanges {
            viewContext.rollback()
        }
        
        setEditing(false, animated: true)
        
        configureOutlets()
    }
    
    // for testing purposes - not really used
    @objc func managedObjectContextDidSave(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            print(inserts)
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            print(updates)
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            print(deletes)
        }
    }
    
}
// MARK: - UITextFieldDelegate
extension PostTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        post.comment = textField.text!
        
        textField.resignFirstResponder()
        
        return true
    }
}
