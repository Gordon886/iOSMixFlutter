import Flutter
import Foundation
import os

final class RouterBridge {
    private let channel: FlutterMethodChannel
    private let log = Logger(subsystem: "com.fluttermixin.app", category: "router")

    var onOpen: ((RouteRequest, @escaping (RouteResult) -> Void) -> Void)?
    var onPop: ((String, RouteResult) -> Void)?

    init(messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "app/router", binaryMessenger: messenger)
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
    }

    func mount(
        routeId: String,
        params: [String: Any],
        requestId: String?,
        completion: @escaping () -> Void
    ) {
        var arguments: [String: Any] = [
            "routeId": routeId,
            "params": params,
        ]
        if let requestId {
            arguments["requestId"] = requestId
        }
        log.info("mount \(routeId, privacy: .public)")
        channel.invokeMethod("mount", arguments: arguments) { _ in
            DispatchQueue.main.async(execute: completion)
        }
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "open":
            guard let request = RouteRequest.parse(call.arguments) else {
                result(RouteResult.error("bad_request").asDictionary)
                return
            }
            log.info("open \(request.routeId, privacy: .public)")
            guard let onOpen else {
                result(RouteResult.error("router_missing").asDictionary)
                return
            }
            onOpen(request) { routeResult in
                result(routeResult.asDictionary)
            }
        case "pop":
            guard let map = stringKeyedMap(call.arguments),
                  let requestId = map["requestId"] as? String
            else {
                result(RouteResult.error("bad_request").asDictionary)
                return
            }
            let status = RouteResult.Status(rawValue: map["status"] as? String ?? "") ?? .error
            let payload = stringKeyedMap(map["result"]) ?? [:]
            log.info("pop \(requestId, privacy: .public) \(status.rawValue, privacy: .public)")
            onPop?(requestId, RouteResult(status: status, result: payload, code: map["code"] as? String))
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
