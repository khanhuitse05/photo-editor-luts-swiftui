//
//  Persistence.swift
//  colorful-room
//
//  Created by Ping9 on 10/10/2021.
//

import CoreData
import os

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "colorful-room", category: "Persistence")

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            logger.error("Preview context save failed: \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "colorful_room")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Log the error instead of crashing in production.
                // Typical reasons: missing parent directory, permissions,
                // device out of space, or model migration failure.
                logger.error("Failed to load persistent store: \(error), \(error.userInfo)")
            }
        })
    }
}
