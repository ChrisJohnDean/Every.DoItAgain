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
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                //label.text = detail.timestamp!.description
            }
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

