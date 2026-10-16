import UIKit

enum AppRoute: String {
    case login
    case home
    case detail
    case deposit

    enum Runtime {
        case flutter
        case native
    }

    enum Presentation {
        case root
        case push
        case replace
    }

    var runtime: Runtime {
        switch self {
        case .login, .home, .detail:
            return .flutter
        case .deposit:
            return .native
        }
    }

    var presentation: Presentation {
        switch self {
        case .login:
            return .root
        case .home:
            return .replace
        case .detail, .deposit:
            return .push
        }
    }

    static func resolve(_ routeId: String) -> AppRoute? {
        AppRoute(rawValue: routeId)
    }
}
