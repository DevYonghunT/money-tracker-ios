import Foundation

/// Date 확장 — 날짜 포맷팅 및 유틸리티
extension Date {
    /// "yyyy년 MM월 dd일" 형식 문자열
    var koreanDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: self)
    }

    /// "MM/dd" 형식 짧은 날짜 문자열
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: self)
    }

    /// "yyyy년 MM월" 형식 월 문자열
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월"
        return formatter.string(from: self)
    }

    /// 해당 월의 시작일
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    /// 해당 월의 마지막 날
    var endOfMonth: Date {
        let calendar = Calendar.current
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return self
        }
        return calendar.date(byAdding: .day, value: -1, to: nextMonth) ?? self
    }

    /// 해당 주의 시작일 (월요일 기준)
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    /// 같은 날인지 확인
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    /// 같은 월인지 확인
    func isSameMonth(as other: Date) -> Bool {
        let calendar = Calendar.current
        let selfComponents = calendar.dateComponents([.year, .month], from: self)
        let otherComponents = calendar.dateComponents([.year, .month], from: other)
        return selfComponents.year == otherComponents.year && selfComponents.month == otherComponents.month
    }
}
