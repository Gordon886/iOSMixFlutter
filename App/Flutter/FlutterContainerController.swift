import Flutter
import UIKit

final class FlutterContainerController: FlutterViewController {
    let requestId: String
    private let onFinish: (RouteResult) -> Void
    private var hasFinished = false

    init(engine: FlutterEngine, requestId: String, onFinish: @escaping (RouteResult) -> Void) {
        self.requestId = requestId
        self.onFinish = onFinish
        super.init(engine: engine, nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) 不可用")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            finish(.cancelled())
        }
    }

    func finish(_ result: RouteResult) {
        guard !hasFinished else { return }
        hasFinished = true
        onFinish(result)
        guard let navigationController,
              navigationController.topViewController === self,
              !isMovingFromParent
        else {
            return
        }
        navigationController.popViewController(animated: true)
    }
}
