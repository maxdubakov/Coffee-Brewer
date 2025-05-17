import SwiftUI

@main
struct Coffee_BrewerApp: App {
  let persistenceController = PersistenceController.shared
  
  var body: some Scene {
    WindowGroup {
      GlobalBackground {
        MainView()
          .environment(\.managedObjectContext, persistenceController.container.viewContext)
          .preferredColorScheme(.dark)
      }
    }
  }
}
