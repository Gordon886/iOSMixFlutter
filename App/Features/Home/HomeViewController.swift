import UIKit

final class HomeViewController: UIViewController {
    private let userName: String
    private let resultLabel = UILabel()
    private let detailButton = UIButton(type: .system)
    private var opening = false

    init(userName: String) {
        self.userName = userName
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) 不可用")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        title = "首页"
        navigationItem.largeTitleDisplayMode = .always
        installLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func installLayout() {
        let badge = UILabel()
        badge.text = "Swift 原生页面"
        badge.font = .preferredFont(forTextStyle: .subheadline)
        badge.textColor = AppColors.secondary

        let greeting = UILabel()
        greeting.text = "你好，\(userName)"
        greeting.font = .systemFont(ofSize: 34, weight: .bold)
        greeting.textColor = AppColors.text
        greeting.numberOfLines = 0

        resultLabel.text = "从这里进入 Flutter 详情页"
        resultLabel.font = .preferredFont(forTextStyle: .body)
        resultLabel.textColor = AppColors.secondary
        resultLabel.numberOfLines = 0

        var configuration = UIButton.Configuration.filled()
        configuration.title = "查看详情"
        configuration.baseBackgroundColor = AppColors.primary
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        detailButton.configuration = configuration
        detailButton.addTarget(self, action: #selector(openDetail), for: .touchUpInside)

        let logoutButton = UIButton(type: .system)
        logoutButton.setTitle("退出登录", for: .normal)
        logoutButton.setTitleColor(AppColors.primary, for: .normal)
        logoutButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [badge, greeting, resultLabel, detailButton, logoutButton])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 16
        stack.setCustomSpacing(8, after: badge)
        stack.setCustomSpacing(28, after: resultLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
        ])
    }

    @objc private func openDetail() {
        guard !opening else { return }
        opening = true
        detailButton.isEnabled = false
        Task {
            let result = await AppRouter.shared.open(
                routeId: AppRoute.detail.rawValue,
                params: ["userName": userName]
            )
            opening = false
            detailButton.isEnabled = true
            switch result.status {
            case .success:
                resultLabel.text = result.result["message"] as? String ?? "已返回"
                resultLabel.textColor = AppColors.text
            case .cancelled:
                resultLabel.text = "已取消"
                resultLabel.textColor = AppColors.secondary
            case .error:
                resultLabel.text = "无法打开详情"
                resultLabel.textColor = AppColors.secondary
            }
        }
    }

    @objc private func logout() {
        Task {
            _ = await AppRouter.shared.open(routeId: AppRoute.login.rawValue, params: [:])
        }
    }
}
