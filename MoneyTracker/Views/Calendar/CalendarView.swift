import SwiftUI
import SwiftData

/// 캘린더 뷰 — 월간 달력 그리드, 일별 합계 표시
struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = TransactionViewModel()

    /// 표시 중인 월
    @State private var displayedMonth: Date = Date()

    /// 요일 헤더
    private let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                VStack(spacing: 16) {
                    // 월 선택
                    monthHeader

                    // 요일 헤더
                    weekdayHeader

                    // 달력 그리드
                    calendarGrid

                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("캘린더")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
        }
    }

    /// 월 선택 헤더
    private var monthHeader: some View {
        HStack {
            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(AppColor.textSecondary)
            }

            Spacer()

            Text(displayedMonth.monthYearString)
                .font(.title3.bold())
                .foregroundStyle(AppColor.textPrimary)

            Spacer()

            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
    }

    /// 요일 헤더
    private var weekdayHeader: some View {
        HStack {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    /// 달력 그리드
    private var calendarGrid: some View {
        let days = generateDays()
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
            ForEach(days, id: \.self) { day in
                if let day = day {
                    dayCell(for: day)
                } else {
                    Color.clear.frame(height: 56)
                }
            }
        }
    }

    /// 개별 날짜 셀
    private func dayCell(for date: Date) -> some View {
        let calendar = Calendar.current
        let dayNumber = calendar.component(.day, from: date)
        let isToday = calendar.isDateInToday(date)
        let total = viewModel.dailyTotal(for: date)

        return VStack(spacing: 2) {
            Text("\(dayNumber)")
                .font(.caption)
                .foregroundStyle(isToday ? AppColor.primary : AppColor.textPrimary)
                .fontWeight(isToday ? .bold : .regular)

            if total != 0 {
                Text(formatCompact(total))
                    .font(.system(size: 8))
                    .foregroundStyle(total > 0 ? AppColor.income : AppColor.expense)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(isToday ? AppColor.primary.opacity(0.15) : AppColor.cardBackground)
        .cornerRadius(8)
    }

    /// 컴팩트 금액 포맷 (만원 단위)
    private func formatCompact(_ amount: Double) -> String {
        let absAmount = abs(amount)
        let prefix = amount > 0 ? "+" : "-"
        if absAmount >= 10000 {
            return "\(prefix)\(Int(absAmount / 10000))만"
        }
        return "\(prefix)\(Int(absAmount))"
    }

    /// 해당 월의 날짜 배열 생성 (빈 칸 포함)
    private func generateDays() -> [Date?] {
        let calendar = Calendar.current
        let startOfMonth = displayedMonth.startOfMonth
        let weekday = calendar.component(.weekday, from: startOfMonth) - 1

        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth) else {
            return []
        }

        var days: [Date?] = Array(repeating: nil, count: weekday)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }

        return days
    }

    /// 월 이동
    private func moveMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }
}
