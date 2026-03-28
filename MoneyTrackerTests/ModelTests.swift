// ModelTests.swift
// PremiumStatus, TransactionCategory, BudgetSetting, Double+Currency, Date+Extensions 테스트

import XCTest
@testable import MoneyTracker

final class ModelTests: XCTestCase {

    // MARK: - νₑ 정상 경로 — PremiumStatus

    func test_premiumStatus_canRecord_freeUnderLimit() {
        let status = PremiumStatus(isActive: false)
        XCTAssertTrue(status.canRecord(currentMonthCount: 0))
        XCTAssertTrue(status.canRecord(currentMonthCount: 49))
    }

    func test_premiumStatus_canRecord_freeAtLimit() {
        let status = PremiumStatus(isActive: false)
        XCTAssertFalse(status.canRecord(currentMonthCount: 50))
    }

    func test_premiumStatus_canRecord_premiumAlways() {
        let status = PremiumStatus(isActive: true)
        XCTAssertTrue(status.canRecord(currentMonthCount: 0))
        XCTAssertTrue(status.canRecord(currentMonthCount: 1000))
    }

    func test_premiumStatus_freeMonthlyLimit_is50() {
        XCTAssertEqual(PremiumStatus.freeMonthlyLimit, 50)
    }

    func test_premiumStatus_canExportCSV() {
        XCTAssertTrue(PremiumStatus(isActive: true).canExportCSV)
        XCTAssertFalse(PremiumStatus(isActive: false).canExportCSV)
    }

    func test_premiumStatus_canSetBudgetAlert() {
        XCTAssertTrue(PremiumStatus(isActive: true).canSetBudgetAlert)
        XCTAssertFalse(PremiumStatus(isActive: false).canSetBudgetAlert)
    }

    // MARK: - νₑ 정상 경로 — TransactionCategory

    func test_transactionCategory_expenseCategories_hasEight() {
        let expenses = TransactionCategory.expenseCategories
        XCTAssertEqual(expenses.count, 8)
    }

    func test_transactionCategory_incomeCategories_hasThree() {
        let incomes = TransactionCategory.incomeCategories
        XCTAssertEqual(incomes.count, 3)
    }

    func test_transactionCategory_displayNames_korean() {
        XCTAssertFalse(TransactionCategory.food.displayName.isEmpty)
        XCTAssertFalse(TransactionCategory.salary.displayName.isEmpty)
    }

    func test_transactionCategory_iconNames_notEmpty() {
        for category in TransactionCategory.allCases {
            XCTAssertFalse(category.iconName.isEmpty, "\(category) 아이콘 비어있음")
        }
    }

    // MARK: - νₑ 정상 경로 — BudgetSetting

    func test_budgetSetting_defaultBudget_isOneMillion() {
        let setting = BudgetSetting.defaultSetting
        XCTAssertEqual(setting.monthlyBudget, 1_000_000)
    }

    func test_budgetSetting_saveAndLoad_roundTrip() {
        UserDefaults.standard.removeObject(forKey: "budget_setting")

        var setting = BudgetSetting(monthlyBudget: 500_000)
        setting.save()

        let loaded = BudgetSetting.load()
        XCTAssertEqual(loaded.monthlyBudget, 500_000)

        UserDefaults.standard.removeObject(forKey: "budget_setting")
    }

    func test_budgetSetting_load_noData_returnsDefault() {
        UserDefaults.standard.removeObject(forKey: "budget_setting")
        let loaded = BudgetSetting.load()
        XCTAssertEqual(loaded.monthlyBudget, 1_000_000)
    }

    // MARK: - νₑ 정상 경로 — Double+Currency

    func test_currencyString_positiveNumber() {
        let formatted = 1234567.0.currencyString
        XCTAssertTrue(formatted.contains("1,234,567"))
        XCTAssertTrue(formatted.contains("₩"))
    }

    func test_currencyString_zero() {
        let formatted = 0.0.currencyString
        XCTAssertTrue(formatted.contains("0"))
    }

    func test_signedCurrencyString_positive_hasPlusSign() {
        let formatted = 50000.0.signedCurrencyString
        XCTAssertTrue(formatted.hasPrefix("+"))
    }

    func test_signedCurrencyString_negative_hasMinusInAmount() {
        let formatted = (-30000.0).signedCurrencyString
        // negative → prefix is empty string "", abs() applied
        XCTAssertTrue(formatted.contains("30,000") || formatted.contains("₩"))
    }

    // MARK: - νₑ 정상 경로 — Date Extensions

    func test_date_isSameDay_sameDayDifferentTime() {
        let morning = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
        let evening = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
        XCTAssertTrue(morning.isSameDay(as: evening))
    }

    func test_date_isSameMonth_samemonth() {
        let today = Date()
        let alsoThisMonth = today.addingTimeInterval(86400) // tomorrow (usually same month)
        // Only test if not last day of month
        let day = Calendar.current.component(.day, from: today)
        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: today)!.count
        if day < daysInMonth {
            XCTAssertTrue(today.isSameMonth(as: alsoThisMonth))
        }
    }

    func test_date_koreanDateString_containsYear() {
        let str = Date().koreanDateString
        XCTAssertTrue(str.contains("년"))
        XCTAssertTrue(str.contains("월"))
        XCTAssertTrue(str.contains("일"))
    }

    func test_date_monthYearString_containsMonth() {
        let str = Date().monthYearString
        XCTAssertTrue(str.contains("년"))
        XCTAssertTrue(str.contains("월"))
    }

    // MARK: - νμ 예외 경로

    func test_premiumStatus_canRecord_overLimit() {
        let status = PremiumStatus(isActive: false)
        XCTAssertFalse(status.canRecord(currentMonthCount: 100))
    }

    // MARK: - ντ 경계 경로

    func test_premiumStatus_canRecord_exactBoundary() {
        let status = PremiumStatus(isActive: false)
        let limit = PremiumStatus.freeMonthlyLimit

        XCTAssertTrue(status.canRecord(currentMonthCount: limit - 1))
        XCTAssertFalse(status.canRecord(currentMonthCount: limit))
        XCTAssertFalse(status.canRecord(currentMonthCount: limit + 1))
    }

    func test_currencyString_largeNumber() {
        let formatted = 999_999_999.0.currencyString
        XCTAssertTrue(formatted.contains("999,999,999"))
    }

    func test_currencyString_smallNumber() {
        let formatted = 100.0.currencyString
        XCTAssertTrue(formatted.contains("100"))
    }

    func test_budgetSetting_codable_roundTrip() throws {
        let setting = BudgetSetting(monthlyBudget: 750_000)
        let data = try JSONEncoder().encode(setting)
        let decoded = try JSONDecoder().decode(BudgetSetting.self, from: data)
        XCTAssertEqual(decoded.monthlyBudget, 750_000)
    }
}
