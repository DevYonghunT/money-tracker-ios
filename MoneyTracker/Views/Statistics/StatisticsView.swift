import SwiftUI
import SwiftData

/// 통계 뷰 — 기간별 요약, 카테고리 분석, 월별 차트
struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = StatisticsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // 기간 선택
                        periodPicker

                        // 요약 카드
                        summaryCards

                        // 카테고리 분석
                        categoryBreakdownSection

                        // 월별 바 차트
                        monthlyBarChart
                    }
                    .padding(16)
                }
            }
            .navigationTitle("통계")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
        }
    }

    /// 기간 선택 피커
    private var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach(StatisticsPeriod.allCases, id: \.self) { period in
                Button {
                    viewModel.selectedPeriod = period
                } label: {
                    Text(period.rawValue)
                        .font(.subheadline.bold())
                        .foregroundStyle(viewModel.selectedPeriod == period ? AppColor.background : AppColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(viewModel.selectedPeriod == period ? AppColor.primary : Color.clear)
                        .cornerRadius(8)
                }
            }
        }
        .background(AppColor.cardBackground)
        .cornerRadius(8)
    }

    /// 요약 카드 (수입/지출/잔액)
    private var summaryCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                summaryCard(title: "수입", amount: viewModel.totalIncome(), color: AppColor.income, icon: "arrow.down.circle.fill")
                summaryCard(title: "지출", amount: viewModel.totalExpense(), color: AppColor.expense, icon: "arrow.up.circle.fill")
            }

            summaryCard(title: "잔액", amount: viewModel.balance(), color: AppColor.secondary, icon: "equal.circle.fill")
        }
    }

    /// 개별 요약 카드
    private func summaryCard(title: String, amount: Double, color: Color, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(AppColor.textSecondary)
                Text(amount.currencyString)
                    .font(.headline)
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer()
        }
        .padding(16)
        .background(AppColor.cardBackground)
        .cornerRadius(12)
    }

    /// 카테고리 분석 섹션
    private var categoryBreakdownSection: some View {
        let breakdown = viewModel.categoryBreakdown()
        return VStack(alignment: .leading, spacing: 12) {
            Text("카테고리별 지출")
                .font(.headline)
                .foregroundStyle(AppColor.textPrimary)

            if breakdown.isEmpty {
                Text("데이터가 없습니다")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                // 색상 막대 (파이 차트 대체)
                HStack(spacing: 2) {
                    ForEach(breakdown) { item in
                        Rectangle()
                            .fill(item.category.color)
                            .frame(height: 12)
                            .frame(maxWidth: .infinity)
                    }
                }
                .cornerRadius(6)

                // 카테고리 목록
                ForEach(breakdown) { item in
                    HStack {
                        Circle()
                            .fill(item.category.color)
                            .frame(width: 10, height: 10)
                        Image(systemName: item.category.iconName)
                            .font(.caption)
                            .foregroundStyle(item.category.color)
                        Text(item.category.displayName)
                            .font(.subheadline)
                            .foregroundStyle(AppColor.textPrimary)
                        Spacer()
                        Text("\(Int(item.percentage))%")
                            .font(.caption)
                            .foregroundStyle(AppColor.textSecondary)
                        Text(item.amount.currencyString)
                            .font(.subheadline.bold())
                            .foregroundStyle(AppColor.textPrimary)
                    }
                }
            }
        }
        .padding(16)
        .background(AppColor.cardBackground)
        .cornerRadius(12)
    }

    /// 월별 바 차트 (간단한 막대 그래프)
    private var monthlyBarChart: some View {
        let chartData = viewModel.monthlyChartData()
        let maxAmount = chartData.map { max($0.income, $0.expense) }.max() ?? 1

        return VStack(alignment: .leading, spacing: 12) {
            Text("월별 추이")
                .font(.headline)
                .foregroundStyle(AppColor.textPrimary)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(chartData) { data in
                    VStack(spacing: 4) {
                        // 수입 막대
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColor.income.opacity(0.7))
                            .frame(height: maxAmount > 0 ? CGFloat(data.income / maxAmount) * 100 : 0)

                        // 지출 막대
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColor.expense.opacity(0.7))
                            .frame(height: maxAmount > 0 ? CGFloat(data.expense / maxAmount) * 100 : 0)

                        // 월 레이블
                        Text(data.month)
                            .font(.caption2)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 220)

            // 범례
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle().fill(AppColor.income).frame(width: 8, height: 8)
                    Text("수입").font(.caption).foregroundStyle(AppColor.textSecondary)
                }
                HStack(spacing: 4) {
                    Circle().fill(AppColor.expense).frame(width: 8, height: 8)
                    Text("지출").font(.caption).foregroundStyle(AppColor.textSecondary)
                }
            }
        }
        .padding(16)
        .background(AppColor.cardBackground)
        .cornerRadius(12)
    }
}
