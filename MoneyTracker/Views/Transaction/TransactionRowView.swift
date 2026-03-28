import SwiftUI

/// 개별 거래 행 뷰 — 아이콘, 카테고리, 금액, 날짜 표시
struct TransactionRowView: View {
    /// 거래 기록
    let transaction: TransactionRecord

    /// 금액 색상 (수입: 녹색, 지출: 빨간색)
    private var amountColor: Color {
        transaction.type == .income ? AppColor.income : AppColor.expense
    }

    /// 부호 포함 금액 문자열
    private var amountString: String {
        let prefix = transaction.type == .income ? "+" : "-"
        return "\(prefix)\(transaction.amount.currencyString)"
    }

    var body: some View {
        HStack(spacing: 12) {
            // 카테고리 아이콘
            Image(systemName: transaction.category.iconName)
                .font(.title3)
                .foregroundStyle(transaction.category.color)
                .frame(width: 40, height: 40)
                .background(transaction.category.color.opacity(0.15))
                .cornerRadius(10)

            // 카테고리명 + 메모
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category.displayName)
                    .font(.subheadline.bold())
                    .foregroundStyle(AppColor.textPrimary)

                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.caption)
                        .foregroundStyle(AppColor.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // 금액 + 날짜
            VStack(alignment: .trailing, spacing: 2) {
                Text(amountString)
                    .font(.subheadline.bold())
                    .foregroundStyle(amountColor)

                Text(transaction.date.shortDateString)
                    .font(.caption2)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppColor.secondaryBackground)
    }
}
