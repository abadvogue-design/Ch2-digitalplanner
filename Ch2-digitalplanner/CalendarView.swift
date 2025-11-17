import SwiftUI

struct CalendarView: View {
    let date: Date
    @Binding var selectedDate: Date
    var backgroundColor: Color
    var cardBackground: Color
    var accentColor: Color
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: date)?.count ?? 0
    }
    
    private var firstDayOfMonth: Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    
    private var startingWeekday: Int {
        let components = calendar.dateComponents([.weekday], from: firstDayOfMonth)
        return (components.weekday! - 1 + 7) % 7 // Sunday = 0
    }
    
    private let dayHeaders = ["S", "M", "T", "W", "T", "F", "S"]
    
    init(date: Date, selectedDate: Binding<Date>, backgroundColor: Color = Color(.systemGroupedBackground), cardBackground: Color = Color(.systemBackground), accentColor: Color = Color.blue) {
        self.date = date
        self._selectedDate = selectedDate
        self.backgroundColor = backgroundColor
        self.cardBackground = cardBackground
        self.accentColor = accentColor
    }
    
    var body: some View {
        VStack(spacing: 16) {
            headerView
            dayHeadersView
            calendarGridView
        }
        .padding()
        .background(cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Text(monthYearString)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 20) {
                previousMonthButton
                todayButton
                nextMonthButton
            }
        }
    }
    
    private var previousMonthButton: some View {
        Button(action: navigateToPreviousMonth) {
            Image(systemName: "chevron.left")
                .foregroundColor(accentColor)
                .font(.system(size: 14, weight: .semibold))
        }
    }
    
    private var todayButton: some View {
        Button("Today") {
            selectedDate = Date()
        }
        .foregroundColor(accentColor)
        .font(.system(size: 14, weight: .semibold))
    }
    
    private var nextMonthButton: some View {
        Button(action: navigateToNextMonth) {
            Image(systemName: "chevron.right")
                .foregroundColor(accentColor)
                .font(.system(size: 14, weight: .semibold))
        }
    }
    
    private var dayHeadersView: some View {
        HStack(spacing: 0) {
            ForEach(dayHeaders, id: \.self) { day in
                Text(day)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var calendarGridView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            // Empty cells for days before the first day of month
            ForEach(0..<startingWeekday, id: \.self) { _ in
                Text("")
                    .frame(height: 32)
            }
            
            // Days of the month
            ForEach(1...daysInMonth, id: \.self) { day in
                dayButton(for: day)
            }
        }
    }
    
    private func dayButton(for day: Int) -> some View {
        let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)!
        let isSelected = calendar.isDate(dayDate, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(dayDate)
        
        return Button(action: {
            selectedDate = dayDate
        }) {
            Text("\(day)")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(isSelected ? .white : (isToday ? accentColor : .primary))
                .frame(height: 32)
                .frame(maxWidth: .infinity)
                .background(isSelected ? accentColor : Color.clear)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isToday && !isSelected ? accentColor : Color.clear, lineWidth: 1)
                )
        }
    }
    
    // MARK: - Private Methods
    
    private func navigateToPreviousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: date) {
            selectedDate = newDate
        }
    }
    
    private func navigateToNextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: date) {
            selectedDate = newDate
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(
            date: Date(),
            selectedDate: .constant(Date()),
            backgroundColor: Color(red: 0.95, green: 0.95, blue: 0.97),
            cardBackground: Color.white,
            accentColor: Color.blue
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
