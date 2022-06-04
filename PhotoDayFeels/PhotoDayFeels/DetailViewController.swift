//
//  DetailViewController.swift
//  PhotoDayFeels
//
//  Created by Yazgülü Türker on 31.05.2022.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var feelingsText: UITextField!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    var choosenPainting = ""
    var choosenPaintingId :UUID?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //DetailViewController kullanıcı hangi modu seçerse seçsin light da kullanılacağını söylüyorum.
        //overrideUserInterfaceStyle = .light
        
        if choosenPainting != ""
        {
            saveButton.isHidden = true
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
        
        //Seçili idyi stringe çevirir.
        let stringId = choosenPaintingId?.uuidString
        
        //Filtreleme işlemine başlandı
        fetchRequest.predicate = NSPredicate(format: "id = %@", stringId!)
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
         let results = try context.fetch(fetchRequest)
            if results.count>0
            {
                //NSManagedObject dizisi verir.
            for result in results as! [NSManagedObject]{
                
                if let title = result.value(forKey: "title") as? String
                {
                    titleText.text = title
                }
                if let feelings = result.value(forKey: "feelings") as? String
                {
                    feelingsText.text = feelings
                }
                
               
                if let imageData = result.value(forKey: "image") as? Data
                {
                    //Veritabanınfa data olarak tutulan fotoğrafı fotoğrafa çeviriyor.
                    imageView.image = UIImage(data: imageData)
                }
                
            }
                
            }
        }
        catch
        {
            print("error")
            
        }
        
        }
        
        else
        {
            saveButton.isEnabled = false
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        
        //Kullanıcı görsele tıklayabilir.
        imageView.isUserInteractionEnabled = true
        
        let gestureRecognizerTap = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(gestureRecognizerTap)


    }
    

    
    @objc func selectImage()
    {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        //Fotoğrafı nasıl seçeceğini belirledi.
        picker.sourceType = .photoLibrary
        //Kullanıcı fotoğrafı editleyebilsin mi
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    //Fotoğraf seçme bitince yapılacaklar
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //imageviewe galeriden seçtiğimiz fotoyu atıyoryuz
        imageView.image = info[.originalImage] as? UIImage
        //Kapatırken bişey olsun isteniyormu
        
        saveButton.isEnabled = true
        self.dismiss(animated: true,completion: nil)
    }
    @objc func hideKeyboard()
    {
        view.endEditing(true)
    }
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        
        //Veritabanı kaydetme işlemi
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //Veritabanının adına erişiyoruz.
        let newPhotos =  NSEntityDescription.insertNewObject(forEntityName: "Photos", into: context)
        
         
        newPhotos.setValue(feelingsText.text, forKey: "feelings")
        newPhotos.setValue(titleText.text, forKey: "title")
        newPhotos.setValue(UUID(), forKey: "id")
        //seçilen fotoğrafı jpege çevirdik 0.5 zipleyerek.
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPhotos.setValue(data, forKey: "image")
        
     
        do
        {
         try context.save()
            print("success")
        }
        catch
        {
            print("error")
        }
        //Diğer viewControllera mesaj gönderiyor.
      
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        self.navigationController?.popViewController(animated: true)

       

    }
    

}
