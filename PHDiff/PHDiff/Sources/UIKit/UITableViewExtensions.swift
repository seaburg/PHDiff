//
//  UITableViewExtensions.swift
//  PHDiff
//
//  Created by Evgeniy Yurtaaev on 1/5/17.
//  Copyright © 2017 Andre Alves. All rights reserved.
//

import UIKit

public extension UITableView {
    public func ph_updateSection<T>(_ section: Int, steps: [DiffStep<T>]) {
        if steps.count == 0 {
            return;
        }
        beginUpdates()

        var insertions: [IndexPath] = []
        var deletions: [IndexPath] = []
        var reloads: [IndexPath] = []

        steps.forEach { step in
            switch step {
            case let .insert(_, index):
                insertions.append(IndexPath(row: index, section: section))
            case let .delete(_, index):
                deletions.append(IndexPath(row: index, section: section))
            case let .move(_, fromIndex, toIndex):
                moveRow(
                    at: IndexPath(row: fromIndex, section: section),
                    to: IndexPath(row: toIndex, section: section)
                )
            case let .update(_, index):
                reloads.append(IndexPath(row: index, section: 0))
            }
        }

        insertRows(at: insertions, with: .automatic)
        deleteRows(at: deletions, with: .automatic)
        reloadRows(at: reloads, with: .automatic)

        endUpdates()
    }
}
