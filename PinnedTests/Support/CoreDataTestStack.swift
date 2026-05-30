//
//  CoreDataTestStack.swift
//  PinnedTests
//
//  Created by Michał Wolanin on 26/05/2026.
//

import CoreData
import Foundation
@testable import Pinned

enum CoreDataTestStack {
 
    static func mStore() -> PinStore {
        PinStore(inMemory: true)
    }
 
    static func mRepository() -> CoreDataPinRepository {
        CoreDataPinRepository(store: mStore())
    }
 
    static func mContext() -> NSManagedObjectContext {
        mStore().container.viewContext
    }
}
