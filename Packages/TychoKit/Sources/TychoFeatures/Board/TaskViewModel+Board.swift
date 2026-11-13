import TychoCore

extension TaskViewModel {
    func setVisible(_ visible: Bool, for status: TaskStatus) {
        var next = state
        next.setVisible(visible, for: status)
        state = next
    }
}
