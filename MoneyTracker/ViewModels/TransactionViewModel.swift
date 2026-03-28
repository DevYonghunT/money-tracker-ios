import Foundation
import SwiftData
import SwiftUI

/// 거래 기록 뷰모델 — CRUD 및 필터링
@MainActor
final class TransactionViewModel: ObservableObject {
    /// 선택된 월 (필터링 기준)
    @Published var selectedMonth: Date = Date()
    /// 검색어
    @Published var searchText: String = ""
    /// 에러 메시지
    @Published var errorMessage: String?

    /// 모델 컨텍스트
    private var modelContext: ModelContext?

    /// 모델 컨텍스트 설정
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    /// 전체 거래 기록 조회
    func fetchAllTransactions() -> [TransactionRecord] {
        guard let modelContext = modelContext else { return [] }
        let descriptor = FetchDescriptor<TransactionRecord>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "거래 기록을 불러올 수 없습니다: \(error.localizedDescription)"
            return []
        }
    }

    /// 선택된 월의 거래 기록 조회
    func fetchMonthlyTransactions() -> [TransactionRecord] {
        let all = fetchAllTransactions()
        return all.filter { $0.date.isSameMonth(as: selectedMonth) }
    }

    /// 현재 월 거래 수
    func currentMonthTransactionCount() -> Int {
        let all = fetchAllTransactions()
        let now = Date()
        return all.filter { $0.date.isSameMonth(as: now) }.count
    }

    /// 날짜별 그룹핑된 거래 기록
    func groupedTransactions() -> [(date: Date, transactions: [TransactionRecord])] {
        let transactions = fetchMonthlyTransactions()
        let grouped = Dictionary(grouping: transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
        return grouped.map { (date: $0.key, transactions: $0.value) }
            .sorted { $0.date > $1.date }
    }

    /// 총 수입 (선택된 월)
    func totalIncome() -> Double {
        fetchMonthlyTransactions()
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }

    /// 총 지출 (선택된 월)
    func totalExpense() -> Double {
        fetchMonthlyTransactions()
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    /// 잔액 (수입 - 지출)
    func balance() -> Double {
        totalIncome() - totalExpense()
    }

    /// 특정 날짜의 총 금액 (수입 - 지출)
    func dailyTotal(for date: Date) -> Double {
        let all = fetchAllTransactions()
        let dayTransactions = all.filter { $0.date.isSameDay(as: date) }
        let income = dayTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let expense = dayTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        return income - expense
    }

    /// 거래 기록 추가
    /// - Parameters:
    ///   - amount: 금액
    ///   - type: 거래 유형
    ///   - category: 카테고리
    ///   - note: 메모
    ///   - date: 거래 날짜
    func addTransaction(
        amount: Double,
        type: TransactionType,
        category: TransactionCategory,
        note: String,
        date: Date
    ) {
        guard let modelContext = modelContext else { return }
        let transaction = TransactionRecord(
            amount: amount,
            type: type,
            category: category,
            note: note,
            date: date
        )
        modelContext.insert(transaction)
        do {
            try modelContext.save()
        } catch {
            errorMessage = "거래 기록 저장에 실패했습니다: \(error.localizedDescription)"
        }
        objectWillChange.send()
    }

    /// 거래 기록 삭제
    /// - Parameter transaction: 삭제할 거래 기록
    func deleteTransaction(_ transaction: TransactionRecord) {
        guard let modelContext = modelContext else { return }
        modelContext.delete(transaction)
        do {
            try modelContext.save()
        } catch {
            errorMessage = "거래 기록 삭제에 실패했습니다: \(error.localizedDescription)"
        }
        objectWillChange.send()
    }

    /// 이전 월로 이동
    func goToPreviousMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
    }

    /// 다음 월로 이동
    func goToNextMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
    }
}
