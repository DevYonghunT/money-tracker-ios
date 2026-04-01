import Foundation

/// 프리미엄 서비스 — 모든 기능이 무료로 해제됨
@MainActor
final class PremiumService: ObservableObject {
    /// 프리미엄 활성화 상태 (항상 true)
    @Published var isPremium: Bool = true
    /// 에러 메시지
    @Published var errorMessage: String?

    /// 프리미엄 상태 객체
    var premiumStatus: PremiumStatus {
        PremiumStatus(isActive: true)
    }

    init() {}
}
