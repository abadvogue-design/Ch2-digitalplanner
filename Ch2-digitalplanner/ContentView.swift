import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var tasks: [Task] = [
        Task(time: "5:00am", title: "Sam workout", date: Date()),
        Task(time: "8:00am", title: "Business Deep Work", date: Date()),
        Task(time: "", title: "Post Post Workout Routine", date: Date()),
        Task(time: "10:00am", title: "Dentist", date: Date())
    ]
    
    @State private var showingAddTask = false
    @State private var currentDate = Date()
    @State private var editingTask: Task?
    @State private var showSplash = true
    
    // FIXED: Computed property to filter tasks by selected date
    var filteredTasks: [Task] {
        tasks.filter { task in
            Calendar.current.isDate(task.date, inSameDayAs: currentDate)
        }
        .sorted { $0.date < $1.date } // Sort by date
    }
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreen()
                    .transition(.opacity)
            } else {
                NavigationView {
                    ZStack {
                        Color(.systemGray6).ignoresSafeArea()
                        
                        VStack(spacing: 0) {
                            // Header
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Planner")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                HStack {
                                    Text(currentDate, style: .date)
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    Spacer()
                                    
                                    DatePicker("", selection: $currentDate, displayedComponents: [.date])
                                        .labelsHidden()
                                        .datePickerStyle(.compact)
                                        .colorScheme(.dark)
                                        .onChange(of: currentDate) { _ in
                                            // Refresh when date changes
                                        }
                                }
                            }
                            .padding()
                            .background(Color.blue)
                            
                            // Tasks List - FIXED: Use filteredTasks
                            if filteredTasks.isEmpty {
                                VStack(spacing: 20) {
                                    Spacer()
                                    Image(systemName: "calendar.badge.plus")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                    Text("No tasks for \(formatHeaderDate(currentDate))")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                            } else {
                                List {
                                    ForEach(filteredTasks) { task in
                                        TaskRow(
                                            task: task,
                                            onUpdate: updateTask,
                                            onEdit: { editingTask = $0 },
                                            onReminder: { setReminder(for: $0) }
                                        )
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                deleteTask(task)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                                .listStyle(PlainListStyle())
                            }
                            
                            // Bottom Navigation
                            HStack {
                                Button("Added the Task") { }
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                        }
                        
                        // Add Button
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: { showingAddTask = true }) {
                                    Image(systemName: "plus")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 60, height: 60)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                                .padding(.trailing, 20)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                    .navigationBarHidden(true)
                    .sheet(isPresented: $showingAddTask) {
                        AddTaskView(
                            isPresented: $showingAddTask,
                            selectedDate: currentDate,
                            onAdd: addTask
                        )
                    }
                    .sheet(item: $editingTask) { task in
                        EditTaskView(task: task, onSave: updateTask, onDelete: deleteTask)
                    }
                    .onAppear {
                        requestNotificationPermission()
                    }
                }
            }
        }
        .onAppear {
            // Show splash screen for 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
    
    // FIXED: Updated to accept date parameter
    private func addTask(time: String, title: String, date: Date) {
        let newTask = Task(time: time, title: title, date: date)
        tasks.append(newTask)
    }
    
    // FIXED: Better update function that triggers UI refresh
    private func updateTask(_ updatedTask: Task) {
        if let index = tasks.firstIndex(where: { $0.id == updatedTask.id }) {
            tasks[index] = updatedTask
            // Force UI refresh by toggling a state change
            let tempTasks = tasks
            tasks = []
            tasks = tempTasks
        }
    }
    
    private func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
    }
    
    // FIXED: Better date formatting for header
    private func formatHeaderDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateStyle = .full
            return formatter.string(from: date)
        }
    }
    
    // MARK: - Reminder Methods (unchanged)
    private func setReminder(for task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].hasReminder.toggle()
            
            if tasks[index].hasReminder {
                #if targetEnvironment(simulator)
                showSimulatorAlert(for: tasks[index])
                #else
                scheduleNotification(for: tasks[index])
                #endif
            }
        }
    }
    
    private func scheduleNotification(for task: Task) {
        let content = UNMutableNotificationContent()
        content.title = "🔔 Task Reminder"
        content.body = "\(task.time.isEmpty ? "Task" : task.time): \(task.title)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: task.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    showAlert(title: "Error", message: "Failed to set reminder")
                } else {
                    print("Reminder set for: \(task.title)")
                    showAlert(title: "Reminder Set!", message: "You'll be reminded about '\(task.title)' in 5 seconds")
                }
            }
        }
    }
    
    private func requestNotificationPermission() {
        #if !targetEnvironment(simulator)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification error: \(error.localizedDescription)")
            }
        }
        #endif
    }
    
    private func showSimulatorAlert(for task: Task) {
        showAlert(
            title: "Reminder Set! (Simulator)",
            message: "On a real device, you'd be reminded about '\(task.title)' in 5 seconds. Notifications don't work on simulator."
        )
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
}
