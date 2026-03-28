import SwiftUI

/// 거래 카테고리 열거형
enum TransactionCategory: String, Codable, CaseIterable, Identifiable {
    // 지출 카테고리
    case food = "food"
    case transport = "transport"
    case shopping = "shopping"
    case culture = "culture"
    case medical = "medical"
    case education = "education"
    case housing = "housing"
    // 수입 카테고리
    case salary = "salary"
    case sidejob = "sidejob"
    // 공통
    case other = "other"

    var id: String { rawValue }

    /// 한국어 표시 이름
    var displayName: String {
        switch self {
        case .food: return "식비"
        case .transport: return "교통"
        case .shopping: return "쇼핑"
        case .culture: return "문화"
        case .medical: return "의료"
        case .education: return "교육"
        case .housing: return "주거"
        case .salary: return "급여"
        case .sidejob: return "부수입"
        case .other: return "기타"
        }
    }

    /// SF Symbol 아이콘 이름
    var iconName: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .shopping: return "bag.fill"
        case .culture: return "theatermasks.fill"
        case .medical: return "cross.case.fill"
        case .education: return "book.fill"
        case .housing: return "house.fill"
        case .salary: return "banknote.fill"
        case .sidejob: return "briefcase.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    /// 카테고리 색상
    var color: Color {
        switch self {
        case .food: return Color(hex: "#E17055")
        case .transport: return Color(hex: "#0984E3")
        case .shopping: return Color(hex: "#FDCB6E")
        case .culture: return Color(hex: "#A29BFE")
        case .medical: return Color(hex: "#FF7675")
        case .education: return Color(hex: "#74B9FF")
        case .housing: return Color(hex: "#55EFC4")
        case .salary: return Color(hex: "#00B894")
        case .sidejob: return Color(hex: "#00CEC9")
        case .other: return Color(hex: "#636E72")
        }
    }

    /// 지출용 카테고리 목록
    static var expenseCategories: [TransactionCategory] {
        [.food, .transport, .shopping, .culture, .medical, .education, .housing, .other]
    }

    /// 수입용 카테고리 목록
    static var incomeCategories: [TransactionCategory] {
        [.salary, .sidejob, .other]
    }
}
