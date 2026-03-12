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
        for weekOffset in -52...52 {
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
                            if Calendar.current.component(.day, from: date) == 1 {
                                MonthIndicator(date: date)
                            }
                            
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
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal,50)
                    .frame(width: UIScreen.main.bounds.width)
                    .id(index)
                }
            }
            .scrollTargetLayout()
            .padding(.top, 70)
            .padding(.bottom, 10)
        }
        .contentMargins(.top, 0, for: .scrollContent)
        .overlay {
            HStack {
                Button {
                    if let id = currentScrollID, id > 0 {
                        withAnimation {
                            currentScrollID = id - 1
                        }
                    }
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.body.weight(.bold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .padding(.leading, 10)
                
                Spacer()
                
                Button {
                    if let id = currentScrollID, id < weeks.count - 1 {
                        withAnimation {
                            currentScrollID = id + 1
                        }
                    }
                } label: {
                    Image(systemName: "chevron.forward")
                        .font(.body.weight(.bold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .padding(.trailing, 10)
            }
            .padding(.top, 45) // Adjust to vertically align with the date cells
        }
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 42, bottomTrailingRadius: 42))
        .background {
            RoundedRectangle(cornerRadius: 0, style:.continuous)
                .fill(Color.clear)
                .glassEffect(.regular, in: UnevenRoundedRectangle(bottomLeadingRadius: 42, bottomTrailingRadius: 42))
                .padding(.top, -450)
                .padding(.horizontal,-5)
                .ignoresSafeArea(edges: .top)
        }
        .scrollPosition(id: $currentScrollID)
        .scrollTargetBehavior(.viewAligned)
        .onAppear {
            currentScrollID = 52
        }
        .padding(.bottom, 20) // Only leave bottom external padding
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

fileprivate struct MonthIndicator: View {
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    let date: Date
    
    var body: some View {
        VStack(spacing: 5) {
            Text(date.formatted(.dateTime.month(.defaultDigits)))
                .font(.system(size: 10, weight: .heavy))
                .fontWidth(.expanded)
                .foregroundStyle(Color.primary)
            
            Rectangle()
                .fill(selectedAccent.color)
                .frame(width: 1, height: 18)
                .cornerRadius(1)
        }
        .frame(width: 35) // Fixed width to separate from DateCells
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
                .font(.system(size: 12))
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .primary : .secondary)
            
            Text(date.formatted(.dateTime.day()))
                .font(.system(size: 14))
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
        .frame(height: 55)
        .frame(maxWidth: .infinity)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.clear)
                    .glassEffect(.clear.tint(selectedAccent.color.opacity(0.8)), in: .rect(cornerRadius: 13))
                    .compositingGroup()
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
