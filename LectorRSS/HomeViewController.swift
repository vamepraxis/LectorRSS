//
//  HomeViewController.swift
//  LectorRSS
//
//  Created by MacBook Pro on 19/10/18.
//  Copyright © 2018 ccc. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, XMLParserDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    let progressHUD = ProgressHUD(text: "Actualizando")

    var refreshControl: UIRefreshControl!
    
    var myFeed: NSMutableArray = []
    var url: URL!
    
    var RSSArray:NSMutableArray = NSMutableArray()

    var myRSS = [NSManagedObject]()
    var newsOffline = [NSManagedObject]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache:NSCache<AnyObject, AnyObject>!

    lazy var searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 50, height: 40))
    var textSearch = ""
    var searchActive: Bool = false
    var searchBarActive: Bool = false
    
    var loaded:Bool = false
    
    var filteredArray: NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Actualizando")
        
        refreshControl.addTarget(self, action: #selector(HomeViewController.refresh(_:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
        self.addSlideMenuButton()
        
        session = URLSession.shared
        task = URLSessionDownloadTask()
        self.cache = NSCache()
        
        searchBar.placeholder = "Buscar noticia"
        self.searchBar.delegate = self
        
        self.imageView.isHidden = true
        self.tableView.isHidden = true
        
        ViewsDesign.hiddeNavigationItem(self, navItem: navigationItem)
        ViewsDesign.translucentNavigationItem(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        if refreshRSS == true { //Actualizar
            let time = DispatchTime.now() + 0
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.tableView.isHidden = true
                ViewsDesign.settingsNavigationItem(self, navItem: self.navigationItem)
                self.view.addSubview(self.progressHUD)
                self.progressHUD.isHidden = false
                self.loadNews()
            }
        } else if loaded != true { //Cargar al entrar
            let time = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.tableView.isHidden = true
                self.imageView.isHidden = false
                self.loadNews()
            }
        }
    }
    
    //MARK: - Refresh
    @objc func refresh(_ sender: AnyObject) {
        self.cache.removeAllObjects()
        self.myFeed = []
        self.filteredArray = []
        
        LoadingView.showActivityIndicator(view)
        
        self.loadMyRSS()
        self.refreshControl?.endRefreshing()
    }
    
    //MARK: - Load News
    func loadNews() {
        
        self.cache.removeAllObjects()

        self.myFeed = []
        self.filteredArray = []
        
        self.tableView.isHidden = true
        LoadingView.showActivityIndicator(self.view)
        
        self.loadMyRSS()
    }
    
    func loadData() {
        
        for i in (0..<RSSArray.count) {
            
            let dictionaryRSS: NSDictionary = RSSArray.object(at: i) as! NSDictionary
            let urlString:String = dictionaryRSS.value(forKey: "url") as! String
            let urlRSS = URL (string: urlString)!
            loadRss(urlRSS);

        }
        
        if myFeed == [] {
            
            if myRSS != [] { //Offline
                refreshRSS = false
                self.loadOffline()
            } else { //No hay RSS favorito
                self.showRSS()
            }
            
        } else { //Mostrar RSS
            
            self.deleteNews()
            self.saveNews()
            
            filteredArray.addObjects(from: myFeed as! [Any])
            
            self.showRSS()
        
        }
        
    }
    
    func loadRss(_ data: URL) {

        let myParser: RSSParser = RSSParser().initWithURL(data) as! RSSParser
        myFeed.addObjects(from: myParser.feeds as! [Any])
        
    }
    
    func showRSS() {
        DispatchQueue.main.async(execute: { () -> Void in
            
            ViewsDesign.settingsNavigationItem(self, navItem: self.navigationItem)
            LoadingView.hideActivityIndicator(self.view)
            
            self.imageView.isHidden = true
            self.progressHUD.isHidden = true
            
            self.loaded = true
            refreshRSS = false
            
            self.tableView.isHidden = false
            self.tableView.reloadData()
        })
    }
    
    //MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = CGPoint(x: 160, y: 284)
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        
        if  RSSArray.count > 0 {
            label.text = ""
            self.tableView.backgroundView = label
            return 1
        } else {
            label.text = "Aún no tienes fuentes de RSS, puedes agregar una desde Preferencias en el menú lateral."
            label.textColor = colorPrimary
            self.tableView.backgroundView = label
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCustomCell") as! TableViewCustomCell
        
        if filteredArray != [] {
            
            cell.titleHome.text = (filteredArray.object(at: indexPath.row) as AnyObject).object(forKey: "title") as? String
            cell.dateHome.text = (filteredArray.object(at: indexPath.row) as AnyObject).object(forKey: "pubDate") as? String
            
            if let description:String = (filteredArray.object(at: indexPath.row) as AnyObject).object(forKey: "description") as? String {
                
                let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
                cell.descriptionHome.text = trimmedDescription
                
            } else {
                cell.descriptionHome.text = (filteredArray.object(at: indexPath.row) as AnyObject).object(forKey: "description") as? String
            }
            
            cell.imageViewHome.image = UIImage(named: "rss")

            if let media_data:Data = (filteredArray.object(at: indexPath.row) as AnyObject).object(forKey: "image_data") as? Data {
                
                if media_data.isEmpty == false {
                    
                    if let image = UIImage(data:media_data) {
                        cell.imageViewHome.image = image
                    }
            
                }
                
             }
            
        }
        
        return cell
    
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let link = (filteredArray.object(at: indexPath.row) as AnyObject).object(forKey: "link") as? String
        let title:String = (filteredArray.object(at: indexPath.row) as AnyObject).object(forKey: "title") as! String
        let date:String = (filteredArray.object(at: indexPath.row) as AnyObject).object(forKey: "pubDate") as! String
        let description:String = (filteredArray.object(at: indexPath.row) as AnyObject).object(forKey: "description") as! String
        
        var imageData:Data = Data()
        if let media_data:Data = (filteredArray.object(at: indexPath.row) as AnyObject).object(forKey: "image_data") as? Data {
            
            if media_data.isEmpty == false {
                
                if UIImage(data:media_data) != nil {
                    imageData = media_data
                }
                
            }
            
        }

        prefs.set(link, forKey: "LINK_RSS")
        prefs.set(title, forKey: "TITLE_RSS")
        prefs.set(date, forKey: "DATE_RSS")
        prefs.set(description, forKey: "DESCRIPTION_RSS")
        prefs.set(imageData, forKey: "DATA_RSS")
        prefs.synchronize()
        self.performSegue(withIdentifier: "home_news", sender: self)
        
    }

    //MARK: - Load RSS Fav
    func loadMyRSS () {
        
        RSSArray = []
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MyRSS")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            myRSS = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        if myRSS.count > 0 {
            
            for i in (0..<myRSS.count) {
                
                let rss:MyRSS = myRSS[i] as! MyRSS
                
                let nameRss:String = rss.value(forKey: "name") as! String
                let urlRss:String = rss.value(forKey: "url") as! String
                let favRss:Bool = rss.value(forKey: "fav") as! Bool
                let idRss:String = rss.value(forKey: "id") as! String
                
                if favRss == true {
                    let dictionaryRSS = ["name": nameRss, "url": urlRss, "fav": favRss, "id": idRss] as [String : Any]
                    RSSArray.add(dictionaryRSS)
                }
                
            }
            
        }
       
        self.loadData()
    }
    
    //MARK: - Delete News
    func deleteNews() {
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
        
        var newsConsulta = [NSManagedObject]()
        newsConsulta = []
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            
            newsConsulta = results as! [NSManagedObject]
            
            if newsConsulta.count > 0 {
                
                for object in newsConsulta {
                    managedContext.delete(object)
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        do {
            try managedContext.save()
        } catch {
            print ("There was an error")
        }
        
    }
    
    //MARK: - Save News
    func saveNews() {
        
        var myFeedTemp: NSMutableArray = NSMutableArray()
        myFeedTemp = []
        
        for i in (0..<myFeed.count) {
            
            let rssDictionary:NSDictionary = myFeed.object(at: i) as! NSDictionary
            
            let title:String = rssDictionary.value(forKey: "title") as! String
            let date:String = rssDictionary.value(forKey: "pubDate") as! String
            let description:String = rssDictionary.value(forKey: "description") as! String
            let link:String = rssDictionary.value(forKey: "link") as! String
            let media:String = rssDictionary.value(forKey: "media") as! String
    
            var imageData:Data = Data()
            
            if media != "" {
                if let url:URL = URL(string:media) {
                    if let dataImage = try? Data(contentsOf: url) {
                        let image = UIImage(data:dataImage)
                        //let imageData = UIImageJPEGRepresentation(image!, 0.5)
                        imageData = image!.jpegData(compressionQuality: 0.5)!
                    }
                }
            }
            
           
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity =  NSEntityDescription.entity(forEntityName: "News", in:managedContext)
            let newRSS = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            newRSS.setValue(title, forKey: "title")
            newRSS.setValue(date, forKey: "date")
            newRSS.setValue(description, forKey: "description_new")
            newRSS.setValue(link, forKey: "link")
            newRSS.setValue(media, forKey: "image_url")
            newRSS.setValue(imageData, forKey: "image_data")

            let dictionaryRSS = ["title": title, "pubDate": date, "description": description, "link": link, "media": media, "image_data": imageData] as [String : Any]
            
            myFeedTemp.add(dictionaryRSS)
            
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
        }
        
        myFeed = []
        myFeed.addObjects(from: myFeedTemp as! [Any])
        
    }
    
    //MARK: - Load offline
    func loadOffline() {
        
        myFeed = []
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            newsOffline = results as! [NSManagedObject]

        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        if newsOffline.count > 0 {
                        
            for i in (0..<newsOffline.count) {
                
                let new:News = newsOffline[i] as! News
                
                var imageData:Data = Data()
                
                let titleNew:String = new.value(forKey: "title") as! String
                let descriptionNew:String = new.value(forKey: "description_new") as! String
                let dateNew:String = new.value(forKey: "date") as! String
                let linkNew:String = new.value(forKey: "link") as! String
                let media:String = new.value(forKey: "image_url") as! String
                if let image_data:Data = new.value(forKey: "image_data") as? Data {
                    imageData = image_data
                }
                let dictionaryRSS = ["title": titleNew, "pubDate": dateNew, "description": descriptionNew, "link": linkNew, "media": media, "image_data": imageData] as [String : Any]
                
                myFeed.add(dictionaryRSS)
            }
            
            filteredArray.addObjects(from: myFeed as! [Any])

        }
    
        DispatchQueue.main.async(execute: { () -> Void in
            let alert = AlertView.simple("Noticias", messageAlert: "Sin conexión a internet, se mostrarán noticias guardadas.", titleAction: "Aceptar")
            self.present(alert, animated: true, completion:nil)
            
            self.showRSS()
            self.loaded = false
            
        })
        
    }
   
    //MARK: - Search
    @IBAction func searchAction(_ sender: UIBarButtonItem) {
        if (searchBarActive == false) {
            self.navigationItem.titleView = searchBar
            searchBarActive = true
            self.searchButton.image = UIImage(named: "button_close")
        } else {
            self.navigationItem.titleView = nil
            self.navigationItem.title = "Noticias"
            searchBarActive = false
            self.searchButton.image = UIImage(named: "button_search")
            
            self.filteredArray = []
            self.filteredArray.addObjects(from: myFeed as! [Any])
            self.searchBar.text = ""
            self.cache.removeAllObjects()
            self.tableView.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let searchPredicate = NSPredicate(format: "title CONTAINS[C] %@", searchText)
        let array = self.myFeed.filter { searchPredicate.evaluate(with: $0) }
        
        textSearch = searchText
        
        if(array.count == 0) {
            searchActive = false;
        } else {
            self.filteredArray = []
            self.filteredArray.addObjects(from: array)
            searchActive = true;
        }
        self.cache.removeAllObjects()
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        self.navigationItem.titleView = nil
        self.navigationItem.title = "Noticias"
        
        self.searchButton.image = UIImage(named: "button_search")
        
        self.filteredArray = []
        self.filteredArray.addObjects(from: myFeed as! [Any])
        self.searchBar.text = ""
        self.cache.removeAllObjects()
        self.tableView.reloadData()
        
        searchBar.resignFirstResponder()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        
        self.navigationItem.titleView = nil
        self.navigationItem.title = "Noticias"
        searchBarActive = false
        self.searchButton.image = UIImage(named: "button_search")
        
        let searchPredicate = NSPredicate(format: "title CONTAINS[C] %@", textSearch)
        let array = self.myFeed.filter { searchPredicate.evaluate(with: $0) }
                
        if(array.count == 0) {
            searchActive = false;
        } else {
            self.filteredArray = []
            self.filteredArray.addObjects(from: array)
            searchActive = true;
        }
        self.cache.removeAllObjects()
        self.tableView.reloadData()
    }
    
}
