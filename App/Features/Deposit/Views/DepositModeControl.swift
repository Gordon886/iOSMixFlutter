import SnapKit
import UIKit

final class DepositModeControl: UIView {
    var onChange: ((DepositMode) -> Void)?

    private let pill = CapsuleGradientView()
    private let depositButton = UIButton(type: .system)
    private let withdrawButton = UIButton(type: .system)
    private var pillLeading: Constraint?
    private var appliedOffset: CGFloat?
    private var mode = DepositMode.deposit

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AppColors.depositTrack
        addSubview(pill)
        depositButton.setTitle("Deposit", for: .normal)
        withdrawButton.setTitle("Withdraw", for: .normal)
        depositButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        withdrawButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        depositButton.addTarget(self, action: #selector(selectDeposit), for: .touchUpInside)
        withdrawButton.addTarget(self, action: #selector(selectWithdraw), for: .touchUpInside)
        let buttons = UIStackView(arrangedSubviews: [depositButton, withdrawButton])
        buttons.axis = .horizontal
        buttons.distribution = .fillEqually
        addSubview(buttons)

        pill.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.bottom.equalToSuperview().offset(-2)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-2)
            pillLeading = make.leading.equalToSuperview().offset(2).constraint
        }
        buttons.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) 不可用")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        updatePillPosition(animated: false)
    }

    func setMode(_ mode: DepositMode) {
        self.mode = mode
        depositButton.setTitleColor(mode == .deposit ? .white : AppColors.depositMuted, for: .normal)
        withdrawButton.setTitleColor(mode == .withdraw ? .white : AppColors.depositMuted, for: .normal)
        updatePillPosition(animated: true)
    }

    private func updatePillPosition(animated: Bool) {
        let inset: CGFloat = 2
        let travel = bounds.width / 2
        let offset = mode == .deposit ? inset : max(travel, inset)
        if appliedOffset != offset {
            appliedOffset = offset
            pillLeading?.update(offset: offset)
        }
        guard animated else { return }
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }

    @objc private func selectDeposit() {
        onChange?(.deposit)
    }

    @objc private func selectWithdraw() {
        onChange?(.withdraw)
    }
}

private final class CapsuleGradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }

    override init(frame: CGRect) {
        super.init(frame: frame)
        guard let gradient = layer as? CAGradientLayer else { return }
        gradient.colors = [AppColors.depositBlue.cgColor, AppColors.depositBlueTop.cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 1)
        gradient.endPoint = CGPoint(x: 0.5, y: 0)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) 不可用")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}
