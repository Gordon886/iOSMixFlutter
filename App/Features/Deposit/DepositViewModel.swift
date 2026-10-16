import Combine
import Foundation

enum DepositMode: Equatable {
    case deposit
    case withdraw
}

struct DepositAmountOption: Equatable {
    let principal: String
    let bonus: String
    let fieldAmount: String
    let fieldExtra: String
    let isFeatured: Bool
}

struct DepositPromotion: Equatable {
    let title: String
    let detail: String?
}

struct DepositViewState: Equatable {
    var mode: DepositMode
    var methodIndex: Int
    var channelIndex: Int
    var amountIndex: Int
    var promotionIndex: Int
    let channels: [String]
    let amounts: [DepositAmountOption]
    let promotions: [DepositPromotion]

    var methodTitle: String {
        mode == .deposit ? "Select Deposit Method" : "Select Withdraw Method"
    }

    var actionTitle: String {
        mode == .deposit ? "Deposit" : "Withdraw"
    }

    var selectedAmount: DepositAmountOption {
        amounts[amountIndex]
    }

    static let initial = DepositViewState(
        mode: .deposit,
        methodIndex: 0,
        channelIndex: 1,
        amountIndex: 0,
        promotionIndex: 1,
        channels: ["Gcash", "Gcash", "Gcash"],
        amounts: [
            DepositAmountOption(principal: "₱100", bonus: "+₱ 100", fieldAmount: "100.00", fieldExtra: "₱100.00", isFeatured: true),
            DepositAmountOption(principal: "₱200", bonus: "+₱ 200", fieldAmount: "200.00", fieldExtra: "₱200.00", isFeatured: false),
            DepositAmountOption(principal: "₱200", bonus: "+₱ 2.00", fieldAmount: "200.00", fieldExtra: "₱2.00", isFeatured: false),
            DepositAmountOption(principal: "₱200", bonus: "+₱ 2.00", fieldAmount: "200.00", fieldExtra: "₱2.00", isFeatured: false),
            DepositAmountOption(principal: "₱200", bonus: "+₱ 2.00", fieldAmount: "200.00", fieldExtra: "₱2.00", isFeatured: false),
            DepositAmountOption(principal: "₱200", bonus: "+₱ 2.00", fieldAmount: "200.00", fieldExtra: "₱2.00", isFeatured: false),
            DepositAmountOption(principal: "₱200", bonus: "+₱ 2.00", fieldAmount: "200.00", fieldExtra: "₱2.00", isFeatured: false),
            DepositAmountOption(principal: "₱200", bonus: "+₱ 2.00", fieldAmount: "200.00", fieldExtra: "₱2.00", isFeatured: false),
        ],
        promotions: [
            DepositPromotion(title: "First Deposit Bonus Up to YYY", detail: "≥ ₱ X"),
            DepositPromotion(title: "Do not participate any promotions", detail: nil),
        ]
    )
}

final class DepositViewModel {
    @Published private(set) var state = DepositViewState.initial

    func selectMode(_ mode: DepositMode) {
        state.mode = mode
    }

    func selectMethod(at index: Int) {
        guard index == 0 || index == 1 else { return }
        state.methodIndex = index
    }

    func selectChannel(at index: Int) {
        guard state.channels.indices.contains(index) else { return }
        state.channelIndex = index
    }

    func selectAmount(at index: Int) {
        guard state.amounts.indices.contains(index) else { return }
        state.amountIndex = index
    }

    func selectPromotion(at index: Int) {
        guard state.promotions.indices.contains(index) else { return }
        state.promotionIndex = index
    }
}
