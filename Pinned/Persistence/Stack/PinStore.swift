//
//  PinStore.swift
//  Pinned
//
//  Created by Michał Wolanin on 25/05/2026.
//

import CoreData

public final class PinStore {
    public let container: NSPersistentContainer
    private static let modelName = "Pinned"

    public init(inMemory: Bool = false) {
        container = NSPersistentContainer(
            name: Self.modelName,
            managedObjectModel: Self.model
        )

        let description = container.persistentStoreDescriptions.first
            ?? NSPersistentStoreDescription()

        if inMemory {
            description.type = NSInMemoryStoreType
            description.url = URL(fileURLWithPath: "/dev/null")
        }

        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true

        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Failed to load persistent store: \(error)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }


    private static let model: NSManagedObjectModel = {
        let bundles = [Bundle(for: PinStore.self), Bundle.main]
        for bundle in bundles {
            if let url = bundle.url(forResource: modelName, withExtension: "momd"),
               let model = NSManagedObjectModel(contentsOf: url) {
                return model
            }
        }
        fatalError("Failed to locate Core Data model \(modelName).momd")
    }()
}
