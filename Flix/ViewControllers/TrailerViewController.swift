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
                // Display error alert if fail to load
                let alertController = UIAlertController(title: "Error", message: "Network is not available, please check Settings.", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                }
                // Add the OK action to the alert controller
                alertController.addAction(OKAction)
                self.present(alertController, animated: true)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                
                // Get the trailer
                let trailers = dataDictionary["results"] as! [[String: Any]]
                let myTrailer = trailers[0]
                let key = myTrailer["key"] as! String
                let trailerBaseURLString = "https://www.youtube.com/watch?v="
                let trailerURL = URL(string: trailerBaseURLString + key)!
                self.trailerWebView.loadRequest(URLRequest(url: trailerURL))
            }
        }
        task.resume()
    }

    @IBAction func didTapOnBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
