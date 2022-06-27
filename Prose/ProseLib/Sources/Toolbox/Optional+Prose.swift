public extension Optional {
    /// Either returns the unwrapped value or prints `message` and stops execution of the program.
    func expect(_ message: String) -> Wrapped {
        guard let value = self else {
            fatalError(message)
        }
        return value
    }
}
