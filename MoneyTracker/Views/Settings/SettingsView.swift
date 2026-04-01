import SwiftUI
import SwiftData

/// 설정 뷰 — 데이터 관리, 앱 정보
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
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
            .sheet(isPresented: $viewModel.showingShareSheet) {
                if let url = viewModel.csvFileURL {
                    ShareSheet(items: [url])
                }
            }
        }
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
                exportCSV()
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                        .foregroundStyle(AppColor.secondary)

                    Text("CSV 내보내기")
                        .font(.subheadline.bold())
                        .foregroundStyle(AppColor.textPrimary)

                    Spacer()

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
