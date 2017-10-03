//
//  GameTimerViewController.swift
//  PBCourtOrganizer
//
//  Created by Evelyn Eldridge on 2017-09-22.
//  Copyright © 2017 codeDependent Software. All rights reserved.
//

import UIKit
import AVFoundation

class GameTimerViewController: UIViewController {

  @IBOutlet weak var timerStepper: UIStepper!
  @IBOutlet weak var timerLabel: UILabel!
  
  @IBOutlet weak var pauseButton: UIButton!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var resetButton: UIButton!
  @IBOutlet weak var allocatedLabel: UILabel!
  
  var seconds = 60 * 15
  var timer = Timer()
  var isTimerRunning = false
  var resumeTapped = false
  
    override func viewDidLoad() {
      super.viewDidLoad()
      seconds = Int(timerStepper.value) * 60
      pauseButton.isEnabled = false
      pauseButton.alpha = 0.5
      allocatedLabel.text = SharedAssets.sharedInstance.teamsAllocated

    }

  func runTimer() {
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    isTimerRunning = true
    pauseButton.isEnabled = true
    pauseButton.alpha = 1.0
  }
  
  func updateTimer() {
    if seconds < 1 {
      timer.invalidate()
      let systemSoundID: SystemSoundID = 1304
      AudioServicesPlaySystemSound (systemSoundID)
      pauseButton.isEnabled = false
      pauseButton.alpha = 0.5
    } else {
      seconds -= 1
      timerLabel.text = timeString(time: TimeInterval(seconds))
    }
  }
  
  
  @IBAction func changeTime(_ sender: Any) {
    seconds = Int(timerStepper.value) * 60
    timerLabel.text = timeString(time: TimeInterval(seconds))
  }
  
  @IBAction func pressStart(_ sender: Any) {
    if isTimerRunning == false {
      runTimer()
      startButton.isEnabled = false
      startButton.alpha = 0.5
      timerStepper.isEnabled = false
      let systemSoundID: SystemSoundID = 1103
      AudioServicesPlaySystemSound (systemSoundID)
    }
    
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
  
  @IBAction func pressPause(_ sender: Any) {
    let systemSoundID: SystemSoundID = 1103
    AudioServicesPlaySystemSound (systemSoundID)
    if self.resumeTapped == false {
      timer.invalidate()
      self.resumeTapped = true
      self.pauseButton.setTitle("Resume",for: .normal)
    } else {
      runTimer()
      self.resumeTapped = false
      self.pauseButton.setTitle("Pause",for: .normal)
    }
  }
  @IBAction func pressReset(_ sender: Any) {
    let systemSoundID: SystemSoundID = 1103
    AudioServicesPlaySystemSound (systemSoundID)
    timer.invalidate()
    seconds = Int(timerStepper.value) * 60
    timerLabel.text = timeString(time: TimeInterval(seconds))
    isTimerRunning = false
    pauseButton.isEnabled = false
    pauseButton.alpha = 0.5
    startButton.isEnabled = true
    startButton.alpha = 1.0
    timerStepper.isEnabled = true
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
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
