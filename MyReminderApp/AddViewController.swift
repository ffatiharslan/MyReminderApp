//
//  AddViewController.swift
//  MyReminderApp
//
//  Created by fatih arslan on 9.01.2024.
//

import UIKit
import CoreData
import MediaPlayer
import AVFoundation
import MobileCoreServices
import UserNotifications
import Foundation

class AddViewController: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource,  MPMediaPickerControllerDelegate , AVAudioPlayerDelegate{
    
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
    @IBOutlet weak var pickerView: UIPickerView!
    
    // Variables
    var datePicker: UIDatePicker = UIDatePicker()
    var timePicker: UIDatePicker = UIDatePicker()
    
    var selectedRingtoneURL: URL?
    
    var audioPlayer: AVAudioPlayer?
    
        let data = ["10 dakika önce", "20 dakika önce", "30 dakika önce", "40 dakika önce"] // Açılır liste seçenekleri
        var selectedOption: String?
        
        override func viewDidLoad() {
            super.viewDidLoad()
           
            
            // UIPickerView için delegate ve dataSource ayarları
            pickerView.delegate = self
            pickerView.dataSource = self
            
            // Label'a tıklanma işlemini algılamak için UITapGestureRecognizer oluşturulması
            let dateTapGesture = UITapGestureRecognizer(target: self, action: #selector(datePickClicked))
            stackView1.isUserInteractionEnabled = true
            stackView1.addGestureRecognizer(dateTapGesture)
            
            let timeTapGesture = UITapGestureRecognizer(target: self, action: #selector(timePickClicked))
            stackView2.isUserInteractionEnabled = true
            stackView2.addGestureRecognizer(timeTapGesture)
            
            let ringTapGesture = UITapGestureRecognizer(target: self, action: #selector(ringTapClicked))
            stackView3.isUserInteractionEnabled = true
            stackView3.addGestureRecognizer(ringTapGesture)
            
            // Date picker ayarları
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
            
            // Time picker ayarları
            timePicker.datePickerMode = .time
            timePicker.locale = Locale(identifier: "tr_TR") // Türkçe saat formatı
            timePicker.addTarget(self, action: #selector(timeChanged), for: .valueChanged)
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
            return data.count // Açılır liste seçeneklerinin sayısı
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return data[row] // Her bir satır için metin
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            selectedOption = data[row] // Kullanıcının seçtiği seçeneği kaydet
            // Seçilen değeri kullanabilirsiniz, örneğin:
            // print("Seçilen seçenek: \(selectedOption ?? "")")
        }
        
        @IBAction func kaydetButtonClicked(_ sender: Any) {
            
            guard let selectedOption = selectedOption else {
                   // Kullanıcı henüz bir seçenek seçmemişse işlemi iptal et
                   return
               }
           
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context  = appDelegate.persistentContainer.viewContext
            
            let newReminder = NSEntityDescription.insertNewObject(forEntityName: "Reminders", into: context)
            
            // Tarih ve saat bilgilerini birleştirerek tek bir Date nesnesi oluşturun.
                let calendar = Calendar.current
                let combinedDate = calendar.date(bySettingHour: calendar.component(.hour, from: timePicker.date),
                                                minute: calendar.component(.minute, from: timePicker.date),
                                                second: 0,
                                                of: datePicker.date)
            
            // Eğer kullanıcı bir zil sesi seçtiyse, seçilen zil sesini kaydet
               if let selectedRingtoneURL = selectedRingtoneURL {
                   // Zil sesini Core Data'ya kaydetmek için bu URL'yi string'e dönüştürün
                   let ringtoneURLString = selectedRingtoneURL.absoluteString
                   newReminder.setValue(ringtoneURLString, forKey: "alarmSound")
               } else {
                   // Kullanıcı zil sesi seçmediyse, varsayılan değeri kullanabilirsiniz.
                   newReminder.setValue("alarm", forKey: "alarmSound")
               }
            
            newReminder.setValue(combinedDate, forKey: "reminderDate")
            
            
            newReminder.setValue(textField.text!, forKey: "note")
            newReminder.setValue(UUID(), forKey: "id")
            newReminder.setValue(getMinutesBefore(from: selectedOption), forKey: "minutesBefore")
            
            
            var dateComponents = DateComponents()
            dateComponents.minute = -getMinutesBefore(from: selectedOption)
            
            let alarmDate = calendar.date(byAdding: dateComponents, to: combinedDate ?? Date()) // uygun bir Date nesnesi oluşturun
            
            scheduleNotification(alarmDate: alarmDate!)
            
            
            do{
                try context.save()
                print("success")
            }
            catch{
                print("error")
            }
            
            NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
                    self.navigationController?.popViewController(animated: true)
            
        }
    
    // "dakika önce" seçeneğine göre dakika değerini döndüren yardımcı fonksiyon
    func getMinutesBefore(from option: String) -> Int {
        switch option {
        case "10 dakika önce":
            return 10
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
    
    
    
    
    //---------------------------------------------------------------------
    
    @objc func ringTapClicked() {
        let audioPickerController = MPMediaPickerController(mediaTypes: .anyAudio)
        audioPickerController.delegate = self
        audioPickerController.allowsPickingMultipleItems = false
        present(audioPickerController, animated: true, completion: nil)
    }
    
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
            dismiss(animated: true, completion: nil)
            
            // Kullanıcı bir zil sesi seçtiğinde, seçilen öğenin URL'sini al
            if let selectedSong = mediaItemCollection.items.first {
                selectedRingtoneURL = selectedSong.assetURL
                // Zil sesi seçildiğinde bir işlem yapabilir veya sadece URL'yi saklayabilirsiniz.
            }
        }
        
        func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
            dismiss(animated: true, completion: nil)
            // Kullanıcı seçimi iptal ettiğinde bir işlem yapabilirsiniz.
        }
    
    
    
    
    
    func scheduleNotification(alarmDate: Date) {
        func saveAudioFile(data: Data, fileName: String) throws -> URL {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let soundFileURL = documentsDirectory.appendingPathComponent(fileName)
            try data.write(to: soundFileURL)
            return soundFileURL
        }

        let content = UNMutableNotificationContent()
        content.title = "Hatırlatma"
        content.body = textField.text ?? "Bir hatırlatıcınız var!"

        // Bildirime zil sesi ekle
        if let selectedRingtoneURL = selectedRingtoneURL {
            do {
                let audioData = try Data(contentsOf: selectedRingtoneURL)
                let soundFileURL = try saveAudioFile(data: audioData, fileName: "customRingtone.caf")
                content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundFileURL.absoluteString))
            } catch {
                print("Error creating sound file: \(error.localizedDescription)")
            }
        } else {
            content.sound = UNNotificationSound.default
        }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: alarmDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "yourNotificationIdentifier", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Notification scheduling error: \(error)")
            } else {
                print("Notification scheduled successfully")
                
                // Bildirim başarıyla planlandığında handleReminder fonksiyonunu çağır
                self.handleReminder()
            }
        }
    }

    
    
    
    //----------------------------------------------------------------------------------------
    func playAlarmSound() {
            guard let soundURL = Bundle.main.url(forResource: "alarm", withExtension: "mp3") else {
                return
            }

            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch let error {
                print("Error playing alarm sound: \(error.localizedDescription)")
            }
        }

        // AVAudioPlayerDelegate metodu
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            if flag {
                // Alarm sesi başarıyla çalındı, isteğe bağlı olarak burada ek işlemler yapabilirsiniz.
            }
        }

        // ...

        // Hatırlatıcı tetiklendiğinde bu fonksiyonu çağırabilirsiniz
        func handleReminder() {
            // Hatırlatıcı zamanı geldiğinde bu fonksiyon çağrılacak
            playAlarmSound()
        }
}


