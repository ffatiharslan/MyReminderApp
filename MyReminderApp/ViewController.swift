//
//  ViewController.swift
//  MyReminderApp
//
//  Created by fatih arslan on 9.01.2024.
//

import UIKit
import CoreData
import UserNotifications

class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    
    var idArray = [UUID]()
    var noteArray = [String]()
    var dateArray = [Date]()
    
    var selectedReminderNote = ""
    var selectedReminderId: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
        getData()
    }
    
    @objc func getData() {
        noteArray.removeAll(keepingCapacity: false)
        dateArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminders")
        fetchRequest.returnsObjectsAsFaults = false

        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let note = result.value(forKey: "note") as? String {
                        self.noteArray.append(note)
                    }
                    if let date = result.value(forKey: "reminderDate") as? Date {
                        self.dateArray.append(date)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                }
                self.tableView.reloadData()
            }
        } catch {
            print("getData Error: \(error)")
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
         
            // Tarih biçimini belirlemek için DateFormatter kullanalım
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm" // İhtiyacınıza göre biçimi değiştirin
            
            // Tarihi uygun biçime dönüştürelim
            let formattedDate = dateFormatter.string(from: dateArray[indexPath.row])
            
            // Başlık (title) kısmına tarihi ekleyelim
            cell.textLabel?.text = formattedDate
            
            // Altyazı (subtitle) kısmına notu ekleyelim
            cell.detailTextLabel?.text = noteArray[indexPath.row]
           
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toReminderVC"{
            let destinationVC =  segue.destination as! ReminderVC
            destinationVC.choosenReminderNote = selectedReminderNote
            destinationVC.choosenReminderId = selectedReminderId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedReminderNote = noteArray[indexPath.row]
        selectedReminderId = idArray[indexPath.row]
        
        performSegue(withIdentifier: "toReminderVC", sender: nil )
    }

    @IBAction func addButtonClicked(_ sender: Any) {
        selectedReminderNote = ""
        performSegue(withIdentifier: "toAddViewController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminders")
            
            let idString = idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let id  = result.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row]{
                                context.delete(result)
                                noteArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                dateArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do{
                                    try context.save()
                                }
                                catch{
                                    print("error")
                                }
                                break
                            }
                        }
                    }
                }
                
            }
            catch{
                print("error")
            }
        }
    }
}

