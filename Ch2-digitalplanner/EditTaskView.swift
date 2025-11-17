import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    let task: Task
    let onSave: (Task) -> Void
    let onDelete: (Task) -> Void
    
    @State private var taskTime: String
    @State private var taskTitle: String
    @State private var taskDate: Date
    @State private var showingDeleteAlert = false
    
    init(task: Task, onSave: @escaping (Task) -> Void, onDelete: @escaping (Task) -> Void) {
        self.task = task
        self.onSave = onSave
        self.onDelete = onDelete
        self._taskTime = State(initialValue: task.time)
        self._taskTitle = State(initialValue: task.title)
        self._taskDate = State(initialValue: task.date)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Time", text: $taskTime)
                    TextField("Task Description", text: $taskTitle)
                }
                
                Section(header: Text("Date")) {
                    DatePicker("Select Date", selection: $taskDate, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                }
                
                Section {
                    Button("Delete Task", role: .destructive) {
                        showingDeleteAlert = true
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Delete Task", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    onDelete(task)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this task?")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        var updatedTask = task
                        updatedTask.time = taskTime
                        updatedTask.title = taskTitle
                        updatedTask.date = taskDate
                        onSave(updatedTask)
                        dismiss()
                    }
                    .disabled(taskTitle.isEmpty)
                }
            }
        }
    }
}
