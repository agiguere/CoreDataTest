//
//  Transaction.swift
//  CoreDataTest
//
//  Created by Alexandre Giguere on 2019-04-29.
//  Copyright © 2019 Alexandre Giguere. All rights reserved.
//

//import Foundation
//import CoreData
//
//class Transaction: NSManagedObject {
//    
//    @NSManaged var url: String
//    @NSManaged var post: Post?
//
//    static var entityName: String { return "Transaction" }
//    
//    class func fetchRequest() -> NSFetchRequest<Transaction> {
//        return NSFetchRequest<Transaction>(entityName: entityName)
//    }
//}
//
//extension Transaction {
//    
//    @discardableResult static func create(url: String, into context: NSManagedObjectContext) -> Transaction {
//        let transaction = Transaction(context: context)
//        
//        transaction.url = url
//        
//        return transaction
//    }
//    
////    static func importNewPosts(with context: NSManagedObjectContext) {
////        create(id: "16", title: "title 16", subTitle: "sub 16", comment: "", into: context)
////    }
////
////    static func createAll(with context: NSManagedObjectContext) {
////        create(id: "01", title: "title 01", subTitle: "sub 01", comment: "", into: context)
////        create(id: "02", title: "title 02", subTitle: "sub 02", comment: "", into: context)
////        create(id: "03", title: "title 03", subTitle: "sub 03", comment: "", into: context)
////        create(id: "04", title: "title 04", subTitle: "sub 04", comment: "", into: context)
////        create(id: "05", title: "title 05", subTitle: "sub 05", comment: "", into: context)
////        create(id: "06", title: "title 06", subTitle: "sub 06", comment: "", into: context)
////        create(id: "07", title: "title 07", subTitle: "sub 07", comment: "", into: context)
////        create(id: "08", title: "title 08", subTitle: "sub 08", comment: "", into: context)
////        create(id: "09", title: "title 09", subTitle: "sub 09", comment: "", into: context)
////        create(id: "10", title: "title 10", subTitle: "sub 10", comment: "", into: context)
////    }
////
////    static func deleteAll() {
////
////    }
//}
