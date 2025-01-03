import Foundation
import SwiftUI

struct TradeOpportunity {
    let type: TradeType
    let targetPrice: Double
    let probability: Double
    let timeframe: String
    
    enum TradeType {
        case buy
        case sell
        
        var color: Color {
            self == .buy ? .green : .red
        }
        
        var text: String {
            self == .buy ? "BUY" : "SELL"
        }
    }
} 