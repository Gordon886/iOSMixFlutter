import Foundation

struct RouteResult {
    enum Status: String {
        case success
        case cancelled
        case error
    }

    let status: Status
    let result: [String: Any]
    let code: String?

    static func success(_ result: [String: Any] = [:]) -> RouteResult {
        RouteResult(status: .success, result: result, code: nil)
    }

    static func cancelled() -> RouteResult {
        RouteResult(status: .cancelled, result: [:], code: nil)
    }

    static func error(_ code: String) -> RouteResult {
        RouteResult(status: .error, result: [:], code: code)
    }

    var asDictionary: [String: Any] {
        var payload: [String: Any] = [
            "status": status.rawValue,
            "result": result,
        ]
        if let code {
            payload["code"] = code
        }
        return payload
    }
}

struct RouteRequest {
    let routeId: String
    let params: [String: Any]
    let requestId: String

    static func parse(_ arguments: Any?) -> RouteRequest? {
        guard let map = stringKeyedMap(arguments),
              let routeId = map["routeId"] as? String
        else {
            return nil
        }
        return RouteRequest(
            routeId: routeId,
            params: stringKeyedMap(map["params"]) ?? [:],
            requestId: map["requestId"] as? String ?? UUID().uuidString
        )
    }
}

func stringKeyedMap(_ value: Any?) -> [String: Any]? {
    if let map = value as? [String: Any] {
        return map
    }
    guard let map = value as? [AnyHashable: Any] else { return nil }
    var result: [String: Any] = [:]
    for (key, item) in map {
        guard let key = key as? String else { continue }
        result[key] = item
    }
    return result
}
