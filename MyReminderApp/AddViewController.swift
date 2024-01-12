//
//  AddViewController.swift
//  MyReminderApp
//
//  Created by fatih arslan on 9.01.2024.
//



import UIKit
import CoreData
import MobileCoreServices
import UserNotifications
import Foundation
import AVFoundation

class AddViewController: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource{
   
    
    
    //outlets
    @IBOutlet weak var stackView1: UIStackView!
    @IBOutlet weak var stackView2: UIStackView!
    @IBOutlet weak var stackView3: UIStackView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeImage: UIImageView!
    @IBOutlet weak var ringLabel: UILabel!
    @IBOutlet weak var ringImage: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var pickerMinuteView: UIPickerView!
    
    // Variables
    var datePicker: UIDatePicker = UIDatePicker()
    var timePicker: UIDatePicker = UIDatePicker()
    
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    var combinedDate: Date?
    
    
    
    let soundPickerView = UIPickerView()
    var soundData: [String] = ["Huawei", "Astronaut" , "Poco"]
    var selectedAlarmSound: String? = "Huawei"
    
    let data = ["10 dakika önce", "20 dakika önce", "30 dakika önce", "40 dakika önce"] // Açılır liste seçenekleri
    var selectedOption: String? = "10 dakika önce"

   

        override func viewDidLoad() {
            super.viewDidLoad()
           
            
            // UIPickerView için delegate ve dataSource ayarları
            pickerMinuteView.delegate = self
            pickerMinuteView.dataSource = self
            
            // Label'a tıklanma işlemini algılamak için UITapGestureRecognizer oluşturulması
            let dateTapGesture = UITapGestureRecognizer(target: self, action: #selector(datePickClicked))
            stackView1.isUserInteractionEnabled = true
            stackView1.addGestureRecognizer(dateTapGesture)
            
            let timeTapGesture = UITapGestureRecognizer(target: self, action: #selector(timePickClicked))
            stackView2.isUserInteractionEnabled = true
            stackView2.addGestureRecognizer(timeTapGesture)
            
            let ringTapGesture = UITapGestureRecognizer(target: self, action: #selector(showSoundPicker))
            stackView3.isUserInteractionEnabled = true
            stackView3.addGestureRecognizer(ringTapGesture)
            
            // Date picker ayarları
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
            
            // Time picker ayarları
            timePicker.datePickerMode = .time
            timePicker.locale = Locale(identifier: "tr_TR") // Türkçe saat formatı
            timePicker.addTarget(self, action: #selector(timeChanged), for: .valueChanged)
            
           
            soundPickerView.delegate = self
            soundPickerView.dataSource = self
            
            pickerMinuteView.tag = 1
            soundPickerView.tag = 2
            
            if let soundPath = Bundle.main.path(forResource: "Poco", ofType: "mp3") {
                       let soundURL = URL(fileURLWithPath: soundPath)

                       do {
                           // AVAudioPlayer oluşturun ve ses dosyasını yükleyin
                           audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                           audioPlayer!.prepareToPlay()
                       } catch {
                           print("Error loading alarm sound: \(error.localizedDescription)")
                       }
                   }

        }
    
    
    //sounpickerview
    @objc func showSoundPicker() {
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .alert)
        
        soundPickerView.frame = CGRect(x: 8, y: 30, width: 250, height: 160)
        alertController.view.addSubview(soundPickerView)
        
        let selectAction = UIAlertAction(title: "Seç", style: .default) { [weak self] _ in
            self?.dateSelected()
        }
        let cancelAction = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
        
        alertController.addAction(selectAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
        
        // Label'a tıklandığında çalışacak fonksiyon
        @objc func datePickClicked() {
            showDatePicker()
        }
        
        @objc func timePickClicked() {
            showTimePicker()
        }
        
        // Date picker'ı ekranda göstermek için fonksiyon
        func showDatePicker() {
            let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .alert)
            
            datePicker.frame = CGRect(x: 8, y: 30, width: 250, height: 160)
            alertController.view.addSubview(datePicker)
            
            let selectAction = UIAlertAction(title: "Seç", style: .default) { [weak self] _ in
                self?.dateSelected()
            }
            let cancelAction = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
            
            alertController.addAction(selectAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
        
        func showTimePicker() {
            let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .alert)
            
            timePicker.frame = CGRect(x: 8, y: 30, width: 250, height: 160)
            alertController.view.addSubview(timePicker)
            
            let selectAction = UIAlertAction(title: "Seç", style: .default) { [weak self] _ in
                self?.timeSelected()
            }
            let cancelAction = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
            
            alertController.addAction(selectAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
        
        // Date picker'dan tarih seçildiğinde çalışacak fonksiyon
        @objc func dateChanged() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            dateLabel.text = dateFormatter.string(from: datePicker.date)
        }
        
        @objc func timeChanged() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            dateFormatter.locale = Locale(identifier: "tr_TR") // Türkçe tarih formatı
            timeLabel.text = dateFormatter.string(from: timePicker.date)
        }
        
        // Date picker'dan seçilen tarihi onaylama işlemi
        @objc func dateSelected() {
            dateLabel.resignFirstResponder()
        }
    
        @objc func timeSelected() {
           timeLabel.resignFirstResponder()
       }
    
    
        
    // UIPickerViewDelegate ve UIPickerViewDataSource protokollerinden gelen metotlar
       func numberOfComponents(in pickerView: UIPickerView) -> Int {
           return 1 // Tek bir sütun kullanıyoruz
       }

       func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
           if pickerView.tag == 1{
               return data.count
           }
           else if pickerView.tag == 2{
              return soundData.count
           }
           return 0
       }

       func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
           if pickerView.tag == 1{
               return data[row]
           }
           else {
               return soundData[row]
           }
           
       }

       func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
           
           
           if pickerView.tag == 1{
               selectedOption = data[row]
           }
           else {
              selectedAlarmSound = soundData[row]
               print(selectedAlarmSound!)
           }
       }
        
        @IBAction func kaydetButtonClicked(_ sender: Any) {
            guard let selectedOption = selectedOption else {
                    // Kullanıcı henüz bir seçenek seçmemişse işlemi iptal et
                    return
                }

                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext

                let newReminder = NSEntityDescription.insertNewObject(forEntityName: "Reminders", into: context)

                // Tarih ve saat bilgilerini birleştirerek tek bir Date nesnesi oluşturun.
                let calendar = Calendar.current
                let combinedDate = calendar.date(bySettingHour: calendar.component(.hour, from: timePicker.date),
                                                minute: calendar.component(.minute, from: timePicker.date),
                                                second: 0,
                                                of: datePicker.date)

                newReminder.setValue("default", forKey: "alarmSound")
                newReminder.setValue(combinedDate, forKey: "reminderDate")

                newReminder.setValue(textField.text!, forKey: "note")
                newReminder.setValue(UUID(), forKey: "id")
                newReminder.setValue(getMinutesBefore(from: selectedOption), forKey: "minutesBefore")

                do {
                    try context.save()
                    print("Başarıyla kaydedildi")
                } catch {
                    print("Hata oluştu")
                }

                let notificationContent = UNMutableNotificationContent()
                notificationContent.title = "Hatırlatma"
                notificationContent.body = textField.text!
                notificationContent.sound = UNNotificationSound.default

            // Hatırlatma tarihine ve önceki dakikalara bağlı olarak tetikleyiciyi ayarla
                if let validCombinedDate = combinedDate {
                    let triggerDate = validCombinedDate.addingTimeInterval(-TimeInterval(getMinutesBefore(from: selectedOption) * 60))
                    let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                    // Hatırlatıcı için request oluşturun
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)

                    // Bildirimi planla
                    UNUserNotificationCenter.current().add(request) { (error) in
                        if let error = error {
                            print("Bildirim planlama hatası: \(error.localizedDescription)")
                        } else {
                            print("Bildirim başarıyla planlandı")
                        }
                    }

                }
            
            let alarmNotificationContent = UNMutableNotificationContent()
            alarmNotificationContent.title = "Hatırlatma"
            alarmNotificationContent.body = textField.text!
            let extensionn = ".mp3"
            alarmNotificationContent.sound = UNNotificationSound.init(named: UNNotificationSoundName(selectedAlarmSound! + extensionn))
            
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: combinedDate!)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
            // Hatırlatıcı için request oluşturun
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: alarmNotificationContent, trigger: trigger)

            // Bildirimi planla
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print("Bildirim planlama hatası: \(error.localizedDescription)")
                } else {
                    print("Bildirim başarıyla planlandı")
                }
            }
            
      
                NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
                self.navigationController?.popViewController(animated: true)
        }

    
    
 
    
   
    
    // "dakika önce" seçeneğine göre dakika değerini döndüren yardımcı fonksiyon
    func getMinutesBefore(from option: String) -> Int {
        switch option {
        case "10 dakika önce":
            return 1
        case "20 dakika önce":
            return 20
        case "30 dakika önce":
            return 30
        case "40 dakika önce":
            return 40
        default:
            return 0
        }
    }
    
   
}
    

        



