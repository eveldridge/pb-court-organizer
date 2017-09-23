//
//  GameViewController.swift
//  PBCourtOrganizer
//
//  Created by Evelyn Eldridge on 2017-09-21.
//  Copyright © 2017 codeDependent Software. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

  var game:Game?
  var index:Int!
  
    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowGame" {
      let detailVC = segue.destination as! GameTableViewController
      detailVC.game = game!
      detailVC.gameNumber = index + 1
    }
  }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
