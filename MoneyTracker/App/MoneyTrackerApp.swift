import SwiftUI
import SwiftData

/// Money Tracker 앱 진입점
@main
struct MoneyTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [TransactionRecord.self])
    }
}
