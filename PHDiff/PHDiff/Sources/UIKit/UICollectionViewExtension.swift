//
//  UICollectionViewExtension.swift
//  PHDiff
//
//  Created by Evgeniy Yurtaaev on 1/6/17.
//  Copyright © 2017 Andre Alves. All rights reserved.
//

import UIKit

public extension UICollectionView {
    /*
     Updates senction items via diff steps
     @warning should be used within `performBatchUpdates` block
    **/
    public func ph_updateSection<T>(_ section: Int, steps: [DiffStep<T>]) {
        if steps.count == 0 {
            return;
        }

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
                moveItem(
                    at: IndexPath(row: fromIndex, section: section),
                    to: IndexPath(row: toIndex, section: section)
                )
            case let .update(_, index):
                reloads.append(IndexPath(row: index, section: 0))
            }
        }

        insertItems(at: insertions)
        deleteItems(at: deletions)
        reloadItems(at: reloads)
    }
}
