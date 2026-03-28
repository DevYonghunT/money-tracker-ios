import SwiftUI
import SwiftData

/// 거래 기록 목록 뷰 — 날짜별 그룹핑, 추가/삭제
struct TransactionListView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var premiumService: PremiumService
    @StateObject private var viewModel = TransactionViewModel()

    /// 거래 추가 시트 표시 여부
    @State private var showingAddSheet: Bool = false
    /// 프리미엄 필요 알림 표시 여부
    @State private var showingPremiumAlert: Bool = false
    /// 삭제 확인 알림 표시 여부
    @State private var showDeleteAlert: Bool = false
    /// 삭제 대상 거래 기록
    @State private var transactionToDelete: TransactionRecord?

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // 월 선택 헤더
                    monthSelector

                    // 요약 카드
                    summaryCard

                    // 거래 목록
                    transactionList
                }
            }
            .navigationTitle("거래기록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let count = viewModel.currentMonthTransactionCount()
                        if premiumService.premiumStatus.canRecord(currentMonthCount: count) {
                            showingAddSheet = true
                        } else {
                            showingPremiumAlert = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppColor.primary)
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddTransactionView(viewModel: viewModel)
            }
            .alert("프리미엄 필요", isPresented: $showingPremiumAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text("무료 사용자는 월 \(PremiumStatus.freeMonthlyLimit)건까지 기록 가능합니다.\n프리미엄으로 업그레이드하세요!")
            }
            .alert("이 거래를 삭제하시겠습니까?", isPresented: $showDeleteAlert) {
                Button("취소", role: .cancel) {
                    transactionToDelete = nil
                }
                Button("삭제", role: .destructive) {
                    if let transaction = transactionToDelete {
                        viewModel.deleteTransaction(transaction)
                        transactionToDelete = nil
                    }
                }
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
        }
    }

    /// 월 선택 헤더
    private var monthSelector: some View {
        HStack {
            Button {
                viewModel.goToPreviousMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(AppColor.textSecondary)
            }

            Spacer()

            Text(viewModel.selectedMonth.monthYearString)
                .font(.headline)
                .foregroundStyle(AppColor.textPrimary)

            Spacer()

            Button {
                viewModel.goToNextMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }

    /// 요약 카드
    private var summaryCard: some View {
        HStack(spacing: 16) {
            summaryItem(title: "수입", amount: viewModel.totalIncome(), color: AppColor.income)
            summaryItem(title: "지출", amount: viewModel.totalExpense(), color: AppColor.expense)
            summaryItem(title: "잔액", amount: viewModel.balance(), color: AppColor.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColor.cardBackground)
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    /// 요약 항목
    private func summaryItem(title: String, amount: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColor.textSecondary)
            Text(amount.currencyString)
                .font(.subheadline.bold())
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    /// 거래 목록
    private var transactionList: some View {
        let grouped = viewModel.groupedTransactions()
        return ScrollView {
            if grouped.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(grouped, id: \.date) { group in
                        Section {
                            ForEach(group.transactions, id: \.id) { transaction in
                                TransactionRowView(transaction: transaction)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            transactionToDelete = transaction
                                            showDeleteAlert = true
                                        } label: {
                                            Label("삭제", systemImage: "trash")
                                        }
                                    }
                            }
                        } header: {
                            HStack {
                                Text(group.date.koreanDateString)
                                    .font(.caption)
                                    .foregroundStyle(AppColor.textSecondary)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 4)
                        }
                    }
                }
            }
        }
    }

    /// 빈 상태 표시
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(AppColor.textSecondary)
            Text("거래 내역이 없습니다")
                .font(.headline)
                .foregroundStyle(AppColor.textSecondary)
            Text("오른쪽 상단 + 버튼으로\n새 거래를 추가해보세요")
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.top, 80)
    }
}
