//
//  ContentView.swift
//  Forex
//
//  Created by Jaccob Humphries on 3/1/2025.
//

import SwiftUI
import Charts
import WebKit

struct CandleStick: Identifiable {
    let id = UUID()
    let date: Date
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    
    var color: Color {
        close >= open ? .green : .red
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var selectedTimeFrame: TimeFrame = .minutes15
    
    var body: some View {
        VStack {
            // TradingView Chart
            WebView(urlString: "https://www.tradingview.com/chart/?symbol=EURUSD")
                .frame(height: 400)
            
            // Time Frame Selector
            Picker("Time Frame", selection: $selectedTimeFrame) {
                ForEach(TimeFrame.allCases) { timeFrame in
                    Text(timeFrame.display).tag(timeFrame)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: selectedTimeFrame) { oldValue, newValue in
                viewModel.updateAnalysis(for: newValue)
            }
            
            // Market Analysis Section
            ScrollView {
                VStack(spacing: 15) {
                    Text("Market Analysis (\(selectedTimeFrame.display))")
                        .font(.title2)
                        .padding(.bottom, 5)
                    
                    // Key Price Levels
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Key Price Levels")
                            .font(.headline)
                        
                        ForEach(viewModel.priceZones) { zone in
                            PriceZoneRow(zone: zone)
                        }
                        
                        if let targetPrice = viewModel.nextTargetPrice {
                            Text("Next Target: \(targetPrice, specifier: "%.4f")")
                                .font(.subheadline)
                                .padding(.top, 2)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Technical Analysis
                    VStack(spacing: 10) {
                        Text("Technical Analysis")
                            .font(.headline)
                        
                        IndicatorRow(name: "RSI", value: viewModel.rsiValue, type: viewModel.rsiValue > 50 ? "Bullish" : "Bearish")
                        IndicatorRow(name: "MACD", value: viewModel.macdValue, type: viewModel.macdValue > 0 ? "Bullish" : "Bearish")
                        IndicatorRow(name: "Moving Average", value: viewModel.maValue, type: viewModel.maValue > 50 ? "Bullish" : "Bearish")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Economic Calendar Events
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Upcoming Market Events")
                            .font(.headline)
                        
                        ForEach(viewModel.economicEvents) { event in
                            HStack {
                                Text(event.time)
                                    .font(.subheadline)
                                Text(event.description)
                                Spacer()
                                Text(event.impact)
                                    .foregroundColor(event.impact == "High" ? .red : .orange)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Trade Setup Analysis
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Potential Trade Setups")
                            .font(.headline)
                        
                        ForEach(viewModel.tradeSetups) { setup in
                            TradeSetupView(setup: setup)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}

struct PriceZoneRow: View {
    let zone: PriceZone
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(zone.type.rawValue)
                    .font(.subheadline)
                    .foregroundColor(zone.type == .resistance ? .red : .green)
                Spacer()
                Text(String(format: "%.4f", zone.price))
                Text("(\(zone.strength.rawValue))")
                    .foregroundColor(zone.strength == .strong ? .red : .orange)
            }
            
            if !zone.notes.isEmpty {
                Text(zone.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct KeyLevelRow: View {
    let type: String
    let price: Double
    let strength: String
    
    var body: some View {
        HStack {
            Text(type)
                .font(.subheadline)
            Spacer()
            Text(String(format: "%.4f", price))
            Text("(\(strength))")
                .foregroundColor(strength == "Strong" ? .red : .orange)
        }
    }
}

struct TradeSetupView: View {
    let setup: TradeSetup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(setup.direction == .long ? "Potential Long Setup" : "Potential Short Setup")
                .font(.subheadline)
                .foregroundColor(setup.direction == .long ? .green : .red)
            
            Text("Entry Zone: \(setup.entryZone)")
            Text("Take Profit: \(setup.takeProfit)")
            Text("Risk/Reward: \(setup.riskReward)")
            
            if !setup.notes.isEmpty {
                Text(setup.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 5)
    }
}

struct WebView: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct IndicatorRow: View {
    let name: String
    let value: Double
    let type: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.headline)
            Spacer()
            Text(type)
                .foregroundColor(type == "Bullish" ? .green : .red)
            Text("\(Int(value))%")
                .font(.subheadline)
                .foregroundColor(type == "Bullish" ? .green : .red)
        }
    }
}

#Preview {
    ContentView()
}
