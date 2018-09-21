//
//  DetailViewController.swift
//  Flix
//
//  Created by Xiaohong Zhu on 9/12/18.
//  Copyright © 2018 Xiaohong Zhu. All rights reserved.
//

import UIKit

enum MovieKeys {
    static let title = "title"
    static let overview = "overview"
    static let releaseDate = "release_date"
    static let backdropPath = "backdrop_path"
    static let posterPath = "poster_path"
    static let id = "id"
}

class DetailViewController: UIViewController {

    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    var movie : [String: Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let movie = movie {
            let overviewTextView = UITextView(frame: CGRect(x: 15, y: 435, width: view.frame.width - 15*2, height: 180))
            overviewTextView.backgroundColor = UIColor.clear
            overviewTextView.textColor = UIColor.white
            overviewTextView.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.thin)
            overviewTextView.isScrollEnabled = true
            
            titleLabel.text = movie[MovieKeys.title] as? String
            releaseDateLabel.text = movie[MovieKeys.releaseDate] as? String
            overviewTextView.text = movie[MovieKeys.overview] as? String
            
            let baseURLString = "https://image.tmdb.org/t/p/original"
            let backdropPathString = movie[MovieKeys.backdropPath] as! String
            let posterPathString = movie[MovieKeys.posterPath] as! String
            let backdropURL = URL(string: baseURLString + backdropPathString)!
            let posterURL = URL(string: baseURLString + posterPathString)!
            
            backdropImageView.af_setImage(withURL: backdropURL)
            posterImageView.af_setImage(withURL: posterURL)
            
            let layer = posterImageView.layer
            layer.borderColor = UIColor.white.cgColor
            layer.borderWidth = 2.0
            
            view.addSubview(overviewTextView)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let trailerViewController = segue.destination as! TrailerViewController
        let idQuery = movie[MovieKeys.id] as! Int
        trailerViewController.idQuery = "\(idQuery)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
