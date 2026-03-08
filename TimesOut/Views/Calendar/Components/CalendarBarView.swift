import SwiftUI

struct CalendarBarView: View {
    @Binding var selectedDate: Date
    
    // Generate dates for the current week centered around today (or just a scrollable list of next 30 days)
    // For simplicity, let's do a 30-day window centered on today.
    private let dates: [Date] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var tempDates: [Date] = []
        for i in -14...14 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                tempDates.append(date)
            }
        }
        return tempDates
    }()
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                HStack(spacing: 12) {
                    ForEach(dates, id: \.self) { date in
                        DateCell(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate))
                            .onTapGesture {
                                withAnimation {
                                    selectedDate = date
                                }
                            }
                            .id(date)
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    // Scroll to today initially
                    let today = Calendar.current.startOfDay(for: Date())
                    proxy.scrollTo(today, anchor: .center)
                }
            }
        }
        .padding(.vertical, 10)
    }
}

// Sub-component for individual date items
fileprivate struct DateCell: View {
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    let date: Date
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? selectedAccent.color : .secondary)
            
            Text(date.formatted(.dateTime.day()))
                .font(.title3)
                .fontDesign(.monospaced)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .primary : .secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .glassEffect(.clear, in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? selectedAccent.color.opacity(0.8) : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    CalendarBarView(selectedDate: .constant(Date()))
        .withAppTheme()
}
