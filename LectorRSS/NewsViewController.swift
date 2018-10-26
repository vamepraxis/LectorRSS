//
//  NewsViewController.swift
//  LectorRSS
//
//  Created by MacBook Pro on 20/10/18.
//  Copyright © 2018 ccc. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache:NSCache<AnyObject, AnyObject>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ViewsDesign.settingsNavigationItem(self, navItem: navigationItem)
        
        session = URLSession.shared
        task = URLSessionDownloadTask()
        self.cache = NSCache()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCustomCell") as! TableViewCustomCell
        
        cell.isSelected = false
        cell.selectionStyle = .none
       
        let title = prefs.value(forKey: "TITLE_RSS") as? String
        let description  = prefs.value(forKey: "DESCRIPTION_RSS") as? String
        let date = prefs.value(forKey: "DATE_RSS") as? String
        
        cell.titleNews.text = title
        cell.dateNews.text = date
        cell.descriptionNews.text = description
        
        cell.imageViewNews.image = UIImage(named: "rss")

        if let media_data:Data = prefs.value(forKey: "DATA_RSS") as? Data {
         
            if media_data.isEmpty == false {
                
                if let image = UIImage(data:media_data) {
                    cell.imageViewNews.image = image
                }
                
            }
            
        } 
        
        if cell.buttonDelegate == nil {
            cell.buttonDelegate = self
        }

        return cell
    }
    
    func cellTapped(_ cell: TableViewCustomCell) {
        
        let linkRSS:String = prefs.value(forKey: "LINK_RSS") as! String
        var urlRSS = linkRSS
        
        if linkRSS.contains(" ") {
           urlRSS = linkRSS.replacingOccurrences(of: " ", with: "")
        }
        
        if !urlRSS.contains("https") {
            urlRSS = urlRSS.replacingOccurrences(of: "http", with: "https")
        }
        
        let trimmed = urlRSS.trimmingCharacters(in: .whitespacesAndNewlines)
        if let url = URL(string: trimmed) {
                UIApplication.shared.open(url)
        } else {
            let alert = AlertView.simple("Noticias", messageAlert: "URL no válida", titleAction: "Aceptar")
            self.present(alert, animated: true, completion:nil)
        }
    }
    
}
