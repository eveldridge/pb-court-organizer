//
//  AddPlayerViewController.swift
//  PBCourtOrganizer
//
//  Created by Evelyn Eldridge on 2017-09-22.
//  Copyright © 2017 codeDependent Software. All rights reserved.
//

import UIKit

class AddPlayerViewController: UIViewController, UITextFieldDelegate {
  @IBOutlet weak var firstNameTextField: UITextField!
  @IBOutlet weak var lastNameTextField: UITextField!
  
  var player = Player()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.styleForPB()
    firstNameTextField.becomeFirstResponder()
    firstNameTextField.delegate = self
    lastNameTextField.delegate = self
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == firstNameTextField {
      lastNameTextField.becomeFirstResponder()
    } else {
      firstNameTextField.becomeFirstResponder()
    }
    return true
  }
  
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    if identifier == "doneAddPlayer" {
      player.firstName = firstNameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
      player.lastName = lastNameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
      
      if !SharedAssets.sharedInstance.insertPlayerData(firstName: player.firstName, lastName: player.lastName) {
        showErrorAlert(title: "Sorry Player Not Added", message: "Player already exists")
        return false
      }
    }
    return true
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
  }
  

  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "doneAddPlayer" {
      if segue.destination.isKind(of: ConfigureCourtsViewController.self) {
        let detailVC = segue.destination as! ConfigureCourtsViewController
        detailVC.newPlayer = player
      }
    }
  }
}
