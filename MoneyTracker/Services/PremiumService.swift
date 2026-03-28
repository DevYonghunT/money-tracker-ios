import Foundation
import StoreKit
import os

/// 프리미엄 구독 관리 서비스 (StoreKit 2)
@MainActor
final class PremiumService: ObservableObject {
    private nonisolated static let logger = Logger(
        subsystem: "com.entangle.moneytracker",
        category: "PremiumService"
    )

    /// 프리미엄 활성화 상태
    @Published var isPremium: Bool = false
    /// 상품 목록
    @Published var products: [Product] = []
    /// 구매 진행 중 여부
    @Published var isPurchasing: Bool = false
    /// 초기 로딩 중 여부
    @Published var isLoading: Bool = true
    /// 에러 메시지
    @Published var errorMessage: String?

    /// 월간 구독 상품 ID
    static let monthlyProductID = "com.entangle.moneytracker.premium.monthly"
    /// 월간 구독 가격
    static let monthlyPrice = "$1.99"

    /// 거래 업데이트 리스너 태스크
    private var updateListenerTask: Task<Void, Never>?

    /// 프리미엄 상태 객체
    var premiumStatus: PremiumStatus {
        PremiumStatus(isActive: isPremium)
    }

    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
            isLoading = false
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    /// 상품 정보 로드
    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: [PremiumService.monthlyProductID])
            products = storeProducts
        } catch {
            errorMessage = "상품 정보를 불러올 수 없습니다"
        }
    }

    /// 구매 처리
    func purchase() async {
        guard let product = products.first else {
            errorMessage = "상품을 찾을 수 없습니다"
            return
        }

        isPurchasing = true
        errorMessage = nil

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await updatePurchasedProducts()
                    isPremium = true
                case .unverified(let transaction, let error):
                    await transaction.finish()
                    errorMessage = "구매 검증 실패. 잠시 후 다시 시도해주세요."
                    Self.logger.error("구매 거래 검증 실패: \(error.localizedDescription)")
                }
            case .userCancelled:
                break
            case .pending:
                errorMessage = "구매 승인 대기 중입니다"
            @unknown default:
                errorMessage = "알 수 없는 구매 결과입니다"
            }
        } catch {
            errorMessage = "구매에 실패했습니다: \(error.localizedDescription)"
        }

        isPurchasing = false
    }

    /// 구매 복원
    func restore() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            errorMessage = "복원에 실패했습니다"
        }
    }

    /// 구매 상태 업데이트
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if transaction.productID == PremiumService.monthlyProductID {
                    isPremium = transaction.revocationDate == nil
                }
            case .unverified(let transaction, let error):
                await transaction.finish()
                Self.logger.error("구독 상태 확인 중 거래 검증 실패: \(error.localizedDescription)")
            }
        }
    }

    /// 거래 검증
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    /// 거래 업데이트 리스너
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                try? Task.checkCancellation()
                guard !Task.isCancelled else { break }
                guard let self = self else { break }
                switch result {
                case .verified(let transaction):
                    await transaction.finish()
                    await self.updatePurchasedProducts()
                case .unverified(let transaction, let error):
                    await transaction.finish()
                    Self.logger.error("거래 검증 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}

/// StoreKit 에러 정의
enum StoreError: Error {
    case failedVerification
}
