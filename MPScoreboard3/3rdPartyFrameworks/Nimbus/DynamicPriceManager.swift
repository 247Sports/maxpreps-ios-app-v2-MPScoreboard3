//
// Created by Jason Sznol on 11/29/22.
//

import DTBiOSSDK
import Foundation
import GoogleMobileAds
import NimbusKit
import NimbusGAMKit

final class DynamicPriceManager {

    let bidders: [Bidder]
    let refreshInterval: TimeInterval
    let requestBuilder: () -> GAMRequest
    var lastRequestTime: TimeInterval = 0
    var callback: ((GAMRequest) -> Void)?
    var autoRefreshTask: Task<Void, Error>?

    init(
        bidders: [Bidder],
        refreshInterval: TimeInterval = 30,
        requestBuilder: @escaping () -> GAMRequest = { GAMRequest() }
    ) {
        self.bidders = bidders
        self.refreshInterval = refreshInterval
        self.requestBuilder = requestBuilder
    }

    func autoRefresh(_ callback: @escaping (GAMRequest) -> Void) {
        self.callback = callback

        setupAutoRefreshingTask()

        setupNotifications()
    }

    func cancelRefresh() {
        autoRefreshTask?.cancel()
        autoRefreshTask = nil
        
        // Added in V6.2.6
        lastRequestTime = 0
    }

    private func auction() async throws -> GAMRequest {
        let sleepInSec = (refreshInterval - (Date().timeIntervalSince1970 - lastRequestTime))
        if sleepInSec > 0 {
            try await Task.sleep(nanoseconds: UInt64(sleepInSec * 1_000_000_000))
        }

        lastRequestTime = Date().timeIntervalSince1970

        print("Starting Auction")
        let bids = await getBids()

        let request = requestBuilder()
        if request.customTargeting == nil { request.customTargeting = [:] }
        bids.forEach { $0.applyTargeting(for: request) }

        // GAM request now has all the custom targeting applied from APS and Nimbus
        return request
    }

    private func getBids() async -> [Bid] {
        return await withTaskGroup(of: Optional<Bid>.self, returning: [Bid].self) { group in
            for bidder in bidders {
                group.addTask {
                    guard let bid = try? await bidder.fetchBid() else {
                        return nil
                    }
                    return bid
                }
            }

            var bids: [Bid] = []
            for await bid in group.compactMap({ $0 }) {
                bids.append(bid)
            }
            return bids
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    @objc private func appDidBecomeActive() {
        setupAutoRefreshingTask()
    }

    @objc private func appWillResignActive() {
        autoRefreshTask?.cancel()
    }

    private func setupAutoRefreshingTask() {
        if autoRefreshTask == nil || autoRefreshTask?.isCancelled == true {
            autoRefreshTask = Task {
                while !Task.isCancelled {
                    callback?(try await auction())
                }
            }
        }
    }
}

enum Bid {
    case nimbus(NimbusAd)
    case aps(DTBAdResponse)

    func applyTargeting(for request: GAMRequest) {
        switch self {
        case let .aps(response):
            response.applyTargeting(into: request)
        case let .nimbus(ad):
            ad.applyTargeting(into: request)
        }
    }
}

protocol Bidder {
    func fetchBid() async throws -> Bid
}

final class NimbusBidder: Bidder {

    private let request: NimbusRequest
    private let mapping: NimbusDynamicPriceMapping?
    private let requestManager = NimbusRequestManager()
    private var continuation: CheckedContinuation<Bid, Error>?

    init(request: NimbusRequest, mapping: NimbusDynamicPriceMapping? = nil)
    {
        self.request = request
        self.mapping = mapping
        requestManager.delegate = self
        //addGoogleOm(request: self.request) // Removed for SDK 2.4.1
        
        // Added for SDK 2.4.1 upgrade
        self.request.configureViewability(partnerName: "Google", partnerVersion: GADMobileAds.sharedInstance().sdkVersion)
    }

    func fetchBid() async throws -> Bid {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let `self` = self else { return }

            self.continuation = continuation

            print("NimbusBidder Start Nimbus Request")
            self.requestManager.performRequest(request: request)
        }
    }

    /*
    func addGoogleOm(request: NimbusRequest) {
        request.source = NimbusSource()
        request.source?.extensions?["omidpn"] = NimbusCodable("Google")

        if request.impressions[0].banner != nil {
            if request.impressions[0].banner?.supportedApis == nil {
                request.impressions[0].banner?.supportedApis = []
            }
            if request.impressions[0].banner?.supportedApis?.contains(NimbusApi.omid1) == false {
                request.impressions[0].banner?.supportedApis?.insert(NimbusApi.omid1)
            }
        }
    }
    */
}

extension NimbusBidder: NimbusRequestManagerDelegate {
    func didCompleteNimbusRequest(request: NimbusRequest, ad: NimbusAd) {
        print("NimbusBidder didCompleteNimbusRequest")
        
        self.continuation?.resume(returning: .nimbus(ad)) // Added self.
        
        // Added in V6.2.7
        self.continuation = nil
    }

    func didFailNimbusRequest(request: NimbusRequest, error: NimbusError) {
        print("NimbusBidder didFailNimbusRequest")
        
        self.continuation?.resume(throwing: error) // Added self.
        
        // Added in V6.2.7
        self.continuation = nil
    }
}


final class APSBidder: Bidder, DTBAdCallback {

    let adLoader: DTBAdLoader
    var continuation: CheckedContinuation<DTBAdResponse, Error>?

    init(adLoader: DTBAdLoader) {
        self.adLoader = adLoader
    }

    func fetchBid() async throws -> Bid {
        try await .aps(loadAd())
    }

    private func loadAd() async throws -> DTBAdResponse {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let `self` = self else { return }

            self.continuation = continuation

            print("APSBidder Start Amazon Banner Ad Load")
            self.adLoader.loadAd(self)
        }
    }

    func onSuccess(_ adResponse: DTBAdResponse!) {
        print("Received Amazon Banner Ad")
        continuation?.resume(returning: adResponse)
    }

    func onFailure(_ error: DTBAdError) {
        print("Amazon Banner Ad Failed \(error.rawValue)")
        continuation?.resume(throwing: NimbusRenderError.adRenderingFailed(message: ""))
    }
}

private extension DTBAdResponse {
    func applyTargeting(into request: GAMRequest) {
        if let customTargeting = customTargeting() {
            request.customTargeting?.merge(customTargeting, uniquingKeysWith: { (_, new) in new })
        }
    }
}

private extension NimbusAd {

    func applyTargeting(into request: GAMRequest, mapping: NimbusGAMLinearPriceMapping = NimbusGAMLinearPriceMapping.banner()) {
        request.customTargeting?["na_id"] = auctionId
        request.customTargeting?["na_network"] = network

        if auctionType == .video {
            request.customTargeting?["na_bid_video"] = mapping.getKeywords(ad: self)

            if let duration = duration {
                request.customTargeting?["na_duration"] = String(duration)
            }
        } else {
            request.customTargeting?["na_bid"] = mapping.getKeywords(ad: self)
        }
    }
}

struct TimedOutError: Error, Equatable {}
