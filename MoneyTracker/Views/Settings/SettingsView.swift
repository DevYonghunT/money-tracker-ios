import SwiftUI
import SwiftData

/// 설정 뷰 — 프리미엄, 앱 정보
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var premiumService: PremiumService
    @StateObject private var viewModel = SettingsViewModel()

    /// 프리미엄 필요 알림 표시 여부
    @State private var showingPremiumAlert: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // 프리미엄 섹션
                        premiumSection

                        // 데이터 관리 섹션
                        dataSection

                        // 앱 정보 섹션
                        appInfoSection
                    }
                    .padding(16)
                }
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $viewModel.showingPremiumView) {
                PremiumView()
            }
            .sheet(isPresented: $viewModel.showingShareSheet) {
                if let url = viewModel.csvFileURL {
                    ShareSheet(items: [url])
                }
            }
            .alert("프리미엄 필요", isPresented: $showingPremiumAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text("CSV 내보내기는 프리미엄 기능입니다.\n프리미엄으로 업그레이드하세요!")
            }
        }
    }

    /// 프리미엄 섹션
    private var premiumSection: some View {
        VStack(spacing: 0) {
            // 프리미엄 상태
            Button {
                viewModel.showingPremiumView = true
            } label: {
                HStack {
                    Image(systemName: premiumService.isPremium ? "crown.fill" : "crown")
                        .font(.title3)
                        .foregroundStyle(AppColor.secondary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("프리미엄")
                            .font(.subheadline.bold())
                            .foregroundStyle(AppColor.textPrimary)
                        Text(premiumService.isPremium ? "활성화됨" : "무료 플랜")
                            .font(.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }

                    Spacer()

                    if !premiumService.isPremium {
                        Text("업그레이드")
                            .font(.caption.bold())
                            .foregroundStyle(AppColor.background)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppColor.secondary)
                            .cornerRadius(12)
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                .padding(16)
            }
        }
        .background(AppColor.cardBackground)
        .cornerRadius(12)
    }

    /// 앱 정보 섹션
    private var appInfoSection: some View {
        VStack(spacing: 0) {
            infoRow(title: "앱 이름", value: viewModel.appName)
            Divider().background(AppColor.secondaryBackground)
            infoRow(title: "버전", value: viewModel.appVersion)
            Divider().background(AppColor.secondaryBackground)
            infoRow(title: "개발팀", value: viewModel.teamName)
            Divider().background(AppColor.secondaryBackground)
            infoRow(title: "빌드 모델", value: "iOS 17.0+")
        }
        .background(AppColor.cardBackground)
        .cornerRadius(12)
    }

    /// 데이터 관리 섹션
    private var dataSection: some View {
        VStack(spacing: 0) {
            Button {
                if premiumService.isPremium {
                    exportCSV()
                } else {
                    showingPremiumAlert = true
                }
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                        .foregroundStyle(AppColor.secondary)

                    Text("CSV 내보내기")
                        .font(.subheadline.bold())
                        .foregroundStyle(AppColor.textPrimary)

                    Spacer()

                    if !premiumService.isPremium {
                        Text("프리미엄")
                            .font(.caption2.bold())
                            .foregroundStyle(AppColor.background)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColor.secondary)
                            .cornerRadius(8)
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                .padding(16)
            }
        }
        .background(AppColor.cardBackground)
        .cornerRadius(12)
    }

    /// CSV 내보내기 실행
    private func exportCSV() {
        let descriptor = FetchDescriptor<TransactionRecord>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        do {
            let records = try modelContext.fetch(descriptor)
            if let url = viewModel.exportCSV(records: records) {
                viewModel.csvFileURL = url
                viewModel.showingShareSheet = true
            }
        } catch {
            viewModel.errorMessage = "거래 기록을 불러올 수 없습니다"
        }
    }

    /// 정보 행
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(AppColor.textPrimary)
        }
        .padding(16)
    }
}

/// 공유 시트 래퍼 (UIActivityViewController)
struct ShareSheet: UIViewControllerRepresentable {
    /// 공유할 항목 배열
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
