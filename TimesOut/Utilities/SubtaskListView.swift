import SwiftUI

// A shared component to manage subtasks that flattens into individual rows when used in a Form Section.
// Constraints: T must be Identifiable for stable row animations.
struct SubtaskListView<T: Identifiable>: View {
    @Binding var items: [T]
    let accentColor: Color
    let placeholder: String
    let canToggle: Bool
    let onCreate: (String) -> T
    let onToggle: ((Binding<T>) -> Void)?
    let getTitle: (T) -> String
    let setTitle: (inout T, String) -> Void
    let isCompleted: ((T) -> Bool)?
    let onSettings: ((Binding<T>) -> Void)? // Callback for configuring task details
    
    @State private var newTitle = ""
    
    init(
        items: Binding<[T]>,
        accentColor: Color,
        placeholder: String,
        canToggle: Bool,
        onCreate: @escaping (String) -> T,
        onToggle: ((Binding<T>) -> Void)? = nil,
        getTitle: @escaping (T) -> String,
        setTitle: @escaping (inout T, String) -> Void,
        isCompleted: ((T) -> Bool)? = nil,
        onSettings: ((Binding<T>) -> Void)? = nil
    ) {
        self._items = items
        self.accentColor = accentColor
        self.placeholder = placeholder
        self.canToggle = canToggle
        self.onCreate = onCreate
        self.onToggle = onToggle
        self.getTitle = getTitle
        self.setTitle = setTitle
        self.isCompleted = isCompleted
        self.onSettings = onSettings
    }
    
    var body: some View {
        // "Add" Field - Top level in the Section, becomes its own row
        HStack(spacing: 12) {
            Image(systemName: "circle.dashed")
                .font(.system(size: 23))
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $newTitle)
                .font(.system(size: 18))
                .fontDesign(.monospaced)
                .fontWeight(.regular)
                .onSubmit { addItem() }
            
            if !newTitle.isEmpty {
                Button(action: addItem) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 23))
                        .foregroundColor(accentColor)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.vertical, 4) // Adjust for standard row height
        
        // List of Existing Items - Top level in the Section, ForEach generates individual rows
        ForEach(items) { item in
            HStack(spacing: 12) {
                if canToggle, let isComp = isCompleted {
                    Button {
                        if let index = items.firstIndex(where: { $0.id == item.id }) {
                            onToggle?($items[index])
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    } label: {
                        Image(systemName: isComp(item) ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 23))
                            .foregroundColor(isComp(item) ? accentColor : .secondary)
                    }
                    .buttonStyle(.plain)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                        .frame(width: 23)
                }
                
                let isComp = isCompleted?(item) ?? false
                
                TextField("Subtask", text: Binding(
                    get: { getTitle(item) },
                    set: { newVal in
                        if let index = items.firstIndex(where: { $0.id == item.id }) {
                            setTitle(&items[index], newVal)
                        }
                    }
                ))
                .font(.system(size: 18))
                .fontDesign(.monospaced)
                .strikethrough(isComp)
                .foregroundColor(isComp ? .secondary : .primary)
                
                Spacer()
                
                if onSettings != nil {
                    Button {
                        if let index = items.firstIndex(where: { $0.id == item.id }) {
                            onSettings?($items[index])
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 15))
                            .foregroundColor(accentColor)
                            .padding(8)
                            .background(accentColor.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        items.removeAll { $0.id == item.id }
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 23))
                        .foregroundColor(.red.opacity(0.8))
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4) // Matches "Add" row height
            .transition(.asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .opacity.combined(with: .scale(scale: 0.95))
            ))
        }
        // Animation is triggered by items change, but individual row animations are handled by Form/List
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: items.map { $0.id as AnyHashable })
    }
    
    private func addItem() {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Append to end of list as in TaskFormView code
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            items.append(onCreate(trimmed))
            newTitle = ""
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

// Specializations for easier use

extension SubtaskListView where T == DraftSubtask {
    static func forTasks(subtasks: Binding<[DraftSubtask]>, accentColor: Color) -> some View {
        SubtaskListView<DraftSubtask>(
            items: subtasks,
            accentColor: accentColor,
            placeholder: "New subtask",
            canToggle: true,
            onCreate: { DraftSubtask(title: $0) },
            onToggle: { $0.wrappedValue.isCompleted.toggle() },
            getTitle: { $0.title },
            setTitle: { $0.title = $1 },
            isCompleted: { $0.isCompleted }
        )
    }
}

extension SubtaskListView where T == DraftRoutineTask {
    static func forRoutineTasks(tasks: Binding<[DraftRoutineTask]>, accentColor: Color, onSettings: @escaping (Binding<DraftRoutineTask>) -> Void) -> some View {
        SubtaskListView<DraftRoutineTask>(
            items: tasks,
            accentColor: accentColor,
            placeholder: "New routine step",
            canToggle: false,
            onCreate: { DraftRoutineTask(title: $0) },
            onToggle: nil,
            getTitle: { $0.title },
            setTitle: { $0.title = $1 },
            isCompleted: nil,
            onSettings: onSettings
        )
    }
}

#Preview {
    Form {
        Section("Subtasks") {
            SubtaskListView<DraftSubtask>.forTasks(subtasks: .constant([
                DraftSubtask(title: "Done", isCompleted: true),
                DraftSubtask(title: "Todo", isCompleted: false)
            ]), accentColor: Color.blue)
        }
    }
    .withAppTheme()
}
