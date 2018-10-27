//
//  MyRSSViewController.swift
//  LectorRSS
//
//  Created by MacBook Pro on 20/10/18.
//  Copyright © 2018 ccc. All rights reserved.
//

import UIKit
import CoreData

class MyRSSViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var RSSArray:NSMutableArray = NSMutableArray()
    
    var textField1: UITextField!
    var textField2: UITextField!
    
    var nombre = ""
    var direccion = ""
    
    var myRSS = [NSManagedObject]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ViewsDesign.settingsNavigationItem(self, navItem: navigationItem)
        
        prefs.set(0, forKey: "RSS_LOADED")

        self.tableView.isHidden = true
        self.loadRSS()
        
        refreshRSS = true

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
            label.text = "Aún no tienes fuentes de RSS, puedes agregar una desde el botón superior."
            label.textColor = colorPrimary
            self.tableView.backgroundView = label
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RSSArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCustomCell") as! TableViewCustomCell
        
        if RSSArray != [] {
            
            let rssDictionary:NSDictionary = RSSArray.object(at: indexPath.row) as! NSDictionary
            
            let name:String = rssDictionary.value(forKey: "name") as! String
            let url:String = rssDictionary.value(forKey: "url") as! String
            let fav:Bool = rssDictionary.value(forKey: "fav") as! Bool
            
            if fav == true {
                cell.nameRSS.textColor = colorPrimary
            } else {
                cell.nameRSS.textColor = UIColor.black
            }

            cell.nameRSS.text = name
            cell.urlRSS.text = url
            
            if cell.buttonDelegate == nil {
                cell.buttonDelegate = self
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rssDictionary:NSDictionary = RSSArray.object(at: indexPath.row) as! NSDictionary
        let fav:Bool = rssDictionary.value(forKey: "fav") as! Bool
        let id:String = rssDictionary.value(forKey: "id") as! String
        
        self.updateFav(id: id, fav: fav)
    }
    
    func cellTapped(_ cell: TableViewCustomCell) {
        
        let row = tableView.indexPath(for: cell)!.row
        
        let rssDictionary:NSDictionary = RSSArray.object(at: row) as! NSDictionary
        
        let id:String = rssDictionary.value(forKey: "id") as! String
        
        let alertController = UIAlertController(title: "Confirmar", message: "¿Borrar fuente?", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.deleteRSS(idRSS: id)

        })
        
        alertController.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)

    }
    
    //MARK: - Add Alert
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Agregar fuente RSS", message: "", preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField(configurationHandler: configurationTextFieldName)
        alert.addTextField(configurationHandler: configurationTextFieldURL)
        
        alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertAction.Style.default, handler:{ (UIAlertAction)in
    
            self.nombre = (self.textField1.text)!
            self.direccion = (self.textField2.text)!
            
            if self.nombre.count == 0 || self.direccion.count == 0 {
                let alert2 = AlertView.simple("Noticias", messageAlert: "El nombre de la fuente y la URL son datos requeridos", titleAction: "Aceptar")
                self.present(alert2, animated: true, completion:nil)
            } else {
                if let url = URL(string: self.direccion) {
                    self.validateRss(url)
                } else {
                    let alertView = AlertView.simple("Noticias", messageAlert: "URL no válida", titleAction: "Aceptar")
                    self.present(alertView, animated: true, completion:nil)
                }
                
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction)in
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    func configurationTextFieldName(textField: UITextField!) {
        if textField != nil {
            self.textField1 = textField!
            textField.placeholder = "Nombre de la fuente"
        }
    }
    
    func configurationTextFieldURL(textField: UITextField!) {
        if textField != nil {
            self.textField2 = textField!
            textField.placeholder = "URL"
        }
    }
    
    //MARK: - Validate RSS
    func validateRss(_ data: URL) {
        
        let myParser: RSSParser = RSSParser().initWithURL(data) as! RSSParser
        if myParser.feeds.count > 0 {
            self.addRSS(nameRSS: self.nombre, urlRSS: self.direccion)
        } else {
            let alertView = AlertView.simple("Noticias", messageAlert: "Fuente RSS no válida", titleAction: "Aceptar")
            self.present(alertView, animated: true, completion:nil)
        }
    
    }
    
    //MARK: - Update Fav
    func updateFav(id:String, fav:Bool) {
        
        if fav == true {
            
            let alert = AlertView.simple("Noticias", messageAlert: "Fuente seleccionada como favorita.", titleAction: "Aceptar")
            self.present(alert, animated: true, completion:nil)
            
        } else {
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MyRSS")
            
            let predicate = NSPredicate(format: "fav == %@", NSNumber(value: true))
            fetchRequest.predicate = predicate
            
            var rssConsulta = [NSManagedObject]()
            rssConsulta = []
            
            do {
                let results = try managedContext.fetch(fetchRequest)
                
                rssConsulta = results as! [NSManagedObject]
                
                if rssConsulta.count > 0 {
                    
                    for i in (0..<rssConsulta.count) {
                        
                        let rss:MyRSS = rssConsulta[i] as! MyRSS
                        rss.setValue(false, forKey: "fav")

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
            
            let managedContext2 = appDelegate.persistentContainer.viewContext
            let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName: "MyRSS")
            
            let predicate2 = NSPredicate(format: "id == %@", id)
            fetchRequest2.predicate = predicate2
            
            var rssConsulta2 = [NSManagedObject]()
            rssConsulta2 = []
            
            do {
                let results2 = try managedContext2.fetch(fetchRequest2)
                
                rssConsulta2 = results2 as! [NSManagedObject]

                if rssConsulta2.count > 0 {
                    for i in (0..<rssConsulta2.count) {
                        let rss:MyRSS = rssConsulta2[i] as! MyRSS
                        rss.setValue(true, forKey: "fav")
                        
                    }
                    
                }
                
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
            do {
                try managedContext2.save()
                
                let alertController = UIAlertController(title: "Noticias", message: "Fuente seleccionada como favorita", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    self.loadRSS()
                })
                self.present(alertController, animated: true, completion: nil)
            } catch {
                print ("There was an error")
            }
        }
        
    }
    
    //MARK: - Load RSS
    func loadRSS () {

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
                let idRss: String = rss.value(forKey: "id") as! String
                let favRss:Bool = rss.value(forKey: "fav") as! Bool
                
                let dictionaryRSS = ["name": nameRss, "url": urlRss, "id": idRss, "fav": favRss] as [String : Any]
                RSSArray.add(dictionaryRSS)
                
           }
            
        }
        
        self.tableView.isHidden = false
        self.tableView.reloadData()
    }
    
    //MARK: - Add RSS
    func addRSS(nameRSS:String, urlRSS:String) {
                
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity =  NSEntityDescription.entity(forEntityName: "MyRSS", in:managedContext)
        let newRSS = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        let id = UUID().uuidString
                
        newRSS.setValue(id, forKey: "id")
        newRSS.setValue(nameRSS, forKey: "name")
        newRSS.setValue(urlRSS, forKey: "url")
        
        if RSSArray == [] {
            newRSS.setValue(true, forKey: "fav")
        } else {
            newRSS.setValue(false, forKey: "fav")
        }
        
        do {
            try managedContext.save()
            myRSS.append(newRSS)
            let alert2 = AlertView.simple("Noticias", messageAlert: "Fuente agregada correctamente.", titleAction: "Aceptar")
            self.present(alert2, animated: true, completion:nil)
            self.loadRSS()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
            let alert2 = AlertView.simple("Error", messageAlert: "Hubo un error al agregar la fuente, por favor inténtalo de nuevo.", titleAction: "Aceptar")
            self.present(alert2, animated: true, completion:nil)
        }
    }
    
    //MARK: - Delete RSS
    func deleteRSS(idRSS: String) {
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MyRSS")
        
        let predicate = NSPredicate(format: "id == %@", idRSS)
        fetchRequest.predicate = predicate
        
        var rssConsulta = [NSManagedObject]()
        rssConsulta = []
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            
            rssConsulta = results as! [NSManagedObject]
            
            if rssConsulta.count > 0 {
                
                for object in rssConsulta {
                    managedContext.delete(object)
                    self.loadRSS()
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
}
