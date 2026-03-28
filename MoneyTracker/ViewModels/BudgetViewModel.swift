import Foundation
import SwiftData

/// 예산 뷰모델 — 예산 설정 및 현황 관리
@MainActor
final class BudgetViewModel: ObservableObject {
    /// 예산 설정
    @Published var budgetSetting: BudgetSetting
    /// 예산 설정 시트 표시 여부
    @Published var showingBudgetSheet: Bool = false
    /// 예산 입력값 (문자열)
    @Published var budgetInputText: String = ""
    /// 에러 메시지
    @Published var errorMessage: String?

    /// 알림 서비스
    private let notificationService = NotificationService()
    /// 모델 컨텍스트
    private var modelContext: ModelContext?

    init() {
        self.budgetSetting = BudgetSetting.load()
        self.budgetInputText = String(Int(budgetSetting.monthlyBudget))
    }

    /// 모델 컨텍스트 설정
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    /// 월별 예산 금액
    var monthlyBudget: Double {
        budgetSetting.monthlyBudget
    }

    /// 현재 월 총 지출
    func currentMonthExpense() -> Double {
        guard let modelContext = modelContext else { return 0 }
        let descriptor = FetchDescriptor<TransactionRecord>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let all: [TransactionRecord]
        do {
            all = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = "지출 내역을 불러올 수 없습니다: \(error.localizedDescription)"
            return 0
        }
        let now = Date()
        return all
            .filter { $0.type == .expense && $0.date.isSameMonth(as: now) }
            .reduce(0) { $0 + $1.amount }
    }

    /// 예산 사용 비율 (0.0 ~ 1.0+)
    func spendingPercentage() -> Double {
        guard monthlyBudget > 0 else { return 0 }
        return currentMonthExpense() / monthlyBudget
    }

    /// 남은 예산
    func remainingBudget() -> Double {
        monthlyBudget - currentMonthExpense()
    }

    /// 예산 초과 여부
    func isOverBudget() -> Bool {
        currentMonthExpense() > monthlyBudget
    }

    /// 예산 저장
    func saveBudget() {
        guard let amount = Double(budgetInputText), amount > 0 else { return }
        budgetSetting = BudgetSetting(monthlyBudget: amount)
        budgetSetting.save()
        showingBudgetSheet = false
    }

    /// 예산 초과 확인 및 알림 전송
    func checkBudgetAlert() {
        let spent = currentMonthExpense()
        let budget = monthlyBudget
        guard budget > 0 else { return }

        let ratio = spent / budget
        if ratio >= 1.0 {
            notificationService.sendBudgetExceededNotification(spent: spent, budget: budget)
        } else if ratio >= 0.9 {
            notificationService.sendBudgetWarningNotification(spent: spent, budget: budget)
        }
    }

    /// 예산 설정 시트 열기
    func openBudgetSheet() {
        budgetInputText = String(Int(monthlyBudget))
        showingBudgetSheet = true
    }
}
