import Foundation
import UserNotifications

/// 알림 서비스 — 예산 초과 알림 관리
final class NotificationService {
    /// 알림 카테고리 식별자
    static let budgetExceededCategory = "BUDGET_EXCEEDED"

    /// 알림 권한 요청
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            return false
        }
    }

    /// 예산 초과 알림 전송
    /// - Parameters:
    ///   - spent: 현재 지출 금액
    ///   - budget: 설정된 예산 금액
    func sendBudgetExceededNotification(spent: Double, budget: Double) {
        let content = UNMutableNotificationContent()
        content.title = "예산 초과 알림 💸"
        content.body = "이번 달 지출(\(spent.currencyString))이 예산(\(budget.currencyString))을 초과했습니다."
        content.sound = .default
        content.categoryIdentifier = NotificationService.budgetExceededCategory

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    /// 예산 경고 알림 전송 (90% 도달 시)
    /// - Parameters:
    ///   - spent: 현재 지출 금액
    ///   - budget: 설정된 예산 금액
    func sendBudgetWarningNotification(spent: Double, budget: Double) {
        let percentage = Int((spent / budget) * 100)
        let content = UNMutableNotificationContent()
        content.title = "예산 경고 ⚠️"
        content.body = "이번 달 예산의 \(percentage)%를 사용했습니다. (\(spent.currencyString)/\(budget.currencyString))"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
