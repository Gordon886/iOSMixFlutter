import SnapKit
import UIKit

enum DepositMetrics {
    static let designWidth: CGFloat = 720
    static var scale: CGFloat { UIScreen.main.bounds.width / designWidth }
    static func s(_ value: CGFloat) -> CGFloat { value * scale }
}

final class DepositView: UIView {
    var onModeChange: ((DepositMode) -> Void)?
    var onMethodSelect: ((Int) -> Void)?
    var onChannelSelect: ((Int) -> Void)?
    var onAmountSelect: ((Int) -> Void)?
    var onPromotionSelect: ((Int) -> Void)?

    private let methodTitleLabel = UILabel()
    private let amountValueLabel = UILabel()
    private let extraValueLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private let modeControl = DepositModeControl()
    private var methodButtons: [UIButton] = []
    private var channelButtons: [UIButton] = []
    private var amountCards: [DepositAmountCard] = []
    private var promotionRows: [DepositPromotionRow] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        installBackground()
        installContent()
        modeControl.onChange = { [weak self] mode in
            self?.onModeChange?(mode)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) 不可用")
    }

    func render(_ state: DepositViewState) {
        modeControl.setMode(state.mode)
        methodTitleLabel.text = state.methodTitle
        amountValueLabel.text = state.selectedAmount.fieldAmount
        extraValueLabel.text = state.selectedAmount.fieldExtra
        actionButton.setTitle(state.actionTitle, for: .normal)

        for (index, button) in methodButtons.enumerated() {
            let selected = index == state.methodIndex
            button.layer.borderWidth = selected ? DepositMetrics.s(4) : 0
            button.layer.borderColor = AppColors.depositBlue.cgColor
            button.clipsToBounds = true
        }
        for (index, button) in channelButtons.enumerated() {
            let selected = index == state.channelIndex
            button.setTitle(state.channels[index], for: .normal)
            button.backgroundColor = selected ? AppColors.depositBlue : .white
            button.setTitleColor(selected ? .white : .black, for: .normal)
            button.clipsToBounds = true
        }
        for (index, card) in amountCards.enumerated() {
            card.apply(option: state.amounts[index], selected: index == state.amountIndex)
        }
        for (index, row) in promotionRows.enumerated() {
            row.apply(promotion: state.promotions[index], selected: index == state.promotionIndex)
        }
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let methodRadius = methodButtons.first?.bounds.height ?? 0
        if methodRadius > 0 {
            for button in methodButtons {
                button.layer.cornerRadius = button.bounds.height / 2
            }
        }
        actionButton.layer.cornerRadius = DepositMetrics.s(16)
        for button in channelButtons where button.bounds.height > 0 {
            button.layer.cornerRadius = button.bounds.height / 2
        }
    }

    private func installBackground() {
        let background = UIImageView(image: UIImage(named: "DepositBackground"))
        background.contentMode = .scaleAspectFill
        background.clipsToBounds = true
        addSubview(background)
        background.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let holly = UIImageView(image: UIImage(named: "DepositHolly"))
        holly.contentMode = .scaleAspectFit
        addSubview(holly)
        holly.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(holly.snp.width).multipliedBy(0.42)
        }
    }

    private func installContent() {
        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        scroll.showsVerticalScrollIndicator = false
        addSubview(scroll)
        scroll.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(DepositMetrics.s(8))
            make.leading.trailing.bottom.equalToSuperview()
        }

        let content = UIStackView()
        content.axis = .vertical
        content.spacing = DepositMetrics.s(28)
        scroll.addSubview(content)
        content.snp.makeConstraints { make in
            make.top.equalTo(scroll.contentLayoutGuide).offset(DepositMetrics.s(36))
            make.leading.equalTo(scroll.frameLayoutGuide).offset(DepositMetrics.s(30))
            make.trailing.equalTo(scroll.frameLayoutGuide).offset(-DepositMetrics.s(30))
            make.bottom.equalTo(scroll.contentLayoutGuide).offset(-DepositMetrics.s(48))
            make.width.equalTo(scroll.frameLayoutGuide).offset(-DepositMetrics.s(60))
        }

        content.addArrangedSubview(modeControl)
        modeControl.snp.makeConstraints { make in
            make.height.equalTo(max(DepositMetrics.s(76), 44))
        }
        content.addArrangedSubview(methodSection())
        content.addArrangedSubview(channelSection())
        content.addArrangedSubview(amountSection())
        content.addArrangedSubview(amountGrid())
        content.addArrangedSubview(promotionSection())
        content.addArrangedSubview(makeActionButton())
    }

    private func methodSection() -> UIView {
        methodTitleLabel.font = .systemFont(ofSize: DepositMetrics.s(28), weight: .semibold)
        methodTitleLabel.textColor = AppColors.depositTitle
        methodTitleLabel.adjustsFontForContentSizeCategory = true
        methodTitleLabel.text = "Select Deposit Method"

        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = DepositMetrics.s(18)
        row.distribution = .fillEqually
        let logos = ["DepositGCash", "DepositPayMaya"]
        for (index, name) in logos.enumerated() {
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: name), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.contentEdgeInsets = UIEdgeInsets(
                top: DepositMetrics.s(16),
                left: DepositMetrics.s(18),
                bottom: DepositMetrics.s(16),
                right: DepositMetrics.s(18)
            )
            button.backgroundColor = .white
            button.tag = index
            button.addTarget(self, action: #selector(methodTapped(_:)), for: .touchUpInside)
            button.snp.makeConstraints { make in
                make.height.equalTo(max(DepositMetrics.s(70), 44))
            }
            row.addArrangedSubview(button)
            methodButtons.append(button)
        }
        return grouped(title: methodTitleLabel, body: row)
    }

    private func channelSection() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = DepositMetrics.s(16)
        row.distribution = .fillEqually
        for index in DepositViewState.initial.channels.indices {
            let button = UIButton(type: .system)
            button.tag = index
            button.titleLabel?.font = .systemFont(ofSize: DepositMetrics.s(28), weight: .semibold)
            button.addTarget(self, action: #selector(channelTapped(_:)), for: .touchUpInside)
            button.snp.makeConstraints { make in
                make.height.equalTo(max(DepositMetrics.s(70), 44))
            }
            row.addArrangedSubview(button)
            channelButtons.append(button)
        }
        return grouped(title: sectionTitle("Select Payment Channel"), body: row)
    }

    private func amountSection() -> UIView {
        let field = UIView()
        field.backgroundColor = .white
        field.layer.cornerRadius = max(DepositMetrics.s(78), 44) / 2
        field.clipsToBounds = true
        field.snp.makeConstraints { make in
            make.height.equalTo(max(DepositMetrics.s(78), 44))
        }

        let peso = UILabel()
        peso.text = "₱"
        peso.font = .systemFont(ofSize: DepositMetrics.s(36), weight: .semibold)
        peso.textColor = AppColors.depositTitle
        amountValueLabel.font = .systemFont(ofSize: DepositMetrics.s(36), weight: .semibold)
        amountValueLabel.textColor = AppColors.depositMuted

        let extraCaption = UILabel()
        extraCaption.text = "extra+"
        extraCaption.font = .systemFont(ofSize: DepositMetrics.s(22), weight: .medium)
        extraCaption.textColor = AppColors.depositTitle
        extraValueLabel.font = .systemFont(ofSize: DepositMetrics.s(22), weight: .semibold)
        extraValueLabel.textColor = AppColors.depositBlue

        let leading = UIStackView(arrangedSubviews: [peso, amountValueLabel])
        leading.axis = .horizontal
        leading.spacing = DepositMetrics.s(8)
        leading.alignment = .center
        let trailing = UIStackView(arrangedSubviews: [extraCaption, extraValueLabel])
        trailing.axis = .horizontal
        trailing.spacing = DepositMetrics.s(2)
        trailing.alignment = .center
        let row = UIStackView(arrangedSubviews: [leading, trailing])
        row.axis = .horizontal
        row.distribution = .equalSpacing
        row.alignment = .center
        field.addSubview(row)
        row.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(DepositMetrics.s(22))
            make.centerY.equalToSuperview()
        }
        return grouped(title: sectionTitle("Enter Amount"), body: field)
    }

    private func amountGrid() -> UIView {
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = DepositMetrics.s(16)
        let options = DepositViewState.initial.amounts
        for start in stride(from: 0, to: options.count, by: 4) {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = DepositMetrics.s(17)
            row.distribution = .fillEqually
            for index in start..<min(start + 4, options.count) {
                let card = DepositAmountCard()
                card.tag = index
                card.addTarget(self, action: #selector(amountTapped(_:)), for: .touchUpInside)
                card.snp.makeConstraints { make in
                    make.height.equalTo(DepositMetrics.s(100))
                }
                row.addArrangedSubview(card)
                amountCards.append(card)
            }
            grid.addArrangedSubview(row)
        }
        return grid
    }

    private func promotionSection() -> UIView {
        let list = UIStackView()
        list.axis = .vertical
        list.spacing = DepositMetrics.s(20)
        for index in DepositViewState.initial.promotions.indices {
            let row = DepositPromotionRow()
            row.tag = index
            row.addTarget(self, action: #selector(promotionTapped(_:)), for: .touchUpInside)
            list.addArrangedSubview(row)
            promotionRows.append(row)
        }
        return grouped(title: sectionTitle("Promotions"), body: list)
    }

    private func makeActionButton() -> UIButton {
        actionButton.backgroundColor = AppColors.depositBlue
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: DepositMetrics.s(32), weight: .semibold)
        actionButton.snp.makeConstraints { make in
            make.height.equalTo(max(DepositMetrics.s(88), 44))
        }
        return actionButton
    }

    private func sectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: DepositMetrics.s(28), weight: .semibold)
        label.textColor = AppColors.depositTitle
        label.adjustsFontForContentSizeCategory = true
        return label
    }

    private func grouped(title: UILabel, body: UIView) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [title, body])
        stack.axis = .vertical
        stack.spacing = DepositMetrics.s(18)
        return stack
    }

    @objc private func methodTapped(_ sender: UIButton) {
        onMethodSelect?(sender.tag)
    }

    @objc private func channelTapped(_ sender: UIButton) {
        onChannelSelect?(sender.tag)
    }

    @objc private func amountTapped(_ sender: UIControl) {
        onAmountSelect?(sender.tag)
    }

    @objc private func promotionTapped(_ sender: UIControl) {
        onPromotionSelect?(sender.tag)
    }
}
