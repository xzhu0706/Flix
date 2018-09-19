//
//  TrailerViewController.swift
//  Flix
//
//  Created by Xiaohong Zhu on 9/18/18.
//  Copyright © 2018 Xiaohong Zhu. All rights reserved.
//

import UIKit

class TrailerViewController: UIViewController {
    
    @IBOutlet weak var trailerWebView: UIWebView!
    
    var idQuery: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let baseURLString = "https://api.themoviedb.org/3/movie/"
        let URLString = baseURLString + idQuery + "/videos?api_key=60a41150f71452609ae99855d181c5dc"
        let url = URL(string: URLString)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                // Show error if network is not available
                self.displayError(title: "Error", message: "Network is not available, please check Settings.")
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                
                // Get the trailer
                let trailers = dataDictionary["results"] as! [[String: Any]]
                if trailers.count != 0 {
                    let myTrailer = trailers[0]
                    let key = myTrailer["key"] as! String
                    let trailerBaseURLString = "https://www.youtube.com/watch?v="
                    let trailerURL = URL(string: trailerBaseURLString + key)!
                    self.trailerWebView.loadRequest(URLRequest(url: trailerURL))
                } else {
                    // Show error if no trailer is found
                    self.displayError(title: "", message: "Sorry, no trailer is found.")
                }
            }
        }
        task.resume()
    }
    
    func displayError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true)
    }
    
    @IBAction func didTapOnBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
