import SwiftUI

@main
struct MyDreamTeamApp: App {
    
    var body: some Scene {
        WindowGroup {
            EstablishmentBuilder().build(with: .delivery)
        }
    }
}
