import SwiftUI

/// 메인 탭 뷰 — 4개 탭 (거래기록/통계/예산/설정)
struct MainTabView: View {
    /// 선택된 탭 인덱스
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TransactionListView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("거래기록")
                }
                .tag(0)

            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("통계")
                }
                .tag(1)

            BudgetView()
                .tabItem {
                    Image(systemName: "target")
                    Text("예산")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("설정")
                }
                .tag(3)
        }
        .tint(AppColor.primary)
    }
}
