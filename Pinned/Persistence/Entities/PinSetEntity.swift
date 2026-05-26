//
//  PinSetEntity.swift
//  Pinned
//
//  Created by Michał Wolanin on 25/05/2026.
//

import CoreData

@objc(PinSetEntity)
final class PinSetEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var domain: String
    @NSManaged var includeSubdomains: Bool
    @NSManaged var createdAt: Date
    @NSManaged var hashesData: Data
}

// MARK: - Fetch request
extension PinSetEntity {
    static let entityName = "PinSetEntity"

    static func makeFetchRequest() -> NSFetchRequest<PinSetEntity> {
        NSFetchRequest<PinSetEntity>(entityName: entityName)
    }

    static func sortedByCreatedAt() -> NSFetchRequest<PinSetEntity> {
        let request = makeFetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \PinSetEntity.createdAt, ascending: true)
        ]
        return request
    }

    static func byID(_ id: UUID) -> NSFetchRequest<PinSetEntity> {
        let request = makeFetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        request.fetchLimit = 1
        return request
    }
}
