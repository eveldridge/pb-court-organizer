//
//  GameTimerViewController.swift
//  PBCourtOrganizer
//
//  Created by Evelyn Eldridge on 2017-09-22.
//  Copyright © 2017 codeDependent Software. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications

class GameTimerViewController: UIViewController {
  
  @IBOutlet weak var timerStepper: UIStepper!
  @IBOutlet weak var timerLabel: UILabel!
  @IBOutlet weak var allocatedLabel: UILabel!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var resetButton: UIButton!
  
  var countdownSeconds = 60 * 15.0  // Default to 15 minutes.
  var timer = Timer()
  var isTimerRunning = false
  var resumeTapped = false
  var endTime = Date()
  var player: AVAudioPlayer?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup the View
    allocatedLabel.text = SharedAssets.sharedInstance.teamsAllocated
    resetTimer()
    
    // Check for UserNotification Permissions
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
        switch notificationSettings.authorizationStatus {
        case .notDetermined:
          self.requestAuthorization(completionHandler: { (success) in
            guard success else { return }
            // Do nothing
          })
          break
        // Request Authorization
        case .authorized:
          // Do nothing
          break
        case .denied:
          self.showErrorAlert(title: "Notifications are Required", message: "Please Allow Notifications to be used in this app to recieve the alarm")
        }
      }
    } else {
      if !areNotificationsEnabled() {
        self.showErrorAlert(title: "Notifications are Required", message: "Please Allow Notifications to be used in this app to recieve the alarm")
      }
    }
  }
  
  private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
    // Request Authorization
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
        if let error = error {
          print("Request Authorization Failed (\(error), \(error.localizedDescription))")
        }
        
        completionHandler(success)
      }
    } else {
      // Fallback on earlier versions
    }
  }
  
  func resetTimer () {
    player?.stop()
    timerStepper.value = 15
    countdownSeconds = timerStepper.value * 60
    
    // EV TESTING
//    countdownSeconds = 15
    
    timerLabel.text = timeString(time: TimeInterval(countdownSeconds))
    startButton.isEnabled = true
    startButton.alpha = 1.0
    startButton.setTitle("Start",for: .normal)
    isTimerRunning = false
    timer.invalidate()
    UIApplication.shared.cancelAllLocalNotifications()
    timerStepper.isEnabled = true
    timerStepper.alpha = 1.0
  }
  
  func pauseTimer () {
    isTimerRunning = false
    timer.invalidate()
    UIApplication.shared.cancelAllLocalNotifications()
    startButton.setTitle("Start",for: .normal)
  }

  func startTimer () {
    endTime = Date().addingTimeInterval(countdownSeconds)
    createNotification()
    isTimerRunning = true
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    startButton.setTitle("Pause",for: .normal)
    timerStepper.isEnabled = false
    timerStepper.alpha = 0.5
  }
  
  func stopTimer () {
    timer.invalidate()
    isTimerRunning = false
    startButton.setTitle("Complete", for: .normal)
    startButton.isEnabled = false
    startButton.alpha = 0.5
    timerLabel.text = timeString(time: 0)
  }
  
  func updateTimer() {
    if countdownSeconds < -2 {
      stopTimer()
    } else if countdownSeconds < 1 {
      stopTimer()
      playSound()
    } else {
      countdownSeconds = endTime.timeIntervalSinceNow
      if countdownSeconds < 1 {
        countdownSeconds = 0
      }
      timerLabel.text = timeString(time: TimeInterval(countdownSeconds))
    }
  }
  
  func areNotificationsEnabled() -> Bool {
    guard let settings = UIApplication.shared.currentUserNotificationSettings else {
      return false
    }
    
    return settings.types.intersection([.alert, .badge, .sound]).isEmpty != true
  }
  

  
  func playSound() {
    guard let url = Bundle.main.url(forResource: "GotGameBlipSynth", withExtension: "caf") else { return }
    
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
      try AVAudioSession.sharedInstance().setActive(true)
      
      
      
      /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
//      player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
      
      // iOS 10 and earlier require the following line:
       player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeCoreAudioFormat)
      
      guard let player = player else { return }
      
      player.play()
      
    } catch let error {
      print(error.localizedDescription)
    }
  }
  
  func createNotification () {
    if areNotificationsEnabled() {
      // Create Notification Content
      if #available(iOS 10.0, *) {
        let notificationContent = UNMutableNotificationContent()
        // Configure Notification Content
        notificationContent.title = "PB Court Organizer"
        notificationContent.subtitle = "Game Timer"
        notificationContent.body = "Time is UP!"
        notificationContent.sound = UNNotificationSound.default()
        
        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: countdownSeconds, repeats: false)
        
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "cocoacasts_local_notification", content: notificationContent, trigger: notificationTrigger)
        
        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
          if let error = error {
            print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
          }
        }
      } else {
        // Fallback on earlier versions
        //make the local notification
        let localNotification = UILocalNotification()
        localNotification.fireDate = endTime
        localNotification.alertBody = "Game Over!"
        localNotification.soundName = "GotGameBlipSynth.caf"
        UIApplication.shared.scheduleLocalNotification(localNotification)
        
      }
    } else {
      print(("No notifications enabled"))
    }
  }
  
  
  
  @IBAction func changeTime(_ sender: Any) {
    countdownSeconds = timerStepper.value * 60
    timerLabel.text = timeString(time: TimeInterval(countdownSeconds))
  }
  
  @IBAction func pressStart(_ sender: Any) {
    if isTimerRunning == false {
      startTimer()
    } else {
      pauseTimer()
    }
    let systemSoundID: SystemSoundID = 1103
    AudioServicesPlaySystemSound (systemSoundID)
    
  }
  @IBAction func pressEndPlay(_ sender: Any) {
    let message = "You won't be able to view these games again"
    
    let alert = UIAlertController(title: "Are you sure you're done?", message: message, preferredStyle: UIAlertControllerStyle.alert)
    let cancelButton = UIAlertAction(title: "No, Stay Here", style: UIAlertActionStyle.cancel) { (alert) -> Void in
      
    }
    let deleteButton = UIAlertAction(title: "Yes, Close", style: UIAlertActionStyle.destructive) { (alert) -> Void in
      self.dismiss(animated: true)
    }
    alert.addAction(cancelButton)
    alert.addAction(deleteButton)
    
    self.present(alert, animated: true, completion: nil)
  }
  
  @IBAction func pressReset(_ sender: Any) {
    let systemSoundID: SystemSoundID = 1103
    AudioServicesPlaySystemSound (systemSoundID)
    resetTimer()
  }
  
  func timeString(time:TimeInterval) -> String {
    let hours = Int(time) / 3600
    let minutes = Int(time) / 60 % 60
    let seconds = Int(time) % 60
    if hours > 0 {
      return String(format:"%0i:%02i:%02i", hours, minutes, seconds)
    } else {
      return String(format:"%02i:%02i", minutes, seconds)
    }
  }
  
  deinit {
    UIApplication.shared.cancelAllLocalNotifications()
  }
  
  func showErrorAlert (title:String, message:String) {
    DispatchQueue.main.async {
      let alert: UIAlertController = UIAlertController(title: title , message:message , preferredStyle: .alert)
      let cancelActionButton: UIAlertAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .cancel) { action -> Void in
      }
      alert.addAction(cancelActionButton)
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}
