import StoreKit

@Observable
final class SubscriptionManager {
    var isPro: Bool = false
    var products: [Product] = []

    private static let productIDs = ["tippy_pro_monthly", "tippy_pro_annual"]

    init() {
        Task {
            await checkSubscriptionStatus()
            await loadProducts()
            listenForTransactions()
        }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: Self.productIDs)
                .sorted { $0.price < $1.price }
        } catch {
            // Products unavailable — not fatal
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    isPro = true
                case .unverified:
                    break
                }
            case .pending, .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            // Purchase failed — not fatal
        }
    }

    func checkSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if Self.productIDs.contains(transaction.productID) && !transaction.isExpired {
                    isPro = true
                    return
                }
            }
        }
        isPro = false
    }

    func restorePurchases() async {
        await checkSubscriptionStatus()
    }

    private func listenForTransactions() {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await MainActor.run {
                        if Self.productIDs.contains(transaction.productID) && !transaction.isExpired {
                            self?.isPro = true
                        }
                    }
                }
            }
        }
    }
}

private extension Transaction {
    var isExpired: Bool {
        if let expirationDate {
            return expirationDate < Date()
        }
        return false
    }
}
