import SnapKit
import UIKit

final class DepositPromotionRow: UIControl {
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let radio = UIImageView()
    private let chevron = UIImageView(image: UIImage(named: "DepositChevron"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        titleLabel.font = .systemFont(ofSize: max(14, 28 * DepositMetrics.scale), weight: .semibold)
        titleLabel.textColor = AppColors.depositTitle
        titleLabel.numberOfLines = 2
        detailLabel.font = .systemFont(ofSize: max(13, 28 * DepositMetrics.scale), weight: .semibold)
        detailLabel.textColor = AppColors.depositTitle
        radio.contentMode = .scaleAspectFit
        chevron.contentMode = .scaleAspectFit

        let text = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        text.axis = .vertical
        text.spacing = 6
        let row = UIStackView(arrangedSubviews: [radio, text, chevron])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.isUserInteractionEnabled = false
        addSubview(row)

        let radioSide = max(24, 48 * DepositMetrics.scale)
        let chevronSide = max(18, 28 * DepositMetrics.scale)
        radio.snp.makeConstraints { make in
            make.width.height.equalTo(radioSide)
        }
        chevron.snp.makeConstraints { make in
            make.width.height.equalTo(chevronSide)
        }
        row.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-16)
        }
        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(max(72, 110 * DepositMetrics.scale))
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) 不可用")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 16 * DepositMetrics.scale
    }

    func apply(promotion: DepositPromotion, selected: Bool) {
        titleLabel.text = promotion.title
        detailLabel.text = promotion.detail
        detailLabel.isHidden = promotion.detail == nil
        chevron.isHidden = promotion.detail == nil
        radio.image = UIImage(named: selected ? "DepositRadioOn" : "DepositRadioOff")
        layer.borderWidth = selected ? 2 : 0
        layer.borderColor = AppColors.depositBlueTop.cgColor
    }
}
