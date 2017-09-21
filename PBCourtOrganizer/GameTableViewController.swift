//
//  GameTableViewController.swift
//  PBCourtOrganizer
//
//  Created by Evelyn Eldridge on 2017-09-20.
//  Copyright © 2017 codeDependent Software. All rights reserved.
//

import UIKit

class GameTableViewController: UITableViewController {
  
  var game = Game()
  var players = [Player]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.reloadData()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return game.courts.count
    } else {
      return game.spares.count
    }
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if indexPath.section == 0 {
      let court = game.courts[indexPath.row]
      let cell = tableView.dequeueReusableCell(withIdentifier: "CourtCell", for: indexPath) as! CourtTableViewCell
      cell.courtLabel.text = "Court \(indexPath.row)"
      
      var t1p1 = ""
      if let p = court.team1?.player1 {
        if p < players.count {
          let player = players[p]
          t1p1 = "\(player.firstName) \(player.lastName)"
        }
      }
      var t1p2 = ""
      if let p = court.team1?.player2 {
        if p < players.count {
          let player = players[p]
          t1p2 = "\(player.firstName) \(player.lastName)"
        }
      }
      cell.team1Label.text = "\(t1p1, t1p2)"
      
      var t2p1 = ""
      if let p = court.team2?.player1 {
        if p < players.count {
          let player = players[p]
          t2p1 = "\(player.firstName) \(player.lastName)"
        }
      }
      var t2p2 = ""
      if let p = court.team2?.player2 {
        if p < players.count {
          let player = players[p]
          t2p2 = "\(player.firstName) \(player.lastName)"
        }
      }
      cell.team2Label.text = "\(t2p1, t2p2)"


      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "CourtCell", for: indexPath) as! SpareTableViewCell
      return cell
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
