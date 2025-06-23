//
//  NoteAppApp.swift
//  NoteApp
//
//  Created by Jenith KJ on 23/06/25.
//

import SwiftUI

@main
struct NoteAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
