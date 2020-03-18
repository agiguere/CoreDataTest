//
//  Post.swift
//  CoreDataTest
//
//  Created by Alexandre Giguere on 2018-06-12.
//  Copyright © 2018 Alexandre Giguere. All rights reserved.
//

import Foundation
import CoreData

class Post: NSManagedObject {
    
    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var subTitle: String
    @NSManaged var comment: String
//    @NSManaged var transactions: Set<Transaction>
    
    static var entityName: String { return "Post" }
    
    class func fetchRequest() -> NSFetchRequest<Post> {
        return NSFetchRequest<Post>(entityName: entityName)
    }
}

extension Post {    
    
    @discardableResult static func create(id: String, title: String, subTitle: String, comment: String, into context: NSManagedObjectContext) -> Post {
        let post = Post(context: context)
        
        post.id = id
        post.title = title
        post.subTitle = subTitle
        post.comment = comment
        
        return post
    }
    
    static func importNewPosts(with context: NSManagedObjectContext) {
        create(id: UUID().uuidString, title: "Test", subTitle: "Test", comment: "", into: context)
        
//        let transaction = Transaction.create(url: "ostea", into: context)
//
//        post.mutableSetValue(forKey: "transactions").add(transaction)
    }
    
//    static func createAll(with context: NSManagedObjectContext) {
//        create(id: "01", title: "title 01", subTitle: "sub 01", comment: "", into: context)
//        create(id: "02", title: "title 02", subTitle: "sub 02", comment: "", into: context)
//        create(id: "03", title: "title 03", subTitle: "sub 03", comment: "", into: context)
//        create(id: "04", title: "title 04", subTitle: "sub 04", comment: "", into: context)
//        create(id: "05", title: "title 05", subTitle: "sub 05", comment: "", into: context)
//        create(id: "06", title: "title 06", subTitle: "sub 06", comment: "", into: context)
//        create(id: "07", title: "title 07", subTitle: "sub 07", comment: "", into: context)
//        create(id: "08", title: "title 08", subTitle: "sub 08", comment: "", into: context)
//        create(id: "09", title: "title 09", subTitle: "sub 09", comment: "", into: context)
//        create(id: "10", title: "title 10", subTitle: "sub 10", comment: "", into: context)
//    }
}
