//
//  DetailViewController.swift
//  TitleViewWithActivityIndicator
//
//  Created by donaldsong on 17-9-6.
//  Copyright © 2017 Tencent. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    let titleView = TitleView(frame: CGRect(x: 0, y: 0, width: 320, height: 44))

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.description
            }
            titleView.titleLabel.text = detail.description
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = titleView
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: NSDate? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    @IBAction func onButton(_ sender: Any) {
        titleView.activityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let `self` = self else { return }
            self.titleView.activityIndicator.stopAnimating()
        }
    }

}

