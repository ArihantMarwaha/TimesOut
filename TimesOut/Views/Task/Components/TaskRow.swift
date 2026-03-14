import SwiftUI
import SwiftData

struct TaskRow: View {
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    let task: TaskItem
    var isEditMode: Bool = false
    var isSelected: Bool = false
    var isBoxView: Bool = false
    @Binding var isExpanded: Bool
    let onToggle: () -> Void
    var onEdit: (() -> Void)? = nil
    
    private var isOverdue: Bool {
        if let dueDate = task.dueDate {
            return dueDate < Date() && !task.isCompleted
        }
        return false
    }
    
    private var hasSubtasks: Bool {
        guard let subtasks = task.subtasks else { return false }
        return !subtasks.isEmpty
    }

    @ViewBuilder
    private var rowContent: some View {
        HStack(spacing: 16) {
            // Multi-select circle (edit mode) or completion checkbox (normal mode)
            Image(systemName: isEditMode
                  ? (isSelected ? "checkmark.circle.fill" : "circle")
                  : (task.isCompleted ? "checkmark.square.fill" : "square"))
            .font(.title)
            .fontWeight(.medium)
            .foregroundColor(isEditMode
                             ? (isSelected ? .red : .secondary)
                             : (task.isCompleted ? selectedAccent.color : .gray))
            .contentTransition(.symbolEffect(.replace))
            .frame(width: 28, height: 28)
            .contentShape(Rectangle())
            .onTapGesture {
                onToggle()
            }
            
            // Task title and details
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.system(size: 20))
                    .fontDesign(.monospaced)
                    .fontWeight(.medium)
                    .strikethrough(!isEditMode && task.isCompleted)
                    .foregroundColor((!isEditMode && task.isCompleted) ? .gray : .primary)
                
                HStack(spacing: 8) {
                    // Due Date Indicator
                    if let dueDate = task.dueDate {
                        let isEndOfDay = Calendar.current.component(.hour, from: dueDate) == 23 && Calendar.current.component(.minute, from: dueDate) == 59
                        HStack(spacing: 4) {
                            Image(systemName: "calendar.badge.clock")
                            if isEndOfDay {
                                Text(dueDate, format: .dateTime.month(.abbreviated).day())
                            } else {
                                Text(dueDate, format: .dateTime.month(.abbreviated).day().hour().minute())
                            }
                        }
                        .font(.system(size: 10))
                        .fontWidth(.expanded)
                        .foregroundColor(isOverdue ? .red : .white)
                        .padding(.horizontal,5)
                        .padding(.vertical,4)
                        .glassEffect(.clear.tint(isOverdue ?  .black.opacity(0.6): task.priority.color),in: .rect(cornerRadius: 6))
                    }
                    
                    // Subtask Indicator
                    if let subtasks = task.subtasks, !subtasks.isEmpty {
                        let completedCount = subtasks.filter { $0.isCompleted }.count
                        HStack(spacing: 4) {
                            Image(systemName: "checklist")
                            Text("\(completedCount)/\(subtasks.count)")
                        }
                        .font(.system(size: 10))
                        .fontWidth(.expanded)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 4)
                        .glassEffect(.clear, in: .rect(cornerRadius: 6))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Trailing Edge: Priority Icon / Edit Button / Chevron
            Button {
                if isEditMode {
                    onEdit?()
                } else if hasSubtasks && !isBoxView {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } else {
                    onEdit?()
                }
            } label: {
                if isEditMode {
                    Image(systemName: "square.and.pencil")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                } else if hasSubtasks && !isBoxView {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(task.priority.color)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                } else {
                    Image(systemName: isOverdue ? "xmark.circle.fill" : task.priority.icon)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(task.isCompleted ? .gray : (isOverdue ? .red : task.priority.color))
                }
            }
            .buttonStyle(.plain)
            .allowsHitTesting(isEditMode || (hasSubtasks && !isBoxView))
            .contentTransition(.symbolEffect(.replace))
            .frame(width: 28, height: 28)
        }
        .opacity((isOverdue && !isEditMode) ? 0.6 : 1.0)
        .contentShape(Rectangle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isEditMode)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isSelected)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: task.isCompleted)
    }

    var body: some View {
        if isBoxView {
            rowContent
        } else {
            rowContent
                .onTapGesture {
                    if !isEditMode && hasSubtasks {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    } else {
                        onToggle()
                    }
                }
        }
    }
}

// MARK: - Subtask Row (rendered as separate List rows by the parent)

struct SubtaskRow: View {
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    @Environment(\.modelContext) private var modelContext
    let subtask: SubtaskItem
    let parentTask: TaskItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundColor(subtask.isCompleted ? selectedAccent.color : .secondary)
            
            Text(subtask.title)
                .strikethrough(subtask.isCompleted)
                .foregroundColor(subtask.isCompleted ? .secondary : .primary)
                .font(.system(size: 16))
                .fontDesign(.monospaced)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 28)
        .contentShape(Rectangle())
        .onTapGesture {
            toggleSubtask()
        }
    }
    
    private func toggleSubtask() {
        withAnimation(.easeInOut(duration: 0.2)) {
            subtask.isCompleted.toggle()
            
            if let allSubtasks = parentTask.subtasks {
                let allCompleted = allSubtasks.allSatisfy { $0.isCompleted }
                if allCompleted && !parentTask.isCompleted {
                    parentTask.isCompleted = true
                    parentTask.completedAt = Date()
                } else if !allCompleted && parentTask.isCompleted {
                    parentTask.isCompleted = false
                    parentTask.completedAt = nil
                }
            }
            
            try? modelContext.save()
        }
    }
}

#Preview {
    @Previewable @State var expanded1 = false
    @Previewable @State var expanded2 = false
    @Previewable @State var expanded3 = false
    @Previewable @State var expanded4 = false
    @Previewable @State var expanded5 = true
    @Previewable @State var expanded6 = false
    @Previewable @State var expanded7 = false

    VStack(spacing: 20) {
        TaskRow(task: TaskItem(title: "Normal Task", priority: .medium), isEditMode: false, isSelected: false, isExpanded: $expanded1, onToggle: {})
        
        TaskRow(task: TaskItem(
            title: "Task with Subtasks",
            priority: .high,
            subtasks: [
                SubtaskItem(title: "First subtask", isCompleted: true),
                SubtaskItem(title: "Second subtask", isCompleted: false)
            ]
        ), isEditMode: false, isSelected: false, isExpanded: $expanded5, onToggle: {})
        
        TaskRow(task: TaskItem(title: "Upcoming Task", priority: .high, dueDate: Date().addingTimeInterval(3600)), isEditMode: false, isSelected: false, isExpanded: $expanded2, onToggle: {})
        
        TaskRow(task: TaskItem(title: "Overdue Task", priority: .high, dueDate: Date().addingTimeInterval(-3600)), isEditMode: false, isSelected: false, isExpanded: $expanded3, onToggle: {})
        
        TaskRow(task: TaskItem(title: "Completed Task", isCompleted: true, priority: .low, dueDate: Date().addingTimeInterval(-3600)), isEditMode: false, isSelected: false, isExpanded: $expanded4, onToggle: {})
        
        Divider()
        
        TaskRow(task: TaskItem(title: "Edit mode unselected"), isEditMode: true, isSelected: false, isExpanded: $expanded6, onToggle: {})
        
        TaskRow(task: TaskItem(title: "Edit mode selected"), isEditMode: true, isSelected: true, isExpanded: $expanded7, onToggle: {})
    }
    .padding()
    .withAppTheme()
}
