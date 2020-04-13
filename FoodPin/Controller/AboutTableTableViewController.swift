//
//  AboutTableTableViewController.swift
//  FoodPin
//
//  Created by wyn on 2020/4/13.
//  Copyright © 2020 AppCoda. All rights reserved.
//

import UIKit
import WebKit

class AboutTableTableViewController: UITableViewController {
    
    var sectionTitles = ["Feedback","Follow Us"]
    var sectionContent = [[(image: "store", text: "Rate us on App Store", link: "https://www.apple.com/ios/app-store/"),(image: "chat", text: "Tell us your feedback", link: "https://www.apple.com/ios/contact")],[(image: "twitter", text: "Twitter", link: "https://www.twitter.com/appcodamobile"),(image: "facebook", text: "Facebook", link: "https://www.facebook.com/appcodamobile"),(image: "instagram", text: "Instgram", link: "http://instgram.com/appcodamobile")]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.cellLayoutMarginsFollowReadableWidth = true
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "Gotu-Regular", size: 40.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 231, green: 76, blue: 60),NSAttributedString.Key.font: customFont]
        }
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sectionContent[section].count
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath)
        
        //Configure the cell...
        let cellData = sectionContent[indexPath.section][indexPath.row]
        cell.textLabel?.text = cellData.text
        cell.imageView?.image = UIImage(named: cellData.image)
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let link = sectionContent[indexPath.section][indexPath.row].link
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                if let url = URL(string: link) {
                    UIApplication.shared.open(url)
                }
            }else if indexPath.row == 1 {
                performSegue(withIdentifier: "showWebView", sender: self)
            }
            
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebView" {
            if let destinationController = segue.destination as? WebViewController,
                let indexPath = tableView.indexPathForSelectedRow {
                destinationController.targetURL = sectionContent[indexPath.section][indexPath.row].link
            }
        }
    }

}
