import Foundation
import SwiftData

/// 통계 기간 선택
enum StatisticsPeriod: String, CaseIterable {
    case weekly = "주간"
    case monthly = "월간"
    case yearly = "연간"
}

/// 카테고리별 통계 데이터
struct CategoryBreakdown: Identifiable {
    let id = UUID()
    let category: TransactionCategory
    let amount: Double
    let percentage: Double
}

/// 월별 차트 데이터
struct MonthlyChartData: Identifiable {
    let id = UUID()
    let month: String
    let income: Double
    let expense: Double
}

/// 통계 뷰모델 — 기간별 분석 및 차트 데이터
@MainActor
final class StatisticsViewModel: ObservableObject {
    /// 선택된 기간
    @Published var selectedPeriod: StatisticsPeriod = .monthly
    /// 선택된 기준 날짜
    @Published var selectedDate: Date = Date()

    /// 모델 컨텍스트
    private var modelContext: ModelContext?

    /// 모델 컨텍스트 설정
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    /// 전체 거래 기록 조회
    private func fetchAllTransactions() -> [TransactionRecord] {
        guard let modelContext = modelContext else { return [] }
        let descriptor = FetchDescriptor<TransactionRecord>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// 기간 내 거래 필터링
    func filteredTransactions() -> [TransactionRecord] {
        let all = fetchAllTransactions()
        let calendar = Calendar.current

        switch selectedPeriod {
        case .weekly:
            let startOfWeek = selectedDate.startOfWeek
            let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) ?? selectedDate
            return all.filter { $0.date >= startOfWeek && $0.date < endOfWeek }
        case .monthly:
            return all.filter { $0.date.isSameMonth(as: selectedDate) }
        case .yearly:
            let year = calendar.component(.year, from: selectedDate)
            return all.filter { calendar.component(.year, from: $0.date) == year }
        }
    }

    /// 총 수입
    func totalIncome() -> Double {
        filteredTransactions()
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }

    /// 총 지출
    func totalExpense() -> Double {
        filteredTransactions()
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    /// 잔액
    func balance() -> Double {
        totalIncome() - totalExpense()
    }

    /// 카테고리별 지출 분석
    func categoryBreakdown() -> [CategoryBreakdown] {
        let expenses = filteredTransactions().filter { $0.type == .expense }
        let total = expenses.reduce(0) { $0 + $1.amount }
        guard total > 0 else { return [] }

        let grouped = Dictionary(grouping: expenses) { $0.category }
        return grouped.map { category, transactions in
            let amount = transactions.reduce(0) { $0 + $1.amount }
            let percentage = (amount / total) * 100
            return CategoryBreakdown(category: category, amount: amount, percentage: percentage)
        }
        .sorted { $0.amount > $1.amount }
    }

    /// 최근 6개월 차트 데이터
    func monthlyChartData() -> [MonthlyChartData] {
        let all = fetchAllTransactions()
        let calendar = Calendar.current
        var chartData: [MonthlyChartData] = []

        for i in (0..<6).reversed() {
            guard let month = calendar.date(byAdding: .month, value: -i, to: Date()) else { continue }
            let monthTransactions = all.filter { $0.date.isSameMonth(as: month) }
            let income = monthTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
            let expense = monthTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }

            let formatter = DateFormatter()
            formatter.dateFormat = "M월"
            let monthLabel = formatter.string(from: month)

            chartData.append(MonthlyChartData(month: monthLabel, income: income, expense: expense))
        }

        return chartData
    }
}
