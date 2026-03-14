import SwiftUI
import SwiftData

struct TaskSectionBoxView: View {
    let title: String
    let subtitle: String?
    let tasks: [TaskItem]

    var defaultDueDate: Date? = nil
    
    @Environment(\.modelContext) private var modelContext
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    
    // The Box will show up to 2 tasks.
    // Prioritize unfinished tasks. If there are fewer than 2 unfinished, fill the rest with completed.
    private var displayTasks: [TaskItem] {
        let unfinished = tasks.filter { !$0.isCompleted }
            .sorted { $0.priority.rawValue > $1.priority.rawValue }
            
        if unfinished.count >= 2 {
            return Array(unfinished.prefix(2))
        } else {
            let completed = tasks.filter { $0.isCompleted }
                .sorted { $0.priority.rawValue > $1.priority.rawValue }
                
            let combined = unfinished + completed
            return Array(combined.prefix(2))
        }
    }
    
    private var unfinishedCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }
    
    

    var body: some View {
        NavigationLink {
            // Push to the new Detail Workspace
            TaskSectionDetailView(
                title: title,
                subtitle: subtitle,
                tasks: tasks,
                defaultDueDate: defaultDueDate
            )
        } label: {
            // Summary Card UI
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .bottom) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 2)
                    }
                    
                    Spacer()
                    
                    // Ratio of completed / total
                    Text("\(tasks.filter { $0.isCompleted }.count)/\(tasks.count)")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .fontWidth(.expanded)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(selectedAccent.color.opacity(0.8))
                        .foregroundColor(.primary)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                if tasks.isEmpty {
                    HStack{
                        Text("All caught up")
                            .font(.system(size: 20))
                            .fontDesign(.monospaced)
                            .foregroundStyle(.secondary)
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: displayTasks)
                    .padding(30)
                    .padding(.bottom)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(displayTasks) { task in
                            TaskRow(
                                task: task,
                                isEditMode: false,
                                isSelected: false,
                                isBoxView: true,
                                isExpanded: .constant(false),
                                onToggle: {
                                    handleToggle(task: task)
                                },
                                onEdit: {}
                            )
                            .padding(.vertical, 4)
                            .padding(.horizontal, 16)
                            // Prevent the TaskRow tap from triggering the NavigationLink, if necessary,
                            // although buttons inside NavigationLinks usually take priority in SwiftUI.
                        }
                        
                        // Indicate more hidden tasks
                        if unfinishedCount > 2 {
                            Text("+ \(unfinishedCount - 2) more to do")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.top, 4)
                        } else if tasks.count > 2 {
                            Text("+ \(tasks.count - 2) more completed")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.top, 4)
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: displayTasks)
                    .padding(.bottom, 16)
                }
            }
     
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color.clear)
                        .glassEffect(.regular,in: .rect(cornerRadius: 30))
                      //  .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    
                    // Background track for the border
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.secondary.opacity(0.5), lineWidth: 5)
                    
                    // Progress fill overlay
                    let progress: CGFloat = tasks.isEmpty ? 0 : CGFloat(tasks.filter { $0.isCompleted }.count) / CGFloat(tasks.count)
                    
                    TopCenterRoundedRectangle(cornerRadius: 30)
                        .trim(from: 0, to: progress)
                        .stroke(selectedAccent.color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                }
            }
            .padding(.horizontal)
        }
        .buttonStyle(.plain)

    }
    
    private func handleToggle(task: TaskItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            task.isCompleted.toggle()
            if task.isCompleted {
                task.completedAt = Date()
            } else {
                task.completedAt = nil
            }
            try? modelContext.save()
        }
    }
}

struct TopCenterRoundedRectangle: Shape {
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topCenter = CGPoint(x: rect.midX, y: rect.minY)
        path.move(to: topCenter)
        
        // Line to top right corner
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        
        // Top right arc
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(0),
                    clockwise: false)
        
        // Line to bottom right
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        
        // Bottom right arc
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)
        
        // Line to bottom left
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        
        // Bottom left arc
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)
        
        // Line to top left
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        
        // Top left arc
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(180),
                    endAngle: .degrees(270),
                    clockwise: false)
        
        // Back to top center
        path.addLine(to: topCenter)
        
        return path
    }
}

#Preview("Populated") {
    NavigationStack {
        TaskSectionBoxView(
            title: "Daily Tasks",
            subtitle: "Today",
            tasks: [
                TaskItem(title: "Sample Task 1", priority: .high),
                TaskItem(title: "Sample Task 2", priority: .medium)
            ]
        )
    }
    .padding(.vertical)
    .withAppTheme()
    .modelContainer(previewContainer)
}

#Preview("Empty State") {
    NavigationStack {
        TaskSectionBoxView(
            title: "Daily Tasks",
            subtitle: "Today",
            tasks: []
        )
    }
    .withAppTheme()
    .modelContainer(previewContainer)
}
