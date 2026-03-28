import Foundation
import SwiftData

/// 거래 유형 (수입/지출)
enum TransactionType: String, Codable, CaseIterable {
    case income = "income"
    case expense = "expense"

    /// 한국어 표시 이름
    var displayName: String {
        switch self {
        case .income: return "수입"
        case .expense: return "지출"
        }
    }
}

/// 거래 기록 모델 (SwiftData)
@Model
final class TransactionRecord {
    /// 고유 식별자
    var id: UUID
    /// 금액
    var amount: Double
    /// 거래 유형 (수입/지출)
    var typeRawValue: String
    /// 카테고리 원시값
    var categoryRawValue: String
    /// 메모
    var note: String
    /// 거래 날짜
    var date: Date
    /// 생성 시각
    var createdAt: Date

    /// 거래 유형 계산 프로퍼티
    var type: TransactionType {
        get { TransactionType(rawValue: typeRawValue) ?? .expense }
        set { typeRawValue = newValue.rawValue }
    }

    /// 카테고리 계산 프로퍼티
    var category: TransactionCategory {
        get { TransactionCategory(rawValue: categoryRawValue) ?? .other }
        set { categoryRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        amount: Double,
        type: TransactionType,
        category: TransactionCategory,
        note: String = "",
        date: Date = Date(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.typeRawValue = type.rawValue
        self.categoryRawValue = category.rawValue
        self.note = note
        self.date = date
        self.createdAt = createdAt
    }
}
