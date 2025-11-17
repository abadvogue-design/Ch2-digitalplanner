import SwiftUI

struct AddTaskView: View {
    @Binding var isPresented: Bool
    let selectedDate: Date
    let onAdd: (String, String, Date) -> Void
    
    @State private var taskTime = ""
    @State private var taskTitle = ""
    @State private var taskDate: Date
    
    init(isPresented: Binding<Bool>, selectedDate: Date, onAdd: @escaping (String, String, Date) -> Void) {
        self._isPresented = isPresented
        self.selectedDate = selectedDate
        self.onAdd = onAdd
        self._taskDate = State(initialValue: selectedDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task Title", text: $taskTitle)
                    TextField("Time (e.g., 9:00 AM)", text: $taskTime)
                }
                
                Section(header: Text("Date")) {
                    DatePicker("Select Date", selection: $taskDate, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                }
            }
            .navigationTitle("Add New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        onAdd(taskTime, taskTitle, taskDate)
                        isPresented = false
                    }
                    .disabled(taskTitle.isEmpty)
                }
            }
        }
    }
}
