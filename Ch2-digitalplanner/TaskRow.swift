import SwiftUI

struct TaskRow: View {
    let task: Task
    var onUpdate: (Task) -> Void
    var onEdit: (Task) -> Void
    var onReminder: (Task) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            if !task.time.isEmpty {
                Text(task.time)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(width: 60, alignment: .leading)
            }
            
            Button(action: { toggleCompletion() }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(task.title)
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? .secondary : .primary)
                    
                    if task.hasReminder {
                        Image(systemName: "bell.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
                
                // FIXED: Better date display
                Text(formatDate(task.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { onReminder(task) }) {
                Image(systemName: task.hasReminder ? "bell.fill" : "bell")
                    .foregroundColor(task.hasReminder ? .orange : .blue)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: { onEdit(task) }) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
    }
    
    private func toggleCompletion() {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        onUpdate(updatedTask)
    }
    
    // FIXED: Better date formatting
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        // Show "Today" for current date
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            return formatter.string(from: date)
        }
    }
}
