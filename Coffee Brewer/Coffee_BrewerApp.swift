//
//  Coffee_BrewerApp.swift
//  Coffee Brewer
//
//  Created by Max on 12/02/2025.
//

import SwiftUI

@main
struct Coffee_BrewerApp: App {
  let persistenceController = PersistenceController.shared
  var body: some Scene {
    WindowGroup {
      MainView().environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
