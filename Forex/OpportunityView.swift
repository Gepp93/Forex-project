import SwiftUI

struct OpportunityView: View {
    let opportunity: TradeOpportunity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Next \(opportunity.type.text) Opportunity")
                    .font(.headline)
                    .foregroundColor(opportunity.type.color)
                Spacer()
                Text(opportunity.timeframe)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Target Price")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(String(format: "%.4f", opportunity.targetPrice))
                        .font(.title2)
                        .bold()
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Probability")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("\(Int(opportunity.probability))%")
                        .font(.title2)
                        .bold()
                        .foregroundColor(opportunity.type.color)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemBackground))
            .shadow(radius: 2))
    }
} 