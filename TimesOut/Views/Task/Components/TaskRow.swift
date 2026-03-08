import SwiftUI

struct TaskRow: View {
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    let task: TaskItem
    var isEditMode: Bool = false
    var isSelected: Bool = false
    let onToggle: () -> Void
    var onEdit: (() -> Void)? = nil
    
    private var isOverdue: Bool {
        if let dueDate = task.dueDate {
            return dueDate < Date() && !task.isCompleted
        }
        return false
    }

    var body: some View {
        HStack(spacing: 16) {
            // Multi-select circle (edit mode) or completion checkbox (normal mode)
            Image(systemName: isEditMode
                  ? (isSelected ? "checkmark.circle.fill" : "circle")
                  : (task.isCompleted ? "checkmark.square.fill" : "square"))
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(isEditMode
                             ? (isSelected ? .red : .secondary)
                             : (task.isCompleted ? selectedAccent.color : .gray))
            .contentTransition(.symbolEffect(.replace))
            .frame(width: 28, height: 28)
            
            // Task title and details
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.title3)
                    .fontDesign(.monospaced)
                    .fontWeight(.medium)
                    .strikethrough(!isEditMode && task.isCompleted)
                    .foregroundColor((!isEditMode && task.isCompleted) ? .gray : .primary)
                
                HStack(spacing: 8) {
                    // Due Date Indicator
                    if let dueDate = task.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar.badge.clock")
                            Text(dueDate, format: .dateTime.month(.abbreviated).day().hour().minute())
                        }
                        .font(.caption2)
                        .fontWidth(.expanded)
                        .foregroundColor(isOverdue ? .red : .white)
                        .padding(.horizontal,5)
                        .padding(.vertical,4)
                        .glassEffect(.clear.tint(isOverdue ?  .black.opacity(0.6): task.priority.color),in: .rect(cornerRadius: 6))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Trailing Edge: Priority Icon (Normal Mode) OR Edit Button (Edit Mode)
            Button {
                onEdit?()
            } label: {
                Image(systemName: isEditMode ? "square.and.pencil" : (isOverdue ? "xmark.circle.fill" : task.priority.icon))
                    .font(isEditMode ? .title2 : .title3)
                    .fontWeight(.bold)
                    .foregroundColor(isEditMode ? .secondary : (task.isCompleted ? .gray : (isOverdue ? .red : task.priority.color)))
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .allowsHitTesting(isEditMode)
        }
        .opacity((isOverdue && !isEditMode) ? 0.6 : 1.0)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isEditMode)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    VStack(spacing: 20) {
        TaskRow(task: TaskItem(title: "Normal Task", priority: .medium), isEditMode: false, isSelected: false, onToggle: {})
        
        TaskRow(task: TaskItem(title: "Upcoming Task", priority: .high, dueDate: Date().addingTimeInterval(3600)), isEditMode: false, isSelected: false, onToggle: {})
        
        TaskRow(task: TaskItem(title: "Overdue Task", priority: .high, dueDate: Date().addingTimeInterval(-3600)), isEditMode: false, isSelected: false, onToggle: {})
        
        TaskRow(task: TaskItem(title: "Completed Task", isCompleted: true, priority: .low, dueDate: Date().addingTimeInterval(-3600)), isEditMode: false, isSelected: false, onToggle: {})
        
        Divider()
        
        TaskRow(task: TaskItem(title: "Edit mode unselected"), isEditMode: true, isSelected: false, onToggle: {})
        
        TaskRow(task: TaskItem(title: "Edit mode selected"), isEditMode: true, isSelected: true, onToggle: {})
    }
    .padding()
    .withAppTheme()
}
