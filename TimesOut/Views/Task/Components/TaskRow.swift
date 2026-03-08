import SwiftUI

struct TaskRow: View {
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    let task: TaskItem
    var isEditMode: Bool = false
    var isSelected: Bool = false
    let onToggle: () -> Void
    var onEdit: (() -> Void)? = nil
    
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
                        .font(.caption)
                        .foregroundColor((dueDate < Date() && !task.isCompleted) ? .red : .secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Trailing Edge: Priority Icon (Normal Mode) OR Edit Button (Edit Mode)
            Button {
                onEdit?()
            } label: {
                Image(systemName: isEditMode ? "square.and.pencil" : task.priority.icon)
                    .font(isEditMode ? .title2 : .title3)
                    .fontWeight(.bold)
                    .foregroundColor(isEditMode ? .secondary : (task.isCompleted ? .gray : task.priority.color))
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .allowsHitTesting(isEditMode)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isEditMode)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    VStack {
        TaskRow(task: TaskItem(title: "Normal mode"), isEditMode: false, isSelected: false, onToggle: {})
        TaskRow(task: TaskItem(title: "Edit mode unselected"), isEditMode: true, isSelected: false, onToggle: {})
        TaskRow(task: TaskItem(title: "Edit mode selected"), isEditMode: true, isSelected: true, onToggle: {})
    }
    .padding()
    .withAppTheme()
}
