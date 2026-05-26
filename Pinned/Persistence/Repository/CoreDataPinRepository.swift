//
//  CoreDataPinRepository.swift
//  Pinned
//
//  Created by Michał Wolanin on 25/05/2026.
//

import CoreData

public final class CoreDataPinRepository: PinRepository, @unchecked Sendable {
    private let container: NSPersistentContainer

    public init(store: PinStore) {
        self.container = store.container
    }

    // MARK: - PinRepository
    public func fetchAll() async throws -> [PinSet] {
        try await run(mapError: RepositoryError.fetchFailed) { context in
            try context.fetch(PinSetEntity.sortedByCreatedAt()).map { try $0.toDomain() }
        }
    }

    public func save(_ pinSet: PinSet) async throws {
        try await run(mapError: RepositoryError.saveFailed) { context in
            let entity = try context.fetch(PinSetEntity.byID(pinSet.id)).first
                ?? PinSetEntity(context: context)
            try entity.apply(pinSet)

            if context.hasChanges {
                try context.save()
            }
        }
    }

    public func delete(id: UUID) async throws {
        try await run(mapError: RepositoryError.deleteFailed) { context in
            guard let entity = try context.fetch(PinSetEntity.byID(id)).first else { return }
            context.delete(entity)
            try context.save()
        }
    }

    // MARK: - Helpers
    private func run<T>(
        mapError: @escaping (_ underlying: Error) -> RepositoryError,
        _ work: @escaping (NSManagedObjectContext) throws -> T
    ) async throws -> T {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        do {
            return try await context.perform { try work(context) }
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw mapError(error)
        }
    }
}
