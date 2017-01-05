//
//  DemoTableViewController.swift
//  Example
//
//  Created by Andre Alves on 10/12/16.
//  Copyright © 2016 Andre Alves. All rights reserved.
//

import UIKit
import PHDiff

final class DemoTableViewController: UITableViewController {
    private var colors: [DemoColor] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }

    @IBAction func didTapShuffleButton(_ sender: UIBarButtonItem) {
        shuffle()
    }

    private func shuffle() {
        updateTableView(newColors: RandomDemoColors().randomColors())
    }

    private func updateTableView(newColors: [DemoColor]) {
        let steps = newColors.difference(from: self.colors)
        self.colors = newColors

        tableView.beginUpdates()
        tableView.ph_updateSection(0, steps: steps)
        tableView.endUpdates()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoCell", for: indexPath)
        let color = colors[indexPath.row]
        cell.textLabel?.text = color.name
        cell.backgroundColor = color.toUIColor()
        return cell
    }
}
