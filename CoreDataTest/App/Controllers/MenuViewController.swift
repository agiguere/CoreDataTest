//
//  MenuViewController.swift
//  CoreDataTest
//
//  Created by Alexandre Giguere on 2020-03-15.
//  Copyright © 2020 Alexandre Giguere. All rights reserved.
//

import UIKit
import CoreData

class MenuViewController: UIViewController {
    
    lazy var coreDataController: CoreDataController = {
        return (UIApplication.shared.delegate as! AppDelegate).coreDataController
    }()
    
    @IBAction func createEntity(_ sender: UIButton) {
        coreDataController.performBackgroundTask(block: { context in
            Post.importNewPosts(with: context)

            do {
                try context.save()

            } catch {
                print(error)
            }
        })
    }
}

// MARK: - Private API
private extension MenuViewController {
    

    
    @IBAction func purgeHistory(_ sender: UIButton) {
        coreDataController.performBackgroundTask { context in
            //let sevenDaysAgo = Date(timeIntervalSinceNow: TimeInterval(exactly: -604_800)!)
            
            var token: NSPersistentHistoryToken?
            
            // unfinished - get token from file - for now delete everything
            let purgeHistoryRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: token)

            do {
                try context.execute(purgeHistoryRequest)
                
            } catch {
                fatalError("Could not purge history: \(error)")
            }
        }
    }
}
