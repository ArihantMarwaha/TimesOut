import SwiftUI

struct DailySummaryBoxView: View {
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    let progress: Double // 0.0 to 1.0
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Summary")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text(summaryText)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("You're doing great. Keep it up!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Circular Progress Indicator
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(selectedAccent.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: progress)
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .fontDesign(.monospaced)
            }
            .frame(width: 60, height: 60)
            .padding(.trailing, 8)
        }
        .padding(20)
        .glassEffect(.clear, in: .rect(cornerRadius: 24))
        .padding(.horizontal)
    }
    
    private var summaryText: String {
        if progress == 0 { return "Let's Start!" }
        if progress < 0.5 { return "Making Progress" }
        if progress < 1.0 { return "Almost There" }
        return "All Done!"
    }
}

#Preview {
    VStack {
        DailySummaryBoxView(progress: 0.0)
        DailySummaryBoxView(progress: 0.45)
        DailySummaryBoxView(progress: 1.0)
    }
    .withAppTheme()
}
