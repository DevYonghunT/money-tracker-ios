import Foundation

/// Double 확장 — 통화 포맷팅
extension Double {
    /// 원화 표시 문자열 (예: "₩1,234,567")
    var currencyString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.currencySymbol = "₩"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "₩0"
    }

    /// 부호 포함 통화 문자열 (수입: +, 지출: -)
    var signedCurrencyString: String {
        let prefix = self >= 0 ? "+" : ""
        return "\(prefix)\(abs(self).currencyString)"
    }
}
