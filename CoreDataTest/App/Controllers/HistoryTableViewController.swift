//
//  HistoryTableViewController.swift
//  CoreDataTest
//
//  Created by Alexandre Giguere on 2020-03-15.
//  Copyright © 2020 Alexandre Giguere. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: UITableViewController {
    
    var lastToken: NSPersistentHistoryToken? = nil {
        didSet {
            guard let token = lastToken else { return }
            
            do {
                // does not work - need to investigate
                let data = try NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: false)
                
                try data.write(to: tokenFile)
            
            } catch {
                print("###\(#function): Could not write token data: \(error)")
            }
        }
    }

    lazy var tokenFile: URL = {
        let url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("YourProjectName", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                
            } catch {
                let message = "Could not create persistent container URL"
                print("###\(#function): \(message): \(error)")
            }
        }
        
        return url.appendingPathComponent("token.data", isDirectory: false)
    }()
    
    lazy var coreDataController: CoreDataController = {
        return (UIApplication.shared.delegate as! AppDelegate).coreDataController
    }()
    
    var context: NSManagedObjectContext!
    
    var transactions = [NSPersistentHistoryTransaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = coreDataController.newPrivateContext()
        
        let fetchHistoryRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: lastToken)

        context.perform {
            do {
                guard let historyResult = try self.context.execute(fetchHistoryRequest) as? NSPersistentHistoryResult else {
                    fatalError("Could not convert history result to transactions.")
                }
                
                self.transactions = (historyResult.result as? [NSPersistentHistoryTransaction]) ?? []
                
                //self.lastToken = NSPersistentHistoryToken()
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - UITableViewControllerDelegate
extension HistoryTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let transaction = transactions[indexPath.row]
        
        print("Transaction: \(transaction)")
        
        guard let changes = transaction.changes else { return }
        
        // By reading the transaction changes, there is no way to know the updated value at that time
        // This is pretty important when working with you own backend (not CloudKit)
        // If you want to replay the changes in a chronogical orders, we need to be able to know the old & new value
        
        for change in changes {
            switch(change.changeType) {
            case .insert:
                // same thing here, we should be able to know the entity value properties at that time
                // even if it as updated after
                break
                
            case .update:
                guard let updatedProperties = change.updatedProperties else { break }

                // we just know the property names that have been change (here it will be comment)
                
                print("Updated entity properties:")
                
                for updatedProperty in updatedProperties {
                    print(updatedProperty.name)
                }

            default:
                break
            }
        }
    }
}

// MARK: - UITableViewControllerDataSource
extension HistoryTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transactions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        
        let transaction = transactions[indexPath.row]
    
        cell.textLabel?.text = String(transaction.transactionNumber)
        cell.detailTextLabel?.text = transaction.bundleID
        //cell.detailTextLabel?.text = "\(post.subTitle) - (\(post.transactions.count))"
        
        return cell
    }
}
