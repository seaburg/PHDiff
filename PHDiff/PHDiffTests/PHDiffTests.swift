//
//  PHDiffTests.swift
//  PHDiffTests
//
//  Created by Andre Alves on 10/16/16.
//  Copyright © 2016 Andre Alves. All rights reserved.
//

import XCTest
@testable import PHDiff

final class PHDiffTests: XCTestCase {

    func testDiff() {
        var oldArray: [String] = []
        var newArray: [String] = []
        var steps: [DiffStep<String>] = []

        oldArray = ["a", "b", "c"]
        newArray = ["a", "b", "c"]
        steps = PHDiff.sortedSteps(fromArray: oldArray, toArray: newArray)
        XCTAssertTrue(try! oldArray.apply(steps: steps) == newArray)

        oldArray = []
        newArray = ["a", "b", "c", "d", "e"]
        steps = PHDiff.sortedSteps(fromArray: oldArray, toArray: newArray)
        XCTAssertTrue(try! oldArray.apply(steps: steps) == newArray)

        oldArray = ["a", "b", "c", "c", "c"]
        newArray = []
        steps = PHDiff.sortedSteps(fromArray: oldArray, toArray: newArray)
        XCTAssertTrue(try! oldArray.apply(steps: steps) == newArray)

        oldArray = ["a", "b", "c", "c", "c"]
        newArray = ["e", "b", "c", "d", "a"]
        steps = PHDiff.sortedSteps(fromArray: oldArray, toArray: newArray)
        XCTAssertTrue(try! oldArray.apply(steps: steps) == newArray)

        oldArray = ["p", "U", "b", "A", "5", "F"]
        newArray = ["O", "w", "Z", "U"]
        steps = PHDiff.sortedSteps(fromArray: oldArray, toArray: newArray)
        XCTAssertTrue(try! oldArray.apply(steps: steps) == newArray)

        oldArray = ["p", "b", "U", "A", "5", "F"]
        newArray = ["O", "w", "Z", "U"]
        steps = PHDiff.sortedSteps(fromArray: oldArray, toArray: newArray)
        XCTAssertTrue(try! oldArray.apply(steps: steps) == newArray)

        oldArray = ["x", "E", "g", "B", "f", "o", "3", "m"]
        newArray = ["j", "f", "L", "L", "m", "V", "g", "Q", "1"]
        steps = PHDiff.sortedSteps(fromArray: oldArray, toArray: newArray)
        XCTAssertTrue(try! oldArray.apply(steps: steps) == newArray)

        oldArray = ["j", "E", "g", "B", "f", "o", "3", "m"]
        newArray = ["j", "f", "L", "L", "m", "V", "g", "Q", "1"]
        steps = PHDiff.sortedSteps(fromArray: oldArray, toArray: newArray)
        XCTAssertTrue(try! oldArray.apply(steps: steps) == newArray)

        oldArray = ["a", "b", "c", "c", "c"]
        newArray = ["e", "b", "c", "d", "a"]
        steps = PHDiff.sortedSteps(fromArray: oldArray, toArray: newArray)
        XCTAssertTrue(try! oldArray.apply(steps: steps) == newArray)

        oldArray = ["a", "b", "c"]
        newArray = ["b", "c", "c"]
        steps = PHDiff.sortedSteps(fromArray: oldArray, toArray: newArray)
        XCTAssertEqual(steps, [ DiffStep.delete(value: "a", index: 0), DiffStep.insert(value: "c", index: 2) ])

        oldArray = ["a", "b", "c"]
        newArray = ["c", "a", "b"]
        steps = PHDiff.steps(fromArray: oldArray, toArray: newArray)
        XCTAssertEqual(steps, [ DiffStep.move(value: "c", fromIndex: 2, toIndex: 0)])

        oldArray = ["a", "b", "c"]
        newArray = ["b", "c", "a"]
        steps = PHDiff.steps(fromArray: oldArray, toArray: newArray)
        XCTAssertEqual(steps, [
            DiffStep.move(value: "b", fromIndex: 1, toIndex: 0),
            DiffStep.move(value: "c", fromIndex: 2, toIndex: 1),
        ])
    }

    func testApplyDiffWithBadInsertIndexSteps() {
        let steps: [DiffStep<String>] = [
            .insert(value: "d", index: 4),
        ]
        do {
            let _ = try [ "a", "b", "c" ].apply(steps: steps)
            XCTAssert(false)
        } catch DiffError<String>.failApplyDiffStep(step: let step) {
            XCTAssertEqual(step, DiffStep.insert(value: "d", index: 4))
        } catch _ {
            XCTAssert(false)
        }
    }

    func testApplyDiffWithBadInsertIndexAfterRemoveSeveralSteps() {
        let steps: [DiffStep<String>] = [
            .delete(value: "a", index: 0),
            .delete(value: "b", index: 1),
            .insert(value: "c", index: 3),
        ]
        do {
            let _ = try [ "a", "b", "c", "d" ].apply(steps: steps)
            XCTAssert(false)
        } catch DiffError<String>.failApplyDiffStep(step: let step) {
            XCTAssertEqual(step, DiffStep.insert(value: "c", index: 3))
        } catch _ {
            XCTAssert(false)
        }
    }

    func testRemoveItemOutRangeIndex() {
        let steps: [DiffStep<String>] = [
            .delete(value: "f", index: 4),
        ]
        do {
            let _ = try [ "a", "b", "c", "d" ].apply(steps: steps)
            XCTAssert(false)
        } catch DiffError<String>.failApplyDiffStep(step: let step) {
            XCTAssertEqual(step, DiffStep.delete(value: "f", index: 4))
        } catch _ {
            XCTAssert(false)
        }
    }

    func testMoveWithInvalidFromIndex() {
        let steps: [DiffStep<String>] = [
            .move(value: "f", fromIndex: 4, toIndex: 0),
        ]
        do {
            let _ = try [ "a", "b", "c", "d" ].apply(steps: steps)
            XCTAssert(false)
        } catch DiffError<String>.failApplyDiffStep(step: let step) {
            XCTAssertEqual(step, DiffStep.move(value: "f", fromIndex: 4, toIndex: 0))
        } catch _ {
            XCTAssert(false)
        }
    }

    func testMoveWithInvalidToIndex() {
        let steps: [DiffStep<String>] = [
            .move(value: "a", fromIndex: 0, toIndex: 4),
            ]
        do {
            let _ = try [ "a", "b", "c", "d" ].apply(steps: steps)
            XCTAssert(false)
        } catch DiffError<String>.failApplyDiffStep(step: let step) {
            XCTAssertEqual(step, DiffStep.insert(value: "a", index: 4))
        } catch _ {
            XCTAssert(false)
        }
    }

    func testUpdateWithInvalidIndex() {
        let steps: [DiffStep<String>] = [
            .update(value: "a", index: 4),
            ]
        do {
            let _ = try [ "a", "b", "c", "d" ].apply(steps: steps)
            XCTAssert(false)
        } catch DiffError<String>.failApplyDiffStep(step: let step) {
            XCTAssertEqual(step, DiffStep.update(value: "a", index: 4))
        } catch _ {
            XCTAssert(false)
        }
    }

    func testDiffUpdate() {
        var oldArray: [TestUser] = []
        var newArray: [TestUser] = []
        var steps: [DiffStep<TestUser>] = []
        var expectedSteps: [DiffStep<TestUser>] = []

        oldArray = [TestUser(name: "1", age: 0), TestUser(name: "2", age: 0)]
        newArray = [TestUser(name: "1", age: 0), TestUser(name: "2", age: 1)]
        steps = PHDiff.sortedSteps(fromArray: oldArray, toArray: newArray)
        expectedSteps = [.update(value: TestUser(name: "2", age: 1), index: 1)]
        XCTAssertTrue(steps == expectedSteps)
        XCTAssertEqual(try! oldArray.apply(steps: steps), newArray, "simple update")
    }

    func testRandomDiffs() {
        let numberOfTests = 1000

        for i in 1...numberOfTests {
            print("############### Random Diff Test \(i) ###############")
            let oldArray = randomArray(length: randomNumber(0..<500))
            let newArray = randomArray(length: randomNumber(0..<500))

            let steps = PHDiff.sortedSteps(fromArray: oldArray, toArray: newArray)
            XCTAssertEqual(try! oldArray.apply(steps: steps), newArray, "\noldArray = \(oldArray)\nnewArray = \(newArray)")
        }
    }

    func testDiffPerformance() {
        let oldArray = randomArray(length: 1000)
        let newArray = randomArray(length: 1000)

        self.measure {
            let _ = PHDiff.sortedSteps(fromArray: oldArray, toArray: newArray)
        }
    }
}
