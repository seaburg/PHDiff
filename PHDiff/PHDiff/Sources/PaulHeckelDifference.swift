//
//  PaulHeckelDifference.swift
//  PaulHeckelDifference
//
//  Created by Andre Alves on 10/13/16.
//  Copyright © 2016 Andre Alves. All rights reserved.
//

import Foundation

internal final class PaulHeckelDifference<T: Diffable> {
    private var newArray: [T] = []
    private var oldArray: [T] = []

    // OA
    private var oldReferencesTable: [Reference] = []
    // NA
    private var newReferencesTable: [Reference] = []

    func difference(from fromArray: [T], to toArray: [T]) -> [DiffStep<T>] {
        newArray = toArray
        oldArray = fromArray

        calculateReferencesTables()
        let differenceSteps = calculateDifferenceSteps()
        cleanUp()

        return differenceSteps
    }

    private func calculateReferencesTables() {
        // First and second pass
        fillSymbolsToReferenceTables()
        // Third pass
        bindAnchorReferences()
        // Fourth pass
        bindSameReferencesAfterAnchors()
        // Fifth pass
        bindSameReferencesBeforeAnchors()
    }

    private func fillSymbolsToReferenceTables() {
        var table: [T.HashType: Reference.Symbol] = [:]

        for newObject in newArray {
            let identifier = newObject.diffIdentifier
            let symbol = table[identifier] ?? Reference.Symbol()
            symbol.newCounter += 1
            table[identifier] = symbol

            newReferencesTable.append(.Pointer(symbol))
        }

        for (oldIndex, oldObject) in oldArray.enumerated() {
            let identifier = oldObject.diffIdentifier
            let symbol = table[identifier] ?? Reference.Symbol()
            symbol.oldCounter += 1
            symbol.oldIndex = oldIndex
            table[identifier] = symbol
            oldReferencesTable.append(.Pointer(symbol))
        }
    }

    private func bindAnchorReferences() {
        for (index, reference) in newReferencesTable.enumerated() {
            if let symbol = reference.symbol, symbol.isAnchor {
                bindReferences(oldIndex: symbol.oldIndex, newIndex: index)
            }
        }
    }

    private func bindSameReferencesAfterAnchors() {
        for newIndex in stride(from: 0, to: newReferencesTable.count - 1, by: 1) {
            if let oldIndex = newReferencesTable[newIndex].index {
                if hasSameSymbolReferencesAt(newIndex: newIndex + 1, oldIndex: oldIndex + 1) {
                    bindReferences(oldIndex: oldIndex + 1, newIndex: newIndex + 1)
                }
            }
        }
    }

    private func bindSameReferencesBeforeAnchors() {
        for newIndex in stride(from: newReferencesTable.count - 1, to: 0, by: -1) {
            if let oldIndex = newReferencesTable[newIndex].index {
                if hasSameSymbolReferencesAt(newIndex: newIndex - 1, oldIndex: oldIndex - 1) {
                    bindReferences(oldIndex: oldIndex - 1, newIndex: newIndex - 1)
                }
            }
        }
    }

    private func hasSameSymbolReferencesAt(newIndex: Int, oldIndex: Int) -> Bool {
        guard let newSymbol = referenceSymbol(at: newIndex, from: newReferencesTable) else {
            return false
        }
        guard let oldSymbol = referenceSymbol(at: oldIndex, from: oldReferencesTable) else {
            return false
        }
        return newSymbol === oldSymbol
    }

    private func bindReferences(oldIndex: Int, newIndex: Int) {
        newReferencesTable[newIndex] = .Index(oldIndex)
        oldReferencesTable[oldIndex] = .Index(newIndex)
    }

    private func referenceSymbol(at index: Int, from references: [Reference]) -> Reference.Symbol? {
        if index < 0 || index >= references.count {
            return nil
        }
        return references[index].symbol
    }

    private func calculateDifferenceSteps() -> [DiffStep<T>] {
        var steps: [DiffStep<T>] = []

        var deleteOffsets = Array(repeating: 0, count: oldReferencesTable.count)
        var runningOffset = 0

        // Find deletions and incremement offset for each delete
        for (index, reference) in oldReferencesTable.enumerated() {
            deleteOffsets[index] = runningOffset
            if reference.symbol != nil {
                steps.append(.delete(value: oldArray[index], index: index))
                runningOffset -= 1
            }
        }

        runningOffset = 0

        // Find inserts, moves and updates
        for (newIndex, reference) in newReferencesTable.enumerated() {
            if let oldIndex = reference.index {
                // Checks for the current offset, if matches means that this move is not needed
                let expectedOldIndex = oldIndex + runningOffset + deleteOffsets[oldIndex]
                if expectedOldIndex != newIndex {
                    steps.append(.move(value: newArray[newIndex], fromIndex: oldIndex, toIndex: newIndex))
                }
                // Check if this object has changed
                if newArray[newIndex] != oldArray[oldIndex] {
                    steps.append(.update(value: newArray[newIndex], index: oldIndex))
                }
            } else {
                steps.append(.insert(value: newArray[newIndex], index: newIndex))
                runningOffset += 1
            }
        }

        return steps
    }

    func cleanUp() {
        newArray = []
        oldArray = []

        newReferencesTable = []
        oldReferencesTable = []
    }
}

/// The `Reference` is used during diff info setup. It can points to the symbol table or array index.
private enum Reference {
    fileprivate final class Symbol {
        var oldCounter = 0 // OC
        var newCounter = 0 // NC
        var oldIndex = 0 // OLNO

        var isAnchor: Bool {
            return (newCounter == 1 && oldCounter == 1)
        }
    }
    case Pointer(Symbol)
    case Index(Int)

    var symbol: Symbol? {
        switch self {
        case let .Pointer(symbol): return symbol
        default: return nil
        }
    }

    var index: Int? {
        switch self {
        case let .Index(index): return index
        default: return nil
        }
    }
}
