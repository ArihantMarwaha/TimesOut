import SwiftUI

struct PriorityPicker: View {
    @Binding var selection: TaskPriority
    @Namespace private var animation
    @State private var localSelection: TaskPriority
    
    init(selection: Binding<TaskPriority>) {
        self._selection = selection
        self._localSelection = State(initialValue: selection.wrappedValue)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TaskPriority.allCases) { priority in
                let isSelected = localSelection == priority
                
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        localSelection = priority
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        selection = priority
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: priority.icon)
                            .font(.system(size: 14, weight: .bold))
                        
                        Text(priority.title)
                            .font(.caption)
                            .fontWidth(.expanded)
                            .fontWeight(isSelected ? .bold : .medium)
                    }
                    .foregroundColor(isSelected ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(priority.color)
                                .shadow(color: priority.color.opacity(0.3), radius: 4, x: 0, y: 2)
                                .matchedGeometryEffect(id: "PRIORITY_TAB", in: animation)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color(uiColor: .tertiarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onChange(of: selection) { _, newValue in
            if localSelection != newValue {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    localSelection = newValue
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PriorityPicker(selection: .constant(.low))
        PriorityPicker(selection: .constant(.medium))
        PriorityPicker(selection: .constant(.high))
    }
    .padding()
    .withAppTheme()
}
