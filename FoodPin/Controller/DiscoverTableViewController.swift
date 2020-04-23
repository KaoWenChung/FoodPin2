//
//  DiscoverTableViewController.swift
//  FoodPin
//
//  Created by wyn on 2020/4/23.
//  Copyright © 2020 Wyn. All rights reserved.
//

import UIKit
import CloudKit

class DiscoverTableViewController: UITableViewController {
    
    var restaurants: [CKRecord] = []
    var spinner = UIActivityIndicatorView()
    private var imageCache = NSCache<CKRecord.ID, NSURL>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.style = .medium
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        
        // Update by drop down screen
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.tintColor = UIColor.gray
        refreshControl?.addTarget(self, action: #selector(fetchRecordsFromCloud), for: UIControl.Event.valueChanged)
        
        // Definition the activity indicator constraint
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150.0), spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        
        // Start spinner
        spinner.startAnimating()
        
        tableView.cellLayoutMarginsFollowReadableWidth = true
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Set navigationBar appearance
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "Gotu-Regular", size: 40.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor(red: 231, green: 76, blue: 60), NSAttributedString.Key.font: customFont]
        }
        
        fetchRecordsFromCloud()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restaurants.count
    }
    
    override func tableView(_ tabkeView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverCell", for: indexPath)
        
        // Set the cell
        let restaurant = restaurants[indexPath.row]
        cell.textLabel?.text = restaurant.object(forKey: "name") as? String
        
        // Set default photo
        cell.imageView?.image = UIImage(named: "photo")
        
        // Check if the image is at cache already
        if let imageFileURL = imageCache.object(forKey: restaurant.recordID) {
            // Get image from cache
            print("Get image from cache")
            if let imageData = try? Data.init(contentsOf: imageFileURL as URL) {
                cell.imageView?.image = UIImage(data: imageData)
            }
        } else {
            // Get image from Cloudkit
            let publicDatabase = CKContainer.default().publicCloudDatabase
            let fetchRecordsImageOperation = CKFetchRecordsOperation(recordIDs: [restaurant.recordID])
            fetchRecordsImageOperation.desiredKeys = ["image"]
            fetchRecordsImageOperation.queuePriority = .veryHigh
            
            fetchRecordsImageOperation.perRecordCompletionBlock = { [unowned self] (record, recordID, error) -> Void in
                if let error = error {
                    print("Failed to get restaurant image: \(error.localizedDescription)")
                    return
                }
                
                if let restaurantRecord = record,
                    let image = restaurantRecord.object(forKey: "image"),
                    let imageAsset = image as? CKAsset {
                    if let imageData = try? Data.init(contentsOf: imageAsset.fileURL!) {
                        
                        // Replace default image by restaurant image
                        DispatchQueue.main.sync {
                            cell.imageView?.image = UIImage(data: imageData)
                            cell.setNeedsLayout()
                        }
                        
                        // add URL to cache
                        self.imageCache.setObject(imageAsset.fileURL! as NSURL, forKey: restaurant.recordID)
                    }
                }
            }
            publicDatabase.add(fetchRecordsImageOperation)
        }
        return cell
    }
    
    @objc func fetchRecordsFromCloud() {
        
        // Delete data records before update
        restaurants.removeAll()
        tableView.reloadData()
        
        // Get data by convience API
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        
        // Prepare for searching
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        
        // Create searching by query
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 50
        queryOperation.recordFetchedBlock = {(record) -> Void in
            self.restaurants.append(record)
        }
        
        queryOperation.queryCompletionBlock = { [unowned self] (cursor, error) -> Void in
            if let error = error {
                print("Failed to get data from iCloud -\(error.localizedDescription)")
                return
            }
            
            print("Successfully retrieve tha data from iCloud")
            DispatchQueue.main.sync {
                self.spinner.stopAnimating()
                self.tableView.reloadData()
                
                if let refreshControl = self.refreshControl {
                    if refreshControl.isRefreshing {
                        refreshControl.endRefreshing()
                    }
                }
                
            }
        }
        
        publicDatabase.add(queryOperation)
//        publicDatabase.perform(query, inZoneWith: nil, completionHandler: {
//            (results, error) -> Void in
//
//            if let error = error {
//                print(error)
//                return
//            }
//
//            if let results = results {
//                print("Completed the download of Restaurant data")
//                self.restaurants = results
//
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//
//            }
//        })
    }
}
