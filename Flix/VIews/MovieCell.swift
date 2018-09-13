//
//  MovieCell.swift
//  Flix
//
//  Created by Xiaohong Zhu on 9/5/18.
//  Copyright © 2018 Xiaohong Zhu. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Set cell selection style
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.darkGray
        selectedBackgroundView = backgroundView
        
        if selected {
            titleLabel.textColor = UIColor.white
            overviewLabel.textColor = UIColor.white
        } else {
            titleLabel.textColor = UIColor.black
            overviewLabel.textColor = UIColor.black
        }
    }

}
