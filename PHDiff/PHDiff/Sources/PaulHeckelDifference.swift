//
//  PaulHeckelDifference.swift
//  PaulHeckelDifference
//
//  Created by Andre Alves on 10/13/16.
//  Copyright © 2016 Andre Alves. All rights reserved.
//

import Foundation

internal func PaulHeckelDifference<T: Diffable>(between fromArray: [T], and toArray: [T]) -> [DiffStep<T>] {
    let info = PaulHeckelDifferenceInfo(from: fromArray, and: toArray)

    var steps: [DiffStep<T>] = []
    var deleteOffsets = Array(repeating: 0, count: info.OA.count)
    var runningOffset = 0

    // Find deletions and incremement offset for each delete
    for (j, ref) in info.OA.enumerated() {
        deleteOffsets[j] = runningOffset
        if ref.symbol != nil {
            steps.append(.delete(value: fromArray[j], index: j))
            runningOffset -= 1
        }
    }

    runningOffset = 0

    // Find inserts, moves and updates
    for (i, ref) in info.NA.enumerated() {
        if let j = ref.index {
            // Checks for the current offset, if matches means that this move is not needed
            let expectedOldIndex = j + runningOffset + deleteOffsets[j]
            if expectedOldIndex != i {
                steps.append(.move(value: toArray[i], fromIndex: j, toIndex: i))
                if expectedOldIndex > i {
                    runningOffset += 1
                }
            }
            // Check if this object has changed
            if toArray[i] != fromArray[j] {
                steps.append(.update(value: toArray[i], index: i))
            }
        } else {
            steps.append(.insert(value: toArray[i], index: i))
            runningOffset += 1
        }
    }

    return steps
}

private func PaulHeckelDifferenceInfo<T: Diffable>(from fromArray: [T], and toArray: [T]) -> (OA: [Reference], NA: [Reference]) {
    var table: [T.HashType: Reference.Symbol] = [:]
    var OA: [Reference] = []
    var NA: [Reference] = []

    // First pass
    for obj in toArray {
        let symbol = table[obj.diffIdentifier] ?? Reference.Symbol()
        symbol.newCounter += 1
        table[obj.diffIdentifier] = symbol
        NA.append(.Pointer(symbol))
    }

    // Second pass
    for (index, obj) in fromArray.enumerated() {
        let symbol = table[obj.diffIdentifier] ?? Reference.Symbol()
        symbol.oldCounter += 1
        symbol.oldIndex = index
        table[obj.diffIdentifier] = symbol
        OA.append(.Pointer(symbol))
    }

    // Third pass
    for (index, ref) in NA.enumerated() {
        if let nSymbol = ref.symbol, nSymbol.newCounter == nSymbol.oldCounter && nSymbol.newCounter == 1 {
            NA[index] = .Index(nSymbol.oldIndex)
            OA[nSymbol.oldIndex] = .Index(index)
        }
    }

    // Fourth pass
    for i in stride(from: 0, to: NA.count - 1, by: 1) {
        if let j = NA[i].index, j + 1 < OA.count {
            if NA[i + 1].symbol != nil && NA[i + 1].symbol === OA[j + 1].symbol {
                NA[i+1] = .Index(j + 1)
                OA[j+1] = .Index(i + 1)
            }
        }
    }

    // Fifth pass
    for i in stride(from: NA.count - 1, to: 0, by: -1) {
        if let j = NA[i].index, j - 1 >= 0 {
            if NA[i - 1].symbol != nil && NA[i - 1].symbol === OA[j - 1].symbol {
                NA[i - 1] = .Index(j - 1)
                OA[j - 1] = .Index(i - 1)
            }
        }
    }

    return (OA, NA)
}

/// The `Reference` is used during diff info setup. It can points to the symbol table or array index.
private enum Reference {
    fileprivate final class Symbol {
        var oldCounter = 0 // OC
        var newCounter = 0 // NC
        var oldIndex = 0 // OLNO
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
