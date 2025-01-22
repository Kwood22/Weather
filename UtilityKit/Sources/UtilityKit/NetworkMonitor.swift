import Foundation
import Network

@Observable
public final class NetworkMonitor: @unchecked Sendable {
    private let networkMonitor = NWPathMonitor()
    public var isConnected = true
    public static let shared: NetworkMonitor = .init()

    private init() {
        startMonitoring()
    }

    deinit {
        networkMonitor.cancel()
    }

    private func startMonitoring() {
        let queue = DispatchQueue(label: "NetworkConnectivityMonitor")
        networkMonitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        networkMonitor.start(queue: queue)
    }

    private func stopMonitoring() {
        networkMonitor.cancel()
    }
}
