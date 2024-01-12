//
//  ReminderVC.swift
//  MyReminderApp
//
//  Created by fatih arslan on 9.01.2024.
//

import UIKit
import CoreData
import UserNotifications


class ReminderVC: UIViewController {
    
    @IBOutlet weak var tarihLabel: UILabel!
    @IBOutlet weak var saatLabel: UILabel!
    @IBOutlet weak var aciklamaLabel: UILabel!
    @IBOutlet weak var tamamlaImageView: UIImageView!
    @IBOutlet weak var silImageView: UIImageView!
    
    
    var choosenReminderNote = ""
    var choosenReminderId: UUID?
    
   
    override func viewDidLoad() {
           super.viewDidLoad()

           if choosenReminderNote != "" {

               let appDelegate = UIApplication.shared.delegate as! AppDelegate
               let context = appDelegate.persistentContainer.viewContext

               let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminders")

               let idString = choosenReminderId?.uuidString

               fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
               fetchRequest.returnsObjectsAsFaults = false

               do {
                   let results = try context.fetch(fetchRequest)
                   if results.count > 0 {
                       for result in results as! [NSManagedObject] {
                           if let aciklama = result.value(forKey: "note") as? String {
                               aciklamaLabel.text = aciklama

                               if let tarihSaat = result.value(forKey: "reminderDate") as? Date {
                                   // DateFormatter kullanarak tarih ve saat değerlerini ayırma
                                   let dateFormatter = DateFormatter()
                                   dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"

                                   let formattedDate = dateFormatter.string(from: tarihSaat)

                                   let components = formattedDate.components(separatedBy: " ")
                                   tarihLabel.text = components[0] // Tarih
                                   saatLabel.text = components[1] // Saat
                               }
                           }
                       }
                   }
               } catch {
                   print("Veri çekme hatası: \(error)")
               }
           }
        
        tamamlaImageView.isUserInteractionEnabled = true
        let gestrueRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorevSil))
        tamamlaImageView.addGestureRecognizer(gestrueRecognizer)
        
        silImageView.isUserInteractionEnabled = true
        let silGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorevSil))
        silImageView.addGestureRecognizer(silGestureRecognizer)
        
       }
    
    @objc func gorevSil() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        if let choosenReminderId = choosenReminderId {
            // Veriyi sil
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminders")
            fetchRequest.predicate = NSPredicate(format: "id = %@", choosenReminderId as CVarArg)
            
            do {
                let results = try context.fetch(fetchRequest)
                for result in results as! [NSManagedObject] {
                    context.delete(result)
                }
                
                // Veriyi silindiğini kaydet
                try context.save()
                
                // Anasayfaya geri dön ve viewWillAppear fonksiyonunu çağır
                navigationController?.popViewController(animated: true)
                if let viewController = navigationController?.topViewController as? ViewController {
                    viewController.viewWillAppear(true)
                }
                
            } catch {
                print("Veri silme hatası: \(error)")
            }
        }
    }





}
