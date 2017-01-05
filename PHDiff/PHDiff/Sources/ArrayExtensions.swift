//
//  ArrayExtensions.swift
//  PHDiff
//
//  Created by Andre Alves on 10/13/16.
//  Copyright © 2016 Andre Alves. All rights reserved.
//

import Foundation

public enum DiffError<T: Diffable>: Error {
    case failApplyDiffStep(step: DiffStep<T>)
}

extension Array where Element: Diffable {
    /**
     Computes diffirance `self` from array from argument

     Complexity: **O(n)**.
     */
    public func difference(from array: [Element]) -> [DiffStep<Element>] {
        return PaulHeckelDifference(between: array, and: self)
    }

    /**
     Creates a new array by applying the diff steps.

     Complexity: **O(n)**.

     - parameter steps: The corresponding steps.
     - returns: the new updated array.
     */
    public func apply(steps: [DiffStep<Element>]) throws -> [Element] {
        if steps.count == 0 {
            return self
        }
        let maxInsertIndex = steps.reduce(-1) { (acc, step) -> Int in
            if (!step.isMove && !step.isInsert) {
                return acc
            }
            return step.index > acc ? step.index : acc
        }

        var insertSteps = [DiffStep<Element>?](repeating: nil, count: maxInsertIndex + 1)
        var removed = [Bool](repeating: false, count: self.count)

        for step in steps {
            switch step {
            case let .insert(_, index):
                insertSteps[index] = step
            case let .delete(_, index):
                if index >= self.count {
                    throw DiffError.failApplyDiffStep(step: step)
                }
                removed[index] = true
            case let .move(value, fromIndex, toIndex):
                if fromIndex >= self.count {
                    throw DiffError.failApplyDiffStep(step: step)
                }
                removed[fromIndex] = true
                insertSteps[toIndex] = .insert(value: value, index: toIndex)
            default:
                break
            }
        }

        var newArray: [Element] = []
        var offset = 0
        for i in 0..<insertSteps.count {
            if let insertStep = insertSteps[i] {
                if insertStep.index != newArray.count {
                    throw DiffError.failApplyDiffStep(step: insertStep)
                }
                newArray.append(insertStep.value)
            } else {
                while offset < self.count && removed[offset]  {
                    offset += 1
                }
                if offset < self.count {
                    newArray.append(self[offset])
                }
                offset += 1
            }
        }
        for i in offset..<self.count {
            if !removed[i] {
                newArray.append(self[i])
            }
        }

        for step in steps {
            switch step {
            case let .update(value: value, index: index):
                if index >= newArray.count {
                    throw DiffError.failApplyDiffStep(step: step)
                }
                newArray[index] = value
            default:
                break
            }
        }

        return newArray
    }
}
