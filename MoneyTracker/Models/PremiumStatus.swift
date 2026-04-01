import Foundation

/// 프리미엄 상태 모델 — 모든 기능 무료 해제
struct PremiumStatus {
    /// 프리미엄 활성화 여부 (항상 true)
    var isActive: Bool = true

    /// 무료 사용자 월간 기록 제한 (더 이상 사용하지 않지만 호환성 유지)
    static let freeMonthlyLimit = 50

    /// 거래 기록 가능 여부 — 항상 허용
    func canRecord(currentMonthCount: Int) -> Bool {
        return true
    }

    /// CSV 내보내기 가능 여부 — 항상 허용
    var canExportCSV: Bool {
        return true
    }

    /// 예산 알림 설정 가능 여부 — 항상 허용
    var canSetBudgetAlert: Bool {
        return true
    }
}
