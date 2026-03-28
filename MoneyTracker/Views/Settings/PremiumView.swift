import SwiftUI

/// 프리미엄 뷰 — 혜택 소개 및 구매
struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var premiumService: PremiumService

    /// 프리미엄 혜택 목록
    private let benefits: [(icon: String, title: String, description: String)] = [
        ("infinity", "무제한 기록", "월 50건 제한 없이 무제한 거래 기록"),
        ("square.and.arrow.up", "CSV 내보내기", "거래 내역을 CSV 파일로 내보내기"),
        ("bell.badge.fill", "예산 알림", "예산 초과 시 푸시 알림 받기"),
        ("chart.bar.fill", "상세 통계", "카테고리별 심층 분석 제공"),
        ("sparkles", "광고 제거", "모든 광고 없이 깔끔한 사용")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // 헤더
                        headerSection

                        // 혜택 목록
                        benefitsSection

                        // 구매 버튼
                        purchaseSection

                        // 복원 버튼
                        restoreButton
                    }
                    .padding(20)
                }
            }
            .navigationTitle("프리미엄")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                    .foregroundStyle(AppColor.textSecondary)
                }
            }
        }
    }

    /// 헤더 섹션
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppColor.secondary)

            Text("Money Tracker Premium")
                .font(.title2.bold())
                .foregroundStyle(AppColor.textPrimary)

            Text("더 스마트한 가계부 관리")
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)
        }
        .padding(.top, 20)
    }

    /// 혜택 목록 섹션
    private var benefitsSection: some View {
        VStack(spacing: 12) {
            ForEach(benefits, id: \.title) { benefit in
                HStack(spacing: 14) {
                    Image(systemName: benefit.icon)
                        .font(.title3)
                        .foregroundStyle(AppColor.secondary)
                        .frame(width: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(benefit.title)
                            .font(.subheadline.bold())
                            .foregroundStyle(AppColor.textPrimary)
                        Text(benefit.description)
                            .font(.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }

                    Spacer()
                }
                .padding(14)
                .background(AppColor.cardBackground)
                .cornerRadius(10)
            }
        }
    }

    /// 구매 섹션
    private var purchaseSection: some View {
        VStack(spacing: 8) {
            if premiumService.isPremium {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColor.primary)
                    Text("프리미엄 활성화됨")
                        .font(.headline)
                        .foregroundStyle(AppColor.primary)
                }
                .padding(.vertical, 16)
            } else {
                Button {
                    Task {
                        await premiumService.purchase()
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text("월 \(PremiumService.monthlyPrice)")
                            .font(.title3.bold())
                        Text("프리미엄 시작하기")
                            .font(.subheadline)
                    }
                    .foregroundStyle(AppColor.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [AppColor.secondary, AppColor.primary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                }
                .disabled(premiumService.isPurchasing)
                .opacity(premiumService.isPurchasing ? 0.6 : 1.0)
            }

            if let error = premiumService.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(AppColor.expense)
            }
        }
    }

    /// 복원 버튼
    private var restoreButton: some View {
        Button {
            Task {
                await premiumService.restore()
            }
        } label: {
            Text("구매 복원")
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)
        }
    }
}
