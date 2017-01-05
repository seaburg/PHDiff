//
//  PHDiff.swift
//  PHDiff
//
//  Created by Andre Alves on 10/13/16.
//  Copyright © 2016 Andre Alves. All rights reserved.
//

import Foundation

/// PHDiff is based on Paul Heckel's paper: A technique for isolating differences between files (1978).
public struct PHDiff {
    /**
     Creates steps (Inserts, Deletes, Moves and Updates) for batch operations.
     
     *Can be used for UITableView, UICollectionView batch updates.*

     Complexity: **O(n+m)** where n is fromArray.count and m is toArray.count.

     - parameter fromArray: The array to calculate the diff from.
     - parameter toArray: The array to calculate the diff to.
     - returns: the steps.
     */
    public static func steps<T: Diffable>(fromArray: [T], toArray: [T]) -> [DiffStep<T>] {
        return PaulHeckelDifference(between: fromArray, and: toArray)
    }

    /**
     Creates sorted steps (Inserts, Deletes and Updates) needed to transform fromArray to toArray.

     Complexity: **O(n+m+d)** where n is fromArray.count, m is toArray.count and d is the number of changes.

     - parameter fromArray: The array to calculate the diff from.
     - parameter toArray: The array to calculate the diff to.
     - returns: the sorted steps.
     */
    public static func sortedSteps<T: Diffable>(fromArray: [T], toArray: [T]) -> [DiffStep<T>] {
        var insertions: [DiffStep<T>] = []
        var updates: [DiffStep<T>] = []
        var indexedDeletions: [[DiffStep<T>]] = Array(repeating: [], count: fromArray.count)

        let unsortedSteps = steps(fromArray: fromArray, toArray: toArray)

        for step in unsortedSteps {
            switch step {
            case .insert:
                insertions.append(step)

            case let .delete(_, fromIndex):
                indexedDeletions[fromIndex].append(step)

            case let .move(value, fromIndex, toIndex):
                // Convert Move to Insert + Delete
                insertions.append(.insert(value: value, index: toIndex))
                indexedDeletions[fromIndex].append(.delete(value: value, index: fromIndex))

            case .update:
                updates.append(step)
            }
        }

        // Insertions need to be sorted asc, batchUpdates already does that.
        // insertions.sort { $0.index < $1.index }

        // Deletions need to be sorted desc.
        let deletions = indexedDeletions.flatMap { $0.first }.reversed()

        return deletions + insertions + updates
    }
}
