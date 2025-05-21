import Foundation

extension Collection {
    /// Returns true if collection is not empty
    var isNotEmpty: Bool {
        return !self.isEmpty
    }

    /// Safely get element at specified index
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
