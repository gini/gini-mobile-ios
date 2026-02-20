//
//  Array+Extensions.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


extension Array {
    
    /**
     * Removes duplicate elements from the array based on a specified key.
     *
     * This method maintains the order of elements, keeping the first occurrence
     * of each unique element and removing subsequent duplicates.
     *
     * - Parameter transform: A closure that transforms each element into a
     *   `Hashable` value used for uniqueness comparison.
     * - Returns: A new array containing only unique elements based on the
     *   specified key, preserving the original order.
     *
     * Example:
     * ```swift
     * let paymentProviders = [provider1, provider2, provider1, provider3]
     * let uniqueProviders = paymentProviders.uniqued(by: { $0.id })
     * ```
     */
    public func uniqued<T: Hashable>(by transform: (Element) -> T) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert(transform($0)).inserted }
    }
}
