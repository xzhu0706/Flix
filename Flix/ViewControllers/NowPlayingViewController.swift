//
//  NowPlayingViewController.swift
//  Flix
//
//  Created by Xiaohong Zhu on 9/2/18.
//  Copyright © 2018 Xiaohong Zhu. All rights reserved.
//

import UIKit
import AlamofireImage
import PKHUD

class NowPlayingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [[String: Any]] = []
    var filteredMovies: [[String: Any]] = []
    
    var refreshControl: UIRefreshControl!
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectionIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectionIndexPath, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let singleTap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(sender:)))
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.clear
        refreshControl.addTarget(self, action: #selector(NowPlayingViewController.didPullToRefresh(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        tableView.addGestureRecognizer(singleTap)
        tableView.dataSource = self
        tableView.delegate = self
        singleTap.delegate = self
        searchBar.delegate = self
        searchBar.placeholder = "Search a movie"
        
        fetchMovies()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Avoid conflict of tap gesture and cell selection
        // Recognize the tap only when search bar is the first responder
        if !(searchBar.isFirstResponder) {
            return false
        }
        return true
    }
    
    @objc func hideKeyboard(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.view.endEditing(true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = filteredMovies[indexPath.row]
        
        // Set title and overview
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        // Set image
        let smallBaseURLString = "https://image.tmdb.org/t/p/w45"
        let largeBaseURLString = "https://image.tmdb.org/t/p/original"
        let posterPathString = movie["poster_path"] as! String
        let smallPosterURL = URL(string: smallBaseURLString + posterPathString)!
        let largePosterURL = URL(string: largeBaseURLString + posterPathString)!
        let placeholderImage = UIImage(named: "placeholder")!
        cell.posterImageView.af_setImage(withURL: smallPosterURL, placeholderImage: placeholderImage, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: false) { (response) in
            cell.posterImageView.af_setImage(withURL: largePosterURL)
        }
        
        return cell
    }
    
    /* No longer need this function because we added detail view to the table
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = tableView.cellForRow(at: indexPath) as! MovieCell
        
        // deselect the cell if tap on selected cell
        if cell.isSelected {
            tableView.deselectRow(at: indexPath, animated: true)
            return nil
        } else {
            return indexPath
        }
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell) {
            let movie = filteredMovies[indexPath.row]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = movie
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies : movies.filter({ (movie: [String : Any]) -> Bool in
            return (movie["title"] as! String).localizedCaseInsensitiveContains(searchText)
        })
        
        tableView.reloadData()
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        // Show progress HUD
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
        // Clear search bar text and end editing
        self.view.endEditing(true)
        searchBar.text = ""
        
        fetchMovies()
    }
    
    func fetchMovies() {
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=60a41150f71452609ae99855d181c5dc")!
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
                self.filteredMovies = movies
                
                // Reload your table view data
                self.tableView.reloadData()
                
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
