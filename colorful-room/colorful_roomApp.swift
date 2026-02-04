//
//  colorful_roomApp.swift
//  colorful-room
//
//  Created by Ping9 on 10/10/2021.
//

import SwiftUI

@main
struct colorful_roomApp: App {
    let persistenceController = PersistenceController.shared
    
    // register initial UserDefaults values every launch
    init() {
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(PECtl.shared)
                .environmentObject(Data.shared)
        }
    }
}
