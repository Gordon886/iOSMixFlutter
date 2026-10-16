import SnapKit
import UIKit

final class DepositAmountCard: UIControl {
    private let artwork = UIImageView()
    private let principalLabel = UILabel()
    private let bonusLabel = UILabel()
    private let plusBadge = UIImageView(image: UIImage(named: "DepositBadgePlus"))
    private let hotBadge = UIImageView(image: UIImage(named: "DepositBadgeHot"))
    private let plusText = UILabel()
    private let hotText = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        artwork.contentMode = .scaleAspectFill
        artwork.clipsToBounds = true
        principalLabel.textAlignment = .center
        principalLabel.font = .systemFont(ofSize: max(13, 32 * DepositMetrics.scale), weight: .semibold)
        principalLabel.textColor = AppColors.depositTitle
        bonusLabel.textAlignment = .center
        bonusLabel.font = .systemFont(ofSize: max(11, 20 * DepositMetrics.scale), weight: .semibold)
        bonusLabel.textColor = AppColors.depositBonus
        plusText.text = "+₱10"
        hotText.text = "HOT"
        for label in [plusText, hotText] {
            label.font = .systemFont(ofSize: max(8, 11 * DepositMetrics.scale), weight: .bold)
            label.textColor = .white
            label.textAlignment = .center
        }
        for item in [artwork, principalLabel, bonusLabel, plusBadge, hotBadge, plusText, hotText] {
            addSubview(item)
        }

        let badgeWidth = max(28, 41 * DepositMetrics.scale)
        let badgeHeight = max(14, 22 * DepositMetrics.scale)
        artwork.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        principalLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-8)
        }
        bonusLabel.snp.makeConstraints { make in
            make.top.equalTo(principalLabel.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
        plusBadge.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.leading.equalToSuperview().offset(2)
            make.width.equalTo(badgeWidth)
            make.height.equalTo(badgeHeight)
        }
        hotBadge.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.trailing.equalToSuperview().offset(-2)
            make.width.equalTo(badgeWidth)
            make.height.equalTo(badgeHeight)
        }
        plusText.snp.makeConstraints { make in
            make.center.equalTo(plusBadge)
        }
        hotText.snp.makeConstraints { make in
            make.center.equalTo(hotBadge)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) 不可用")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 13 * DepositMetrics.scale
        clipsToBounds = true
    }

    func apply(option: DepositAmountOption, selected: Bool) {
        principalLabel.text = option.principal
        bonusLabel.text = option.bonus
        artwork.image = UIImage(named: option.isFeatured ? "DepositAmountFeatured" : "DepositAmountPlain")
        plusBadge.isHidden = !option.isFeatured
        hotBadge.isHidden = !option.isFeatured
        plusText.isHidden = !option.isFeatured
        hotText.isHidden = !option.isFeatured
        layer.borderWidth = selected && !option.isFeatured ? 2 : 0
        layer.borderColor = AppColors.depositBlue.cgColor
    }
}
