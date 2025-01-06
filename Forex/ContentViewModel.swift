import Foundation
import SwiftUI

struct EconomicEvent: Identifiable {
    let id = UUID()
    let time: String
    let description: String
    let impact: String
}

enum TradeDirection {
    case long
    case short
}

struct TradeSetup: Identifiable {
    let id = UUID()
    let direction: TradeDirection
    let entryZone: String
    let takeProfit: String
    let riskReward: String
    let notes: String
}

enum TimeFrame: String, CaseIterable, Identifiable {
    case minutes15 = "15m"
    case hour1 = "1h"
    case hour4 = "4h"
    case day1 = "1d"
    
    var id: String { self.rawValue }
    
    var display: String {
        switch self {
        case .minutes15: return "15m"
        case .hour1: return "1h"
        case .hour4: return "4h"
        case .day1: return "1D"
        }
    }
}

enum ZoneType: String {
    case resistance = "Resistance"
    case support = "Support"
}

enum ZoneStrength: String {
    case weak = "Weak"
    case medium = "Medium"
    case strong = "Strong"
}

struct PriceZone: Identifiable {
    let id = UUID()
    let type: ZoneType
    let price: Double
    let strength: ZoneStrength
    let notes: String
    let timeFrame: TimeFrame
}

class ContentViewModel: ObservableObject {
    @Published var rsiValue: Double = 0.0
    @Published var macdValue: Double = 0.0
    @Published var maValue: Double = 0.0
    @Published var priceZones: [PriceZone] = []
    @Published var nextTargetPrice: Double? = 1.0880
    @Published var economicEvents: [EconomicEvent] = []
    @Published var tradeSetups: [TradeSetup] = []
    
    init() {
        setupLiveData()
        loadEconomicCalendar()
        updateAnalysis(for: .minutes15) // Default time frame
    }
    
    func updateAnalysis(for timeFrame: TimeFrame) {
        // Update price zones based on time frame
        loadPriceZones(for: timeFrame)
        // Update trade setups for the selected time frame
        loadTradeSetups(for: timeFrame)
    }
    
    private func setupLiveData() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.updateMarketData()
        }
    }
    
    private func updateMarketData() {
        // Update technical indicators
        rsiValue = Double.random(in: 30...70)
        macdValue = Double.random(in: -20...20)
        maValue = Double.random(in: 40...60)
        
        // Update price levels based on market movement
        analyzeKeyLevels()
    }
    
    private func analyzeKeyLevels() {
        // Add your price level analysis logic here
        // This should update resistance, support, and target levels
    }
    
    private func loadPriceZones(for timeFrame: TimeFrame) {
        // Base these levels around current market price of ~1.0315
        switch timeFrame {
        case .minutes15:
            priceZones = [
                PriceZone(type: .resistance, price: 1.0325, strength: .medium, notes: "15m local high", timeFrame: timeFrame),
                PriceZone(type: .resistance, price: 1.0335, strength: .strong, notes: "15m structure resistance", timeFrame: timeFrame),
                PriceZone(type: .support, price: 1.0305, strength: .medium, notes: "15m local low", timeFrame: timeFrame),
                PriceZone(type: .support, price: 1.0295, strength: .strong, notes: "15m structure support", timeFrame: timeFrame)
            ]
        case .hour1:
            priceZones = [
                PriceZone(type: .resistance, price: 1.0340, strength: .strong, notes: "1h supply zone", timeFrame: timeFrame),
                PriceZone(type: .resistance, price: 1.0330, strength: .medium, notes: "1h structure high", timeFrame: timeFrame),
                PriceZone(type: .support, price: 1.0290, strength: .strong, notes: "1h demand zone", timeFrame: timeFrame),
                PriceZone(type: .support, price: 1.0300, strength: .medium, notes: "1h structure low", timeFrame: timeFrame)
            ]
        case .hour4:
            priceZones = [
                PriceZone(type: .resistance, price: 1.0365, strength: .strong, notes: "4h range high", timeFrame: timeFrame),
                PriceZone(type: .resistance, price: 1.0345, strength: .medium, notes: "4h structure resistance", timeFrame: timeFrame),
                PriceZone(type: .support, price: 1.0285, strength: .strong, notes: "4h range low", timeFrame: timeFrame),
                PriceZone(type: .support, price: 1.0295, strength: .medium, notes: "4h structure support", timeFrame: timeFrame)
            ]
        case .day1:
            priceZones = [
                PriceZone(type: .resistance, price: 1.0390, strength: .strong, notes: "Daily resistance", timeFrame: timeFrame),
                PriceZone(type: .resistance, price: 1.0370, strength: .medium, notes: "Previous day high", timeFrame: timeFrame),
                PriceZone(type: .support, price: 1.0270, strength: .strong, notes: "Daily support", timeFrame: timeFrame),
                PriceZone(type: .support, price: 1.0280, strength: .medium, notes: "Previous day low", timeFrame: timeFrame)
            ]
        }
    }
    
    private func loadTradeSetups(for timeFrame: TimeFrame) {
        // Update trade setups based on the selected time frame
        tradeSetups = [
            TradeSetup(
                direction: .long,
                entryZone: getPriceRange(for: timeFrame, type: .support),
                takeProfit: getTakeProfit(for: timeFrame, direction: .long),
                riskReward: getRiskReward(for: timeFrame),
                notes: "Wait for confirmation at \(timeFrame.display) support"
            ),
            TradeSetup(
                direction: .short,
                entryZone: getPriceRange(for: timeFrame, type: .resistance),
                takeProfit: getTakeProfit(for: timeFrame, direction: .short),
                riskReward: getRiskReward(for: timeFrame),
                notes: "Watch for reversal at \(timeFrame.display) resistance"
            )
        ]
    }
    
    // Helper methods for generating price ranges and targets
    private func getPriceRange(for timeFrame: TimeFrame, type: ZoneType) -> String {
        let zone = priceZones.first { $0.type == type && $0.timeFrame == timeFrame }
        guard let price = zone?.price else { return "N/A" }
        
        let spread = switch timeFrame {
        case .minutes15: 0.0005
        case .hour1: 0.0008
        case .hour4: 0.0012
        case .day1: 0.0015
        }
        
        return String(format: "%.4f-%.4f", price - spread, price + spread)
    }
    
    private func getTakeProfit(for timeFrame: TimeFrame, direction: TradeDirection) -> String {
        let currentPrice = 1.0315 // Base price
        
        let (tp1, tp2) = switch timeFrame {
        case .minutes15:
            direction == .long 
                ? (currentPrice + 0.0015, currentPrice + 0.0030)
                : (currentPrice - 0.0015, currentPrice - 0.0030)
        case .hour1:
            direction == .long
                ? (currentPrice + 0.0025, currentPrice + 0.0045)
                : (currentPrice - 0.0025, currentPrice - 0.0045)
        case .hour4:
            direction == .long
                ? (currentPrice + 0.0040, currentPrice + 0.0070)
                : (currentPrice - 0.0040, currentPrice - 0.0070)
        case .day1:
            direction == .long
                ? (currentPrice + 0.0060, currentPrice + 0.0100)
                : (currentPrice - 0.0060, currentPrice - 0.0100)
        }
        
        return String(format: "%.4f, %.4f", tp1, tp2)
    }
    
    private func getRiskReward(for timeFrame: TimeFrame) -> String {
        // Adjust risk/reward based on time frame
        switch timeFrame {
        case .minutes15: return "1:1.5"
        case .hour1: return "1:2"
        case .hour4: return "1:2.5"
        case .day1: return "1:3"
        }
    }
    
    private func loadEconomicCalendar() {
        economicEvents = [
            EconomicEvent(time: "14:30", description: "US NFP Report", impact: "High"),
            EconomicEvent(time: "15:00", description: "ECB Speech", impact: "Medium"),
            EconomicEvent(time: "16:45", description: "FOMC Minutes", impact: "High")
        ]
    }
} 