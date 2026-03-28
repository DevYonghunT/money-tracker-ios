import Foundation

/// 프리미엄 상태 모델
struct PremiumStatus {
    /// 프리미엄 활성화 여부
    var isActive: Bool

    /// 무료 사용자 월간 기록 제한
    static let freeMonthlyLimit = 50

    /// 거래 기록 가능 여부 확인
    /// - Parameter currentMonthCount: 현재 월 기록 수
    /// - Returns: 기록 가능 여부
    func canRecord(currentMonthCount: Int) -> Bool {
        if isActive { return true }
        return currentMonthCount < PremiumStatus.freeMonthlyLimit
    }

    /// CSV 내보내기 가능 여부
    var canExportCSV: Bool {
        return isActive
    }

    /// 예산 알림 설정 가능 여부
    var canSetBudgetAlert: Bool {
        return isActive
    }
}
