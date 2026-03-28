import Foundation

/// 예산 설정 모델 (UserDefaults 저장용)
struct BudgetSetting: Codable {
    /// 월별 예산 금액
    var monthlyBudget: Double

    /// UserDefaults 저장 키
    static let storageKey = "budget_setting"

    /// 기본값 (100만원)
    static let defaultSetting = BudgetSetting(monthlyBudget: 1_000_000)

    /// UserDefaults에 저장
    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: BudgetSetting.storageKey)
    }

    /// UserDefaults에서 불러오기
    static func load() -> BudgetSetting {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let setting = try? JSONDecoder().decode(BudgetSetting.self, from: data) else {
            return defaultSetting
        }
        return setting
    }
}
