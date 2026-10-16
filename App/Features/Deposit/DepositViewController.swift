import Combine
import UIKit

final class DepositViewController: UIViewController, UIGestureRecognizerDelegate {
    var onFinish: ((RouteResult) -> Void)?

    private let viewModel = DepositViewModel()
    private let depositView = DepositView()
    private var cancellables = Set<AnyCancellable>()
    private var didFinish = false

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) 不可用")
    }

    override func loadView() {
        view = depositView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        installNavigationItem()
        depositView.onModeChange = { [weak self] mode in
            self?.viewModel.selectMode(mode)
        }
        depositView.onMethodSelect = { [weak self] index in
            self?.viewModel.selectMethod(at: index)
        }
        depositView.onChannelSelect = { [weak self] index in
            self?.viewModel.selectChannel(at: index)
        }
        depositView.onAmountSelect = { [weak self] index in
            self?.viewModel.selectAmount(at: index)
        }
        depositView.onPromotionSelect = { [weak self] index in
            self?.viewModel.selectPromotion(at: index)
        }
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showNavigationBar(animated: false)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard isMovingFromParent || isBeingDismissed else { return }
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard isMovingFromParent || isBeingDismissed else { return }
        finish(.cancelled())
    }

    private func render(_ state: DepositViewState) {
        navigationItem.title = state.actionTitle
        depositView.render(state)
    }

    private func installNavigationItem() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = UIColor(white: 0, alpha: 0.08)
        appearance.titleTextAttributes = [
            .foregroundColor: AppColors.depositTitle,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
        ]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.title = "Deposit"

        let back = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(close)
        )
        back.accessibilityLabel = "返回"
        navigationItem.leftBarButtonItem = back
    }

    private func showNavigationBar(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.tintColor = AppColors.depositTitle
        navigationItem.leftBarButtonItem?.tintColor = AppColors.depositTitle
    }

    @objc private func close() {
        AppRouter.shared.dismiss(self)
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === navigationController?.interactivePopGestureRecognizer else {
            return true
        }
        return (navigationController?.viewControllers.count ?? 0) > 1
    }

    private func finish(_ result: RouteResult) {
        guard !didFinish else { return }
        didFinish = true
        onFinish?(result)
    }
}
