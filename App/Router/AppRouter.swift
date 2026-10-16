import UIKit

final class AppRouter {
    static let shared = AppRouter()

    private weak var window: UIWindow?
    private let engineManager = FlutterEngineManager()
    private var bridge: RouterBridge?
    private var prepared = false

    func prepare() {
        guard !prepared else { return }
        prepared = true

        let engine = engineManager.makeEngine()
        // 当前引擎禁止在 run 之前注册通道，否则会触发
        // setMessageHandlerOnChannel 的断言。
        let started = engine.run(
            withEntrypoint: nil,
            libraryURI: nil,
            initialRoute: "/",
            entrypointArgs: ["hosted"]
        )
        if !started {
            assertionFailure("Flutter Engine 启动失败")
            return
        }
        GeneratedPluginRegistrant.register(with: engine)
        let bridge = RouterBridge(messenger: engine.binaryMessenger)
        bridge.onOpen = { [weak self] request, reply in
            guard let self else {
                reply(.error("router_missing"))
                return
            }
            self.perform(routeId: request.routeId, params: request.params, reply: reply)
        }
        bridge.onPop = { [weak self] requestId, result in
            self?.handlePop(requestId: requestId, result: result)
        }
        self.bridge = bridge
    }

    func attach(window: UIWindow) {
        self.window = window
        guard window.rootViewController == nil else { return }
        showFlutter(route: .login, params: [:], reply: { _ in })
    }

    func open(routeId: String, params: [String: Any]) async -> RouteResult {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                self.perform(routeId: routeId, params: params) { result in
                    continuation.resume(returning: result)
                }
            }
        }
    }

    func perform(routeId: String, params: [String: Any], reply: @escaping (RouteResult) -> Void) {
        let once = OnceReply(reply)
        guard let route = AppRoute.resolve(routeId) else {
            once.call(.error("route_not_found"))
            return
        }
        switch route.runtime {
        case .native:
            showNative(route: route, params: params) { once.call($0) }
        case .flutter:
            showFlutter(route: route, params: params) { once.call($0) }
        }
    }

    func handlePop(requestId: String, result: RouteResult) {
        guard let container = navigationController?.topViewController as? FlutterContainerController,
              container.requestId == requestId
        else {
            return
        }
        container.finish(result)
    }

    private var navigationController: UINavigationController? {
        window?.rootViewController as? UINavigationController
    }

    private func showNative(route: AppRoute, params: [String: Any], reply: @escaping (RouteResult) -> Void) {
        switch route {
        case .home:
            let name = (params["userName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
            let home = HomeViewController(userName: (name?.isEmpty == false ? name : nil) ?? "访客")
            let navigation = UINavigationController(rootViewController: home)
            navigation.navigationBar.prefersLargeTitles = true
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = AppColors.background
            navigation.navigationBar.standardAppearance = appearance
            navigation.navigationBar.scrollEdgeAppearance = appearance
            setRoot(navigation)
            reply(.success())
        case .deposit:
            showDeposit(reply: reply)
        case .login, .detail:
            reply(.error("route_not_found"))
        }
    }

    func dismiss(_ controller: UIViewController) {
        if let navigation = controller.navigationController, navigation.viewControllers.count > 1 {
            navigation.popViewController(animated: true)
            return
        }
        dismissTop()
    }

    func dismissTop() {
        navigationController?.popViewController(animated: true)
    }

    private func showDeposit(reply: @escaping (RouteResult) -> Void) {
        guard let navigationController else {
            reply(.error("navigator_missing"))
            return
        }
        let once = OnceReply(reply)
        let page = DepositViewController()
        page.onFinish = { result in
            once.call(result)
        }
        navigationController.pushViewController(page, animated: true)
    }

    private func showFlutter(route: AppRoute, params: [String: Any], reply: @escaping (RouteResult) -> Void) {
        let requestId = UUID().uuidString
        let once = OnceReply(reply)
        let display = { [weak self] in
            guard let self else {
                once.call(.error("router_missing"))
                return
            }
            guard let engine = self.engineManager.engine else {
                once.call(.error("engine_missing"))
                return
            }
            let container = FlutterContainerController(engine: engine, requestId: requestId) { result in
                once.call(result)
            }
            switch route.presentation {
            case .push:
                guard let navigationController = self.navigationController else {
                    once.call(.error("navigator_missing"))
                    return
                }
                navigationController.pushViewController(container, animated: true)
            case .root:
                self.setRoot(container)
                once.call(.success())
            case .replace:
                let navigation = UINavigationController(rootViewController: container)
                navigation.setNavigationBarHidden(true, animated: false)
                self.setRoot(navigation)
                once.call(.success())
            }
        }

        let alreadyVisible = window?.rootViewController != nil
        guard alreadyVisible, let bridge else {
            display()
            return
        }
        bridge.mount(routeId: route.rawValue, params: params, requestId: requestId, completion: display)
    }

    private func setRoot(_ controller: UIViewController) {
        window?.rootViewController = controller
    }
}

private final class OnceReply {
    private var done = false
    private let reply: (RouteResult) -> Void

    init(_ reply: @escaping (RouteResult) -> Void) {
        self.reply = reply
    }

    func call(_ result: RouteResult) {
        guard !done else { return }
        done = true
        DispatchQueue.main.async {
            self.reply(result)
        }
    }
}
