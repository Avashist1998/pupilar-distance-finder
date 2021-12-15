//
//  AboutViewController.swift
//  pup
//
//  Created by Miguel Tamayo on 3/28/21.
//

import UIKit

class AboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        let aboutLabel: UILabel = UILabel(forAutoLayout: ())
        aboutLabel.text =
            """
            ABOUT:
            App Developed by

            Abhay Vashist
            &
            Miguel Tamayo
            """
        aboutLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        aboutLabel.textColor = .black
        aboutLabel.contentMode = .center
        aboutLabel.textAlignment = .center
        aboutLabel.lineBreakMode = .byWordWrapping
        aboutLabel.adjustsFontSizeToFitWidth = true
        aboutLabel.numberOfLines = 0
        self.view.addSubview(aboutLabel)
        aboutLabel.autoPinEdgesToSuperviewSafeArea(with: .init(top: 8, left: 8, bottom: 8, right: 8))
    }

}
