//
//  SuperheroViewController.swift
//  Flix
//
//  Created by Xiaohong Zhu on 9/18/18.
//  Copyright © 2018 Xiaohong Zhu. All rights reserved.
//

import UIKit
import PKHUD

class SuperheroViewController: UIViewController, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var movies : [[String: Any]] = []
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.clear
        refreshControl.addTarget(self, action: #selector(SuperheroViewController.didPullToRefresh(_:)), for: .valueChanged)
        collectionView.insertSubview(refreshControl, at: 0)
        
        collectionView.dataSource = self
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = layout.minimumInteritemSpacing
        let cellsPerLine : CGFloat = 2
        let totalInterItemSpacing = (cellsPerLine - 1) * layout.minimumInteritemSpacing
        let width = (collectionView.frame.size.width - totalInterItemSpacing) / cellsPerLine
        layout.itemSize = CGSize(width: width, height: width * 3 / 2)
        
        fetchMovies()
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        // Show progress HUD
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
        fetchMovies()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell
        let movie = movies[indexPath.item]
        
        // Set image
        if let posterPathString = movie["poster_path"] as? String {
            let smallBaseURLString = "https://image.tmdb.org/t/p/w45"
            let largeBaseURLString = "https://image.tmdb.org/t/p/original"
            
            let smallPosterURL = URL(string: smallBaseURLString + posterPathString)!
            let largePosterURL = URL(string: largeBaseURLString + posterPathString)!
            let placeholderImage = UIImage(named: "placeholder")!
            cell.posterImageView.af_setImage(withURL: smallPosterURL, placeholderImage: placeholderImage, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: false) { (response) in
                cell.posterImageView.af_setImage(withURL: largePosterURL)
            }
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UICollectionViewCell
        if let indexPath = collectionView.indexPath(for: cell) {
            let movie = movies[indexPath.item]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = movie
        }
    }
    
    func fetchMovies() {
        let url = URL(string: "https://api.themoviedb.org/3/movie/297762/similar?api_key=60a41150f71452609ae99855d181c5dc")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if error != nil {
                // Display error alert if fail to load
                let alertController = UIAlertController(title: "Error", message: "Network is not available, please check Settings.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                }
                // Add the OK action to the alert controller
                alertController.addAction(OKAction)
                PKHUD.sharedHUD.hide()
                self.present(alertController, animated: true)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                
                // Get the array of movies
                let movies = dataDictionary["results"] as! [[String: Any]]
                
                // Store the movies in a property to use elsewhere
                self.movies = movies
                
                // Reload your table view data
                self.collectionView.reloadData()
                
                // Hide progress HUD
                PKHUD.sharedHUD.hide()
            }
        }
        self.refreshControl.endRefreshing()
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
