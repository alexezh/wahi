//
//  wahiApp.swift
//  wahi
//
//  Created by alexezh on 5/26/25.
//

import SwiftUI

@main
struct wahiApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
