import SwiftUI
import SwiftData

/// 예산 뷰 — 원형 프로그레스, 예산 설정, 알림
struct BudgetView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var premiumService: PremiumService
    @StateObject private var viewModel = BudgetViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // 원형 프로그레스 링
                        progressRing

                        // 예산 상세
                        budgetDetails

                        // 예산 설정 버튼
                        setBudgetButton
                    }
                    .padding(16)
                }
            }
            .navigationTitle("예산")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $viewModel.showingBudgetSheet) {
                budgetSettingSheet
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
        }
    }

    /// 원형 프로그레스 링
    private var progressRing: some View {
        let percentage = viewModel.spendingPercentage()
        let displayPercentage = min(percentage, 1.0)
        let isOver = viewModel.isOverBudget()

        return ZStack {
            // 배경 원
            Circle()
                .stroke(AppColor.cardBackground, lineWidth: 20)
                .frame(width: 200, height: 200)

            // 프로그레스
            Circle()
                .trim(from: 0, to: displayPercentage)
                .stroke(
                    isOver ? AppColor.expense : AppColor.primary,
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: displayPercentage)

            // 중앙 텍스트
            VStack(spacing: 4) {
                Text("\(Int(percentage * 100))%")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(isOver ? AppColor.expense : AppColor.primary)
                Text("사용")
                    .font(.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(.top, 20)
    }

    /// 예산 상세 정보
    private var budgetDetails: some View {
        VStack(spacing: 16) {
            detailRow(title: "월 예산", amount: viewModel.monthlyBudget, color: AppColor.secondary)
            detailRow(title: "현재 지출", amount: viewModel.currentMonthExpense(), color: AppColor.expense)

            Divider().background(AppColor.textSecondary)

            let remaining = viewModel.remainingBudget()
            detailRow(
                title: remaining >= 0 ? "남은 예산" : "초과 금액",
                amount: abs(remaining),
                color: remaining >= 0 ? AppColor.income : AppColor.expense
            )
        }
        .padding(20)
        .background(AppColor.cardBackground)
        .cornerRadius(16)
    }

    /// 상세 행
    private func detailRow(title: String, amount: Double, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)
            Spacer()
            Text(amount.currencyString)
                .font(.headline)
                .foregroundStyle(color)
        }
    }

    /// 예산 설정 버튼
    private var setBudgetButton: some View {
        Button {
            viewModel.openBudgetSheet()
        } label: {
            HStack {
                Image(systemName: "slider.horizontal.3")
                Text("예산 설정")
            }
            .font(.headline)
            .foregroundStyle(AppColor.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppColor.primary)
            .cornerRadius(14)
        }
    }

    /// 예산 설정 시트
    private var budgetSettingSheet: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("월별 예산을 설정하세요")
                        .font(.headline)
                        .foregroundStyle(AppColor.textPrimary)

                    HStack {
                        Text("₩")
                            .font(.title)
                            .foregroundStyle(AppColor.primary)
                        TextField("금액", text: $viewModel.budgetInputText)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(AppColor.textPrimary)
                            .keyboardType(.numberPad)
                    }
                    .padding(16)
                    .background(AppColor.cardBackground)
                    .cornerRadius(12)

                    // 빠른 선택 버튼
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                        ForEach([500_000, 1_000_000, 1_500_000, 2_000_000, 3_000_000, 5_000_000], id: \.self) { amount in
                            Button {
                                viewModel.budgetInputText = String(amount)
                            } label: {
                                Text(Double(amount).currencyString)
                                    .font(.caption)
                                    .foregroundStyle(AppColor.textPrimary)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(AppColor.secondaryBackground)
                                    .cornerRadius(8)
                            }
                        }
                    }

                    Button {
                        viewModel.saveBudget()
                    } label: {
                        Text("저장")
                            .font(.headline)
                            .foregroundStyle(AppColor.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColor.primary)
                            .cornerRadius(14)
                    }

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("예산 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        viewModel.showingBudgetSheet = false
                    }
                    .foregroundStyle(AppColor.textSecondary)
                }
            }
        }
    }
}
