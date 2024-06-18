import SwiftUI
import SwiftData

@main
struct BongSooApp: App {
    @StateObject private var pathHolder = NavigationPathHolder()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $pathHolder.navigationPath) {
                BTPage()
                    .environmentObject(pathHolder)
            }
        }
    }
}

class NavigationPathHolder: ObservableObject {
    @Published var navigationPath = NavigationPath()
}
