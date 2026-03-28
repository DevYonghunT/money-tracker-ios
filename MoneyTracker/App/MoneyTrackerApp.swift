import SwiftUI
import SwiftData

/// Money Tracker 앱 진입점
@main
struct MoneyTrackerApp: App {
    /// 프리미엄 서비스
    @StateObject private var premiumService = PremiumService()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
                .environmentObject(premiumService)
        }
        .modelContainer(for: [TransactionRecord.self])
    }
}
