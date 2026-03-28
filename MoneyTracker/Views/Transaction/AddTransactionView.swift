import SwiftUI

/// 거래 추가 뷰 — 금액, 유형, 카테고리, 메모, 날짜 입력
struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TransactionViewModel

    /// 금액 입력값
    @State private var amountText: String = ""
    /// 거래 유형 (수입/지출)
    @State private var transactionType: TransactionType = .expense
    /// 선택된 카테고리
    @State private var selectedCategory: TransactionCategory = .food
    /// 메모
    @State private var note: String = ""
    /// 거래 날짜
    @State private var date: Date = Date()

    /// 현재 유형에 맞는 카테고리 목록
    private var availableCategories: [TransactionCategory] {
        switch transactionType {
        case .expense: return TransactionCategory.expenseCategories
        case .income: return TransactionCategory.incomeCategories
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // 금액 입력
                        amountInput

                        // 유형 선택 토글
                        typeToggle

                        // 카테고리 선택
                        categoryPicker

                        // 메모 입력
                        noteInput

                        // 날짜 선택
                        datePicker

                        // 저장 버튼
                        saveButton
                    }
                    .padding(20)
                }
            }
            .navigationTitle("거래 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundStyle(AppColor.textSecondary)
                }
            }
            .onChange(of: transactionType) { _, _ in
                // 유형 변경 시 카테고리 초기화
                selectedCategory = availableCategories.first ?? .other
            }
        }
    }

    /// 금액 입력 섹션
    private var amountInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("금액")
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)

            HStack {
                Text("₩")
                    .font(.title)
                    .foregroundStyle(AppColor.primary)
                TextField("0", text: $amountText)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(AppColor.textPrimary)
                    .keyboardType(.numberPad)
            }
            .padding(16)
            .background(AppColor.cardBackground)
            .cornerRadius(12)
        }
    }

    /// 유형 선택 토글
    private var typeToggle: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("유형")
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)

            HStack(spacing: 0) {
                ForEach(TransactionType.allCases, id: \.self) { type in
                    Button {
                        transactionType = type
                    } label: {
                        Text(type.displayName)
                            .font(.headline)
                            .foregroundStyle(transactionType == type ? AppColor.background : AppColor.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(transactionType == type ? typeColor(type) : Color.clear)
                            .cornerRadius(10)
                    }
                }
            }
            .background(AppColor.cardBackground)
            .cornerRadius(10)
        }
    }

    /// 유형별 색상 반환
    private func typeColor(_ type: TransactionType) -> Color {
        switch type {
        case .income: return AppColor.income
        case .expense: return AppColor.expense
        }
    }

    /// 카테고리 선택 그리드
    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("카테고리")
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                ForEach(availableCategories) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: category.iconName)
                                .font(.title3)
                                .foregroundStyle(selectedCategory == category ? AppColor.background : category.color)
                            Text(category.displayName)
                                .font(.caption2)
                                .foregroundStyle(selectedCategory == category ? AppColor.background : AppColor.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedCategory == category ? category.color : AppColor.cardBackground)
                        .cornerRadius(10)
                    }
                }
            }
        }
    }

    /// 메모 입력 섹션
    private var noteInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("메모")
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)

            TextField("메모를 입력하세요 (선택)", text: $note)
                .foregroundStyle(AppColor.textPrimary)
                .padding(14)
                .background(AppColor.cardBackground)
                .cornerRadius(10)
        }
    }

    /// 날짜 선택 섹션
    private var datePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("날짜")
                .font(.subheadline)
                .foregroundStyle(AppColor.textSecondary)

            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .tint(AppColor.primary)
                .padding(14)
                .background(AppColor.cardBackground)
                .cornerRadius(10)
        }
    }

    /// 저장 버튼
    private var saveButton: some View {
        Button {
            guard let amount = Double(amountText), amount > 0 else { return }
            viewModel.addTransaction(
                amount: amount,
                type: transactionType,
                category: selectedCategory,
                note: note,
                date: date
            )
            dismiss()
        } label: {
            Text("저장")
                .font(.headline)
                .foregroundStyle(AppColor.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColor.primary)
                .cornerRadius(14)
        }
        .disabled(amountText.isEmpty)
        .opacity(amountText.isEmpty ? 0.5 : 1.0)
    }
}
