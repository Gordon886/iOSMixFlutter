import Flutter

/// 持有一个可无界面运行的 Engine。登录页被原生首页替换后，Isolate 仍保留，
/// 再次打开详情时挂到新的容器上。同一时刻只显示一个 Flutter 容器。
final class FlutterEngineManager {
    private(set) var engine: FlutterEngine?

    func makeEngine() -> FlutterEngine {
        if let engine {
            return engine
        }
        let engine = FlutterEngine(name: "main")
        self.engine = engine
        return engine
    }
}
