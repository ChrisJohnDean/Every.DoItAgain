//
//  DetailViewController.swift
//  Every.DoItAgain
//
//  Created by Chris Dean on 2018-03-21.
//  Copyright © 2018 Chris Dean. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem, let label = detailDescriptionLabel, let toDoTitle = detailItem?.title, let descript = detailItem?.todoDescription {
            label.text = "\(toDoTitle): \(descript) Priority: \(detail.priorityNumber)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: ToDo? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

