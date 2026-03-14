import SwiftUI

struct SummaryTextRenderer: TextRenderer {
    var progress: Double // 0.0 to 1.0
    
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
    
    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        // Flatten all glyphs into a single list to calculate total count
        let allGlyphs = layout.flatMap { $0 }.flatMap { $0 }
        let glyphCount = allGlyphs.count
        
        var currentGlyphIndex = 0
        
        for line in layout {
            for run in line {
                for glyph in run {
                    // Calculate individual progress for this specific glyph
                    // We stagger them so they appear one by one
                    let stagger: Double = 0.03 // Slightly faster delay between letters
                    let individualDuration: Double = 0.2 // Faster individual letter fade
                    
                    let startAt = Double(currentGlyphIndex) * stagger
                    let endAt = startAt + individualDuration
                    
                    // Normalize the global progress to this glyph's local time window
                    let localProgress = max(0, min(1, (progress - startAt) / individualDuration))
                    
                    var copy = context
                    
                    // Animate opacity: 0 -> 1
                    copy.opacity = localProgress
                    
                    // Animate position: slide up from below
                    let yOffset = 10 * (1.0 - localProgress)
                    copy.translateBy(x: 0, y: yOffset)
                    
                    // Draw the glyph with subpixel precision for smooth motion
                    copy.draw(glyph, options: .disablesSubpixelQuantization)
                    
                    currentGlyphIndex += 1
                }
            }
        }
    }
}

struct DailySummaryBoxView: View {
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    let progress: Double // 0.0 to 1.0
    
    @State private var textRevealProgress: Double = 1.0
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Summary")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text(summaryText)
                    .font(.title2)
                    .fontWeight(.bold)
                    .textRenderer(SummaryTextRenderer(progress: textRevealProgress))
                    .id(summaryText) // Force a fresh redraw/animation when text changes
                
                Text("You're doing great. Keep it up!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Circular Progress Indicator
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 3)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(selectedAccent.color, style: StrokeStyle(lineWidth: 6, lineCap:.round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: progress)
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .fontWidth(.expanded)
                    .textRenderer(SummaryTextRenderer(progress: textRevealProgress))
                    .id(Int(progress * 100)) // Force redraw when number changes
            }
            .frame(width: 70, height: 70)
            .padding(.trailing, 8)
        }
        .padding(25)
        .glassEffect(.regular, in: .rect(cornerRadius: 30))
        .padding(.horizontal)
        .onChange(of: progress) { _, _ in
            // Reset and trigger a staggered reveal
            textRevealProgress = 0
            withAnimation(.linear(duration: 0.6)) { // Snappier total duration
                textRevealProgress = 1.0
            }
        }
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
