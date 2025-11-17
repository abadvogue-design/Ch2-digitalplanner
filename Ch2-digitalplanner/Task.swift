import Foundation

struct Task: Identifiable, Hashable {
    let id = UUID()
    var time: String
    var title: String
    var date: Date
    var isCompleted: Bool = false
    var hasReminder: Bool = false
}
