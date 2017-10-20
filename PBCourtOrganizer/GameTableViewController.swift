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
  var gameNumber = 1
  
  
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
    return 3
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else if section == 1 {
      return game.courts.count
    } else {
      return game.spares.count
    }
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 1 {
      let headerView = UIView()
      let headerLabel = UILabel(frame: CGRect(x: 30, y: 0, width:
        tableView.bounds.size.width, height: tableView.bounds.size.height))
      headerLabel.font = UIFont.systemFont(ofSize: 24)
      headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
      headerLabel.sizeToFit()
      headerView.addSubview(headerLabel)
      
      return headerView
    } else {
      return tableView.headerView(forSection: 1)
    } 
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }
  
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return ""
    } else if section == 1 {
      return "Game \(gameNumber)"
    } else if section == 2 {
      return "Spares"
    }
    return ""
  }
  
  @IBAction func completedValueChanged(_ sender: Any) {
    let mySwitch = sender as! UISwitch
    if mySwitch.tag == 1000 {
      // It's the completedSwitch
      if mySwitch.isOn {
        SharedAssets.sharedInstance.games[gameNumber - 1].completed = true
      } else {
        SharedAssets.sharedInstance.games[gameNumber - 1].completed = false
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedCell", for: indexPath) as! CompletedTableViewCell
      if game.completed {
        cell.completedSwitch.isOn = true
      } else {
        cell.completedSwitch.isOn = false
      }
      return cell
    } else if indexPath.section == 1 {
      let court = game.courts[indexPath.row]
      let cell = tableView.dequeueReusableCell(withIdentifier: "CourtCell", for: indexPath) as! CourtTableViewCell
      cell.courtLabel.text = "\(indexPath.row + 1)"
      
      cell.team1Label.text = getPlayerName(p: court.team1?.player1) + " / " + getPlayerName(p: court.team1?.player2)
      cell.team2Label.text = getPlayerName(p: court.team2?.player1) + " / " + getPlayerName(p: court.team2?.player2)
      if (court.team1?.isDuplicate)! {
        cell.team1Label.textColor = UIColor.red
      } else {
        cell.team1Label.textColor = UIColor.black
      }
      if (court.team2?.isDuplicate)! {
        cell.team2Label.textColor = UIColor.red
      } else {
        cell.team2Label.textColor = UIColor.black
      }
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
