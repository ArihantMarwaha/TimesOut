import SwiftUI

struct CalendarBarView: View {
    @Binding var selectedDate: Date
    @State private var localSelectedDate: Date
    
    @State private var currentScrollID: Int?
    @Namespace private var animation
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        self._localSelectedDate = State(initialValue: selectedDate.wrappedValue)
    }
    
    // Generate an array of weeks. Each week is an array of 7 Dates.
    // For simplicity, generate 5 weeks centered around the current week.
    private let weeks: [[Date]] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Find the start of the current week (e.g., Sunday or Monday depending on locale)
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return []
        }
        
        var tempWeeks: [[Date]] = []
        for weekOffset in -2...2 {
            var weekDates: [Date] = []
            if let thisWeekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startOfWeek) {
                for dayOffset in 0..<7 {
                    if let date = calendar.date(byAdding: .day, value: dayOffset, to: thisWeekStart) {
                        weekDates.append(date)
                    }
                }
            }
            tempWeeks.append(weekDates)
        }
        return tempWeeks
    }()
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(Array(weeks.enumerated()), id: \.offset) { index, week in
                    HStack(spacing: 0) {
                        ForEach(week, id: \.self) { date in
                            DateCell(
                                date: date,
                                isSelected: Calendar.current.isDate(date, inSameDayAs: localSelectedDate),
                                animation: animation
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    localSelectedDate = date
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    selectedDate = date
                                }
                            }
                            .frame(maxWidth: .infinity) // Distribute evenly
                        }
                    }
                    .padding(.horizontal,20)
                    .frame(width: UIScreen.main.bounds.width)
                    .id(index)
                }
            }
            .scrollTargetLayout()
            .padding(.top, 60)
            .padding(.bottom, 10)
        }
        .contentMargins(.top, 0, for: .scrollContent)
        // Use the same radius as the user set for the glass effect (52)
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 32, bottomTrailingRadius: 32))
        .background {
            RoundedRectangle(cornerRadius: 0, style:.continuous)
                .fill(Color.clear)
                .glassEffect(.regular, in: UnevenRoundedRectangle(bottomLeadingRadius: 32, bottomTrailingRadius: 32))
                .padding(.top, -500)
                .padding(.horizontal,-2)
                .ignoresSafeArea(edges: .top)

        }

        .scrollPosition(id: $currentScrollID)
        .scrollTargetBehavior(.viewAligned)
        .onAppear {
            currentScrollID = 2
        }
        .padding(.bottom, 10) // Only leave bottom external padding
        .fixedSize(horizontal: false, vertical: true)
        .onChange(of: selectedDate) { _, newValue in
            if !Calendar.current.isDate(localSelectedDate, inSameDayAs: newValue) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    localSelectedDate = newValue
                }
            }
        }
    }
}

fileprivate struct DateCell: View {
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    let date: Date
    let isSelected: Bool
    var animation: Namespace.ID
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text(date.formatted(.dateTime.weekday(.narrow)))
                .fontWeight(isSelected ? .bold : .light)
                .fontWidth(.expanded)
                .font(.system(size: 16))
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .primary : .secondary)
            
            Text(date.formatted(.dateTime.day()))
                .font(.system(size: 15))
                .fontWidth(.expanded)
                .fontWeight(isSelected ? .bold : .thin)
                .foregroundColor(isSelected ? .primary : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            // Indicator for today
            RoundedRectangle(cornerRadius: 10)
                .fill(isToday ? (isSelected ? .primary.opacity(0.8) : selectedAccent.color) : Color.clear)
                .frame(width: 8, height: 2)
        }
        .frame(minWidth: 45, minHeight: 60) // Fixed size for uniform capsule
        .padding(.vertical, 0)
        .background {
            if isSelected {
                Color.clear
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .glassEffect(.clear.tint(selectedAccent.color.opacity(0.7)),in:.rect(cornerRadius: 10))
                    .matchedGeometryEffect(id: "CALENDAR_SELECTION", in: animation)
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    CalendarBarView(selectedDate: .constant(Date()))
        .withAppTheme()
}
