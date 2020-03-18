//
//  CoreDataController.swift
//  Dollarama
//
//  Created by Alexandre Giguere on 2018-06-12.
//  Copyright © 2018 Dollarama. All rights reserved.
//

//
//  CoreDataController.swift
//
//  Created by Keith Harrison http://useyourloaf.com
//  Copyright (c) 2017 Keith Harrison. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//
//  3. Neither the name of the copyright holder nor the names of its
//  contributors may be used to endorse or promote products derived from
//  this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
import Foundation
import CoreData

/// `CoreDataController` is a simple wrapper class for setting up
/// and using a Core Data stack.
///
/// Warning: Requires iOS 10 as it depends on the availability of
/// `NSPersistentContainer`.
@available(iOS 10.0, macOS 10.12, watchOS 3.0, tvOS 10.0, *)
public class CoreDataController: NSObject {
    
    /// The default directory for the persistent stores on the current platform.
    ///
    /// - Returns: An `NSURL` for the directory containing the persistent
    ///   store(s). If the persistent store does not exist it will be created
    ///   by default in this location when loaded.
    public class func defaultDirectoryURL() -> URL {
        return NSPersistentContainer.defaultDirectoryURL()
    }
    
    /// A read-only flag indicating if the persistent store is loaded.
    public private (set) var isStoreLoaded = false
    
    /// The managed object context associated with the main queue (read-only).
    /// To perform tasks on a private background queue see
    /// `performBackgroundTask:` and `newPrivateContext`.
    ///
    /// The context is configured to be generational and to automatically
    /// consume save notifications from other contexts.
    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /// The `URL` of the persistent store for this Core Data Stack. If there
    /// is more than one store this property returns the first store it finds.
    /// The store may not yet exist. It will be created at this URL by default
    /// when first loaded.
    ///
    /// This is a readonly property to create a persistent store in a different
    /// location use `loadStoreAtURL:withCompletionHandler`. To move an existing
    ///  persistent store use
    /// `replacePersistentStoreAtURL:withPersistentStoreFromURL:`.
    public var storeURL: URL? {
        var url: URL?
        let descriptions = persistentContainer.persistentStoreDescriptions
        if let firstDescription = descriptions.first {
            url = firstDescription.url
        }
        return url
    }
    
    /// A flag that indicates whether this store is read-only. Set this value
    /// to YES before loading the persistent store if you want a read-only
    /// store (for example if loading from the application bundle).
    /// Default is false.
    public var isReadOnly = false
    
    /// A flag that indicates whether the store is added asynchronously.
    /// Set this value before loading the persistent store.
    /// Default is true.
    public var shouldAddStoreAsynchronously = true
    
    /// A flag that indicates whether the store should be migrated
    /// automatically if the store model version does not match the
    /// coordinators model version.
    /// Set this value before loading the persistent store.
    /// Default is true.
    public var shouldMigrateStoreAutomatically = true
    
    /// A flag that indicates whether a mapping model should be inferred
    /// when migrating a store.
    /// Set this value before loading the persistent store.
    /// Default is true.
    public var shouldInferMappingModelAutomatically = true
    
    /// Creates and returns a `CoreDataController` object. This is the designated
    /// initializer for the class. It creates the managed object model,
    /// persistent store coordinator and main managed object context but does
    /// not load the persistent store.
    ///
    /// The managed object model should be in the same bundle as this class.
    ///
    /// - Parameter name: The name of the persistent store.
    ///
    /// - Returns: A `CoreDataController` object or nil if the model
    ///   could not be loaded.
    public init?(name: String) {
        let bundle = Bundle(for: CoreDataController.self)
        guard let mom = NSManagedObjectModel.mergedModel(from: [bundle]) else {
            return nil
        }
        
        persistentContainer = NSPersistentContainer(name: name, managedObjectModel: mom)
        
        let description = persistentContainer.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        //description?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        super.init()
        
        viewContext.automaticallyMergesChangesFromParent = true
    }
    
    /// Load the persistent store from the default location.
    ///
    /// - Parameter handler: This handler block is executed on the calling
    ///   thread when the loading of the persistent store has completed.
    ///
    /// To override the default name and location of the persistent store use
    /// `loadStoreAtURL:withCompletionHandler:`.
    public func loadStore(completionHandler: @escaping (Error?) -> Void) {
        loadStore(storeURL: storeURL, completionHandler: completionHandler)
    }
    
    /// Load the persistent store from a specified location
    ///
    /// - Parameter storeURL: The URL for the location of the persistent
    ///   store. It will be created if it does not exist.
    /// - Parameter handler: This handler block is executed on the calling
    ///   thread when the loading of the persistent store has completed.
    public func loadStore(storeURL: URL?, completionHandler: @escaping (Error?) -> Void) {
        
        if let storeURL = storeURL ?? self.storeURL {
            let description = storeDescription(with: storeURL)
            persistentContainer.persistentStoreDescriptions = [description]
        }
        
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if error == nil {
                self.isStoreLoaded = true
            }
            
            DispatchQueue.main.async {
                completionHandler(error)
            }
        }
    }
    
    /// A flag indicating if the persistent store exists at the specified URL.
    ///
    /// - Parameter storeURL: An `NSURL` object for the location of the
    ///   peristent store.
    ///
    /// - Returns: true if a file exists at the specified URL otherwise false.
    ///
    /// - Warning: This method checks if a file exists at the specified
    ///   location but does not verify if it is a valid persistent store.
    public func persistentStoreExists(at storeURL: URL) -> Bool {
        if storeURL.isFileURL &&
            FileManager.default.fileExists(atPath: storeURL.path) {
            return true
        }
        return false
    }
    
    /// Destroy a persistent store.
    ///
    /// - Parameter storeURL: An `NSURL` for the persistent store to be
    ///   destroyed.
    /// - Returns: A flag indicating if the operation was successful.
    /// - Throws: If the store cannot be destroyed.
    public func destroyPersistentStore(at storeURL: URL) throws {
        let psc = persistentContainer.persistentStoreCoordinator
        try psc.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
    }
    
    /// Replace a persistent store.
    ///
    /// - Parameter destinationURL: An `NSURL` for the persistent store to be
    ///   replaced.
    /// - Parameter sourceURL: An `NSURL` for the source persistent store.
    /// - Returns: A flag indicating if the operation was successful.
    /// - Throws: If the persistent store cannot be replaced.
    public func replacePersistentStore(at url: URL, withPersistentStoreFrom sourceURL: URL) throws {
        let psc = persistentContainer.persistentStoreCoordinator
        try psc.replacePersistentStore(at: url, destinationOptions: nil,
                                       withPersistentStoreFrom: sourceURL, sourceOptions: nil, ofType: NSSQLiteStoreType)
    }
    
    /// Create and return a new private queue `NSManagedObjectContext`. The
    /// new context is set to consume `NSManagedObjectContextSave` broadcasts
    /// automatically.
    ///
    /// - Returns: A new private managed object context
    public func newPrivateContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    /// Execute a block on a new private queue context.
    ///
    /// - Parameter block: A block to execute on a newly created private
    ///   context. The context is passed to the block as a parameter.
    public func performBackgroundTask(block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    /// Return an object ID for the specified URI representation if a matching
    /// store is available.
    ///
    /// - Parameter storeURL: An `NSURL` containing a URI of a managed object.
    /// - Returns: An optional `NSManagedObjectID`.
    public func managedObjectID(forURIRepresentation storeURL: URL) -> NSManagedObjectID? {
        let psc = persistentContainer.persistentStoreCoordinator
        return psc.managedObjectID(forURIRepresentation: storeURL)
    }
    
    private let persistentContainer: NSPersistentContainer;
    
    private func storeDescription(with url: URL) -> NSPersistentStoreDescription {
        let description = NSPersistentStoreDescription(url: url)
        description.shouldMigrateStoreAutomatically = shouldMigrateStoreAutomatically
        description.shouldInferMappingModelAutomatically = shouldInferMappingModelAutomatically
        description.shouldAddStoreAsynchronously = shouldAddStoreAsynchronously
        description.isReadOnly = isReadOnly
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        return description
    }
    
    /// Delete all records of an entity
    ///
    /// - Parameters:
    ///   - entityName: The entity name to delete
    ///   - resultType: The batch delete request result type
    /// - Returns: A tuple with the batch result and error
    @discardableResult public func batchDelete(entityNamed entityName: String, resultType: NSBatchDeleteRequestResultType = .resultTypeCount) -> (result: NSBatchDeleteResult?, error: NSError?) {
        var error: NSError?
        var result: NSBatchDeleteResult?
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: entityName, in: viewContext)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = resultType
        
        do {
            result = try viewContext.execute(deleteRequest) as? NSBatchDeleteResult
            
        } catch let deleteError as NSError {
            error = deleteError
        }
        
        return (result, error)
    }
    
    /// Delete all records from an entity list
    ///
    /// - Parameters:
    ///   - entityNames: A list of entity names to delete
    ///   - resultType: The batch delete request result type
    /// - Returns: An array containing the result for each entity
    @discardableResult open func batchDelete(entitiesNamed entityNames: [String], resultType: NSBatchDeleteRequestResultType = .resultTypeCount) -> [(NSBatchDeleteResult?, NSError?)] {
        let results = entityNames.map({ batchDelete(entityNamed: $0, resultType: resultType)})
        
        viewContext.reset()
        
        return results
    }
}
