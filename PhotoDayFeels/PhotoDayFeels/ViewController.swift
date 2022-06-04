//
//  ViewController.swift
//  PhotoDayFeels
//
//  Created by Yazgülü Türker on 31.05.2022.
//

import UIKit
import CoreData
import LocalAuthentication

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
  

    @IBOutlet weak var tableView: UITableView!
    var titleArray = [String]()
    var idArray = [UUID]()
    var selectedId :UUID?
    var selectedTitle = ""
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
      
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
      
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addPhoto))
        
        
        //DetailViewController kullanıcı hangi modu seçerse seçsin dark da kullanılacağını söylüyorum.
        //overrideUserInterfaceStyle = .dark
        
        getData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    
        let authContext = LAContext()
        var nsError : NSError?
        
        //Pointer olarak istediği için &işareti koydum.
        if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &nsError)
        {
            authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "is it you") { sucess, error in
                if sucess == true
                {
                    print("success")
                }
                
                else
                {
                    print("error")
                }
            }
            
            
        }
      
       NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
       
    }
    @objc func getData()
    {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //Çekme için yapılan işlemler
        
        
        //Veritabanı adı verildi.
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            
            //Veritabanından çekme işlemi yapılırsa results değişkenine atılıyor yapılmazsa catch kısmı yakalıyor.
            let results = try context.fetch(fetchRequest)
            titleArray.removeAll(keepingCapacity: true)
            idArray.removeAll(keepingCapacity: true)
        for result in results as! [NSManagedObject]
        {
           
            if let title = result.value(forKey:"title") as? String
            {
                titleArray.append(title)
            }
            if let id  = result.value(forKey: "id") as? UUID
            {
                idArray.append(id)
            }
            //tableviewdeki verileri sürekli yeniler.
            self.tableView.reloadData()
            
           
        }
        }
        
        catch
        {
            print("error")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        
        return cell
        
        
    }
    //Detailviewcontrollerdaki bilgilere ulaşabilmek için yapılır.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == ("toDetailPhotoVC")
        {
            let destinationVc = segue.destination as! DetailViewController
            destinationVc.choosenPainting = selectedTitle
            destinationVc.choosenPaintingId = selectedId
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedTitle = titleArray[indexPath.row]
        selectedId = idArray [indexPath.row]
        performSegue(withIdentifier: "toDetailPhotoVC", sender: nil)
    }
    @objc func addPhoto()
    {
        selectedTitle = ""
        
        performSegue(withIdentifier: "toDetailPhotoVC", sender: nil)
    }
    
    //Table silme işlemi
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
             
            //Veritabanı erişimi
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
            
            //İlgili idnin stringe dönüştürülmesi
            let idString = idArray[indexPath.row].uuidString
            
            //İlgili id'yi Filtreleme yapılarak getirilmesi
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            do
            {
                let results = try context.fetch(fetchRequest)
                
                if results.count>0
                {
                    for result in results as! [NSManagedObject]
                    {
                        if let id = result.value(forKey: "id") as? UUID
                        {
                         
                            if id == idArray[indexPath.row]
                            {
                                context.delete(result)
                                titleArray.remove(at:indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                do{
                                    try context.save()
                                    
                                }
                                catch
                                {
                                    print("error")
                                }
                            }
                        }
                        
                        
                    }
                }
            }
            catch
            {
                print("error")
            }
            fetchRequest.returnsObjectsAsFaults = false
            
            
        
        }
        
        
    }
    
    
    //trait yapıldığı an algılar.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        if userInterfaceStyle == .dark
        {
            self.tableView.backgroundColor = UIColor.blue
        }
        
        
    }

}

