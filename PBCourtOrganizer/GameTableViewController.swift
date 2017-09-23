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
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.reloadData()
    tableView.tableFooterView = UIView()
    
    
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
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 1 {
      return "Spares"
    }
    return ""
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if indexPath.section == 0 {
      let court = game.courts[indexPath.row]
      let cell = tableView.dequeueReusableCell(withIdentifier: "CourtCell", for: indexPath) as! CourtTableViewCell
      cell.courtLabel.text = "\(indexPath.row + 1)"
      
      cell.team1Label.text = getPlayerName(p: court.team1?.player1) + " / " + getPlayerName(p: court.team1?.player2)
      cell.team2Label.text = getPlayerName(p: court.team2?.player1) + " / " + getPlayerName(p: court.team2?.player2)
      
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath) as! PlayerTableViewCell
      cell.nameLabel.text = getPlayerName(p: game.spares[indexPath.row])
      return cell
    }
  }
  
  override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 130
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    return UITableViewAutomaticDimension
  }
  
}
