import Foundation

/// 설정 뷰모델 — 프리미엄 및 앱 정보
@MainActor
final class SettingsViewModel: ObservableObject {
    /// 프리미엄 뷰 표시 여부
    @Published var showingPremiumView: Bool = false
    /// CSV 공유 시트 표시 여부
    @Published var showingShareSheet: Bool = false
    /// 생성된 CSV 파일 URL
    @Published var csvFileURL: URL?
    /// 에러 메시지
    @Published var errorMessage: String?

    /// 앱 버전
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    /// 앱 이름
    var appName: String {
        return "Money Tracker"
    }

    /// 개발팀
    var teamName: String {
        return "Team Entangle"
    }

    /// CSV 내보내기 — 거래 기록을 CSV 파일로 생성
    /// - Parameter records: 내보낼 거래 기록 배열
    /// - Returns: 생성된 CSV 파일의 URL, 실패 시 nil
    func exportCSV(records: [TransactionRecord]) -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        var csvContent = "날짜,유형,카테고리,금액,메모\n"

        for record in records {
            let dateString = dateFormatter.string(from: record.date)
            let typeString = record.type.displayName
            let categoryString = record.category.displayName
            let amountString = String(format: "%.0f", record.amount)
            // 메모에 쉼표나 줄바꿈이 포함될 수 있으므로 따옴표로 감싸기
            let escapedNote = record.note
                .replacingOccurrences(of: "\"", with: "\"\"")
            let noteString = "\"\(escapedNote)\""

            csvContent += "\(dateString),\(typeString),\(categoryString),\(amountString),\(noteString)\n"
        }

        let fileName = "MoneyTracker_\(Date().monthYearString).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            errorMessage = "CSV 파일 생성에 실패했습니다: \(error.localizedDescription)"
            return nil
        }
    }
}
