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
    @State private var bullishProbability: Double = 65
    @State private var bearishProbability: Double = 35
    @State private var tradeSignal: String = "WAIT"
    
    // Sample candlestick data
    @State private var candleData: [CandleStick] = [
        CandleStick(date: Date().addingTimeInterval(-3600 * 24), open: 1.0840, high: 1.0860, low: 1.0830, close: 1.0850),
        CandleStick(date: Date().addingTimeInterval(-3600 * 18), open: 1.0850, high: 1.0870, low: 1.0845, close: 1.0855),
        CandleStick(date: Date().addingTimeInterval(-3600 * 12), open: 1.0855, high: 1.0865, low: 1.0835, close: 1.0840),
        CandleStick(date: Date().addingTimeInterval(-3600 * 6), open: 1.0840, high: 1.0880, low: 1.0840, close: 1.0860),
        CandleStick(date: Date(), open: 1.0860, high: 1.0875, low: 1.0855, close: 1.0865)
    ]
    
    // Add trade opportunities
    @State private var buyOpportunity = TradeOpportunity(
        type: .buy,
        targetPrice: 1.0820,
        probability: 75,
        timeframe: "4H"
    )
    
    @State private var sellOpportunity = TradeOpportunity(
        type: .sell,
        targetPrice: 1.0890,
        probability: 68,
        timeframe: "4H"
    )
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // TradingView Chart
                TradingViewChart()
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.4)
                    .background(Color(.systemBackground))
                    .shadow(radius: 2)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Trade Opportunities Section
                        VStack(spacing: 12) {
                            OpportunityView(opportunity: buyOpportunity)
                            OpportunityView(opportunity: sellOpportunity)
                        }
                        .padding(.horizontal)
                        
                        // Trade Signal Section
                        Text(tradeSignal)
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(signalColor)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(signalColor.opacity(0.1))
                            .cornerRadius(15)
                        
                        // Probability Indicators
                        HStack(spacing: 15) {
                            // Bullish Probability
                            VStack(spacing: 5) {
                                Text("Bullish")
                                    .font(.subheadline)
                                ZStack {
                                    Circle()
                                        .stroke(lineWidth: 6)
                                        .opacity(0.3)
                                        .foregroundColor(.green)
                                    
                                    Circle()
                                        .trim(from: 0.0, to: CGFloat(bullishProbability) / 100)
                                        .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                                        .foregroundColor(.green)
                                        .rotationEffect(.degrees(-90))
                                    
                                    Text("\(Int(bullishProbability))%")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .frame(width: 70, height: 70)
                            }
                            
                            // Bearish Probability
                            VStack(spacing: 5) {
                                Text("Bearish")
                                    .font(.subheadline)
                                ZStack {
                                    Circle()
                                        .stroke(lineWidth: 6)
                                        .opacity(0.3)
                                        .foregroundColor(.red)
                                    
                                    Circle()
                                        .trim(from: 0.0, to: CGFloat(bearishProbability) / 100)
                                        .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                                        .foregroundColor(.red)
                                        .rotationEffect(.degrees(-90))
                                    
                                    Text("\(Int(bearishProbability))%")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .frame(width: 70, height: 70)
                            }
                        }
                        .padding(.vertical, 10)
                        
                        // Indicator List
                        VStack {
                            IndicatorRow(name: "Moving Averages", value: 65, type: "Bullish")
                            IndicatorRow(name: "RSI", value: 45, type: "Bearish")
                            IndicatorRow(name: "MACD", value: 75, type: "Bullish")
                            IndicatorRow(name: "Pattern", value: 30, type: "Bearish")
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("EUR/USD Analysis")
        }
    }
    
    private var signalColor: Color {
        switch tradeSignal {
        case "BUY":
            return .green
        case "SELL":
            return .red
        default:
            return .orange
        }
    }
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
