//
//  ConfigureCourtsViewController.swift
//  PBCourtOrganizer
//
//  Created by Evelyn Eldridge on 2017-09-19.
//  Copyright © 2017 codeDependent Software. All rights reserved.
//

import UIKit
import GameKit

class ConfigureCourtsViewController: UIViewController {
  @IBOutlet weak var allPlayersTableVIew: UITableView!
  @IBOutlet weak var selectedPlayersTableView: UITableView!
  @IBOutlet weak var numberOfCourtsStepper: UIStepper!
  @IBOutlet weak var numberOfCourtsLabel: UILabel!
  @IBOutlet weak var selectedCountLabel: UILabel!
  
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  var totalCourts = 3
  var teams = [Team]()
  var sparesCount = 0
  var games = [Game]()
  var totalGames = 10
  var allocatedCount = 0
  var notAllocatedCount = 0
  var worstNotAllocatedCount = 0
  var bestAllocatedCount = 0
  var bestGames = [Game]()
  var allPlayers = [Player]()               // All players in db
  var allPlayersFiltered = [Player]()       // All players not yet selected
  var selectedPlayers = [Player]()          // Selected players
  var newPlayer = Player()
  
  // MARK: - ViewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
//    activityIndicator.startAnimating()
    activityIndicator.center = view.center
    view.addSubview(activityIndicator)
        
    self.navigationController?.styleForPB()
    selectedPlayersTableView.tableFooterView = UIView()
    allPlayersTableVIew.backgroundColor = UIColor.groupTableViewBackground
    allPlayersTableVIew.tableFooterView = UIView()
    allPlayersTableVIew.delegate = self
    allPlayersTableVIew.dataSource = self
    selectedPlayersTableView.delegate = self
    selectedPlayersTableView.dataSource = self
    numberOfCourtsStepper.value = Double(totalCourts)
    numberOfCourtsLabel.text = "\(Int(numberOfCourtsStepper.value))"
    
    SharedAssets.sharedInstance.createDatabase()
    allPlayersFiltered = SharedAssets.sharedInstance.loadPlayers()
    allPlayers = allPlayersFiltered
    allPlayersTableVIew.reloadData()
    updateCount()
  }
  
  
  // MARK: - Create the Schedule Methods
  func configureCourts () {
    activityIndicator.startAnimating()
    // The players are saved in the shared instance for use later.
    SharedAssets.sharedInstance.players = selectedPlayers
    
    let minCourtCount = Int(SharedAssets.sharedInstance.players.count / 4)
    if minCourtCount < Int(numberOfCourtsStepper.value) {
      totalCourts = minCourtCount
    } else {
      totalCourts = Int(numberOfCourtsStepper.value)
    }
    createTeams()
    worstNotAllocatedCount = teams.count
    totalGames = teams.count / (totalCourts * 2)
    
    for _ in 0...500 {

      createGames()
      assignSpares()
      assignCourts()
      if worstNotAllocatedCount > notAllocatedCount {
        worstNotAllocatedCount = notAllocatedCount
        bestGames = games
        bestAllocatedCount = allocatedCount
        if allocatedCount == teams.count {
          print ("Perfect")
          break
        }
      }
      games.removeAll()
    }
    for g in 0...bestGames.count - 1 {
      let game = bestGames [g]
      for c in 0...game.courts.count - 1 {
        let court = game.courts[c]
        if court.team1 == nil || court.team2 == nil {
          fixGame(g: g)
        }
      }
    }
    SharedAssets.sharedInstance.games = bestGames
    SharedAssets.sharedInstance.teamsAllocated = "\(totalGames * totalCourts * 2 - bestAllocatedCount) Duplicate Teams"
    
    print ("teams \(teams.count)")
    print ("allocated \(bestAllocatedCount)")
    // Reset the view
    games.removeAll()
    bestGames.removeAll()
    teams.removeAll()
    allocatedCount = 0
    bestAllocatedCount = 0
//    printSchedule()
    activityIndicator.stopAnimating()
  }

  // If there are any games without 4 players, fix them
  func fixGame (g:Int) {
    let game = bestGames[g]
    var needToAdd = [Int]()
    for p in 0...SharedAssets.sharedInstance.players.count - 1 {
      if !isInThisGame(game: game, player: p) {
        needToAdd.append(p)
      }
    }
    
    for c in 0...game.courts.count - 1 {
      let court = game.courts[c]
      if court.team1 == nil {
        if needToAdd.count > 1 {
          let team = Team(player1: needToAdd[0], player2: needToAdd[1], isDuplicate: true)
          bestGames[g].courts[c].team1 = team
          needToAdd.removeFirst(2)
        }
      }
      if court.team2 == nil {
        if needToAdd.count > 1 {
          let team = Team(player1: needToAdd[0], player2: needToAdd[1], isDuplicate: true)
          bestGames[g].courts[c].team2 = team
          needToAdd.removeFirst(2)
        }
      }
      if needToAdd.count < 2 {
        break
      }
    }
  }
  
  func printSchedule () {
    for i in 0...SharedAssets.sharedInstance.games.count - 1 {
      let game = SharedAssets.sharedInstance.games[i]
      print("GAME: \(i)")
      //      print("GAME: \(i) spares: \(bestGames[i].spares)")
      for j in 0...game.courts.count - 1 {
        let court = game.courts[j]
        
        let t1p1 = getPlayerName(p: court.team1?.player1)
        let t1p2 = getPlayerName(p: court.team1?.player2)
        let t2p1 = getPlayerName(p: court.team2?.player1)
        let t2p2 = getPlayerName(p: court.team2?.player2)
        print("court: \(j) team1: \(t1p1)     \(t1p2)")
        print("            team2: \(t2p1)     \(t2p2)")
      }
      print ("SPARES:")
      for spare in game.spares {
        print ("        \(getPlayerName(p: spare))")
      }
    }
  }
  
  // Create a unique list of ALL possible teams
  func createTeams () {
    var count = 0
    for i in 0...SharedAssets.sharedInstance.players.count - 1 {
      if i < SharedAssets.sharedInstance.players.count - 1 {
        for j in i + 1...SharedAssets.sharedInstance.players.count - 1 {
          let team = Team(player1: i, player2: j, isDuplicate: false)
          count = count + 1
          teams.append(team)
        }
      }
    }
    let shuffled = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: teams)
    teams = shuffled as! [Team]
  }
  
  // Create Games with the correct number of empty courts
  func createGames () {
    for _ in 0...totalGames - 1 {
      var game = Game()
      for _ in 0...totalCourts - 1 {
        game.courts.append(Court())
      }
      games.append(game)
    }
  }
  
  // Assign Spares Randomly to each game, Repeat as needed
  func assignSpares() {
    sparesCount = SharedAssets.sharedInstance.players.count - (totalCourts * 4)
    guard sparesCount > 0 else {
      return
    }
    
    var spares = [Int]()
    for i in 0...SharedAssets.sharedInstance.players.count - 1 {
      spares.append(i)
    }
    let shuffled = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: spares)
    spares = shuffled as! [Int]
    
    var currentSpare = 0
    
    for i in 0...games.count - 1 {
      for _ in 1...sparesCount {
        games[i].spares.append(spares[currentSpare])
        currentSpare = currentSpare + 1
        if currentSpare > SharedAssets.sharedInstance.players.count - 1 {
          currentSpare = 0
        }
      }
    }
  }

//  func assignCourts () {
//    allocatedCount = 0
//    var t = 0
//    var removedCount = 0
//    while t < teams.count  {
//      let team = teams[t]
////    }
////    for team in teams {
//      var isTeamAllocated = false
//      
//      // Check each Game
//      for i in 0...games.count - 1 {
//        var currentGame = games[i]
//        var inThisGame = false
//        
//        if isInThisGame(game: currentGame, player: team.player1) {
//          inThisGame = true
//        }
//        
//        if isInThisGame(game: currentGame, player: team.player2) {
//          inThisGame = true
//        }
//        
//        // IF not in this game, then add them.
//        if !inThisGame {
//          // Add to the first available court
//          
//          for j in 0...totalCourts - 1 {
//            let court = currentGame.courts[j]
//            if court.team1 == nil {
//              games[i].courts[j].team1 = team
//              isTeamAllocated = true
//              break
//            } else if court.team2 == nil {
//              games[i].courts[j].team2 = team
//              isTeamAllocated = true
//              break
//            }
//          }
//        }
//        
//        // If the team is allocated, then don't bother checking the rest of the games
//        if isTeamAllocated {
//          allocatedCount = allocatedCount + 1
//          t = t + 1
//          break
//        }
//      }  // END of checking each game
//      if isTeamAllocated == false {
//        // remove the last team
//        for (g, game) in games.enumerated() {
//          for (c, court) in game.courts.enumerated() {
//            if games[g].courts[c].team1?.player1 == teams[t-1].player1 &&
//              games[g].courts[c].team1?.player2 == teams[t-1].player2 {
//              games[g].courts[c].team1 = nil
//              print ("team removed")
//              removedCount = removedCount + 1
//              allocatedCount = allocatedCount - 1
//              break
//            }
//            if games[g].courts[c].team2?.player1 == teams[t-1].player1 &&
//              games[g].courts[c].team2?.player2 == teams[t-1].player2 {
//              games[g].courts[c].team2 = nil
//              print ("team removed")
//              removedCount = removedCount + 1
//              allocatedCount = allocatedCount - 1
//              break
//            }
//          }
//        }
//        
//        
//        let lastTeam = teams.remove(at: t - 1)
//        teams.insert(lastTeam, at: teams.count - 1)
//        t = t - 1
//        if removedCount > teams.count {
//          print ("no solution")
//          break
//        }
//      }
//    }
//  }

  
  
  // Put each team onto Courts, some teams won't fit
  func assignCourts () {
    allocatedCount = 0
    notAllocatedCount = 0
    for team in teams {
      var isTeamAllocated = false
      
      // Check each Game
      for i in 0...games.count - 1 {
        var currentGame = games[i]
        var inThisGame = false
        
        if isInThisGame(game: currentGame, player: team.player1) {
          inThisGame = true
        }
        
        if isInThisGame(game: currentGame, player: team.player2) {
          inThisGame = true
        }
        
        // IF not in this game, then add them.
        if !inThisGame {
          // Add to the first available court
          
          for j in 0...totalCourts - 1 {
            let court = currentGame.courts[j]
            if court.team1 == nil {
              games[i].courts[j].team1 = team
              isTeamAllocated = true
              
              break
            } else if court.team2 == nil {
              games[i].courts[j].team2 = team
              isTeamAllocated = true
              
              break
            }
          }
        }
        
        // If the team is allocated, then don't bother checking the rest of the games
        if isTeamAllocated {
          allocatedCount = allocatedCount + 1
          break
        }
      }  // END of checking each game
      if isTeamAllocated == false {
        notAllocatedCount = notAllocatedCount + 1
      }
      if notAllocatedCount >= worstNotAllocatedCount {
        break
      }
    } //END of allocating Teams
  }
  
  func isInThisGame(game:Game, player:Int) -> Bool {
    // Check the spares for this game
    for spare in game.spares {
      if player == spare {
        return true
      }
    }
    
    // Check each court for this Game
    for currentCourt in game.courts {
      if isPlayingOnCourt(player: player, court: currentCourt) {
        return true
      }
    }
    
    return false
  }
  
  func isPlayingOnCourt(player:Int, court:Court) -> Bool {
    var isAllocated = false
    if player == court.team1?.player1 ||
      player == court.team1?.player2 ||
      player == court.team2?.player1 ||
      player == court.team2?.player2 {
      isAllocated = true
    }
    return isAllocated
  }
  
  func updateCount () {
    selectedCountLabel.text = "\(selectedPlayers.count) players selected"
  }
  
  // MARK: - IB Actions  
  @IBAction func changeNumberOfCourts(_ sender: Any) {
    numberOfCourtsLabel.text = "\(Int(numberOfCourtsStepper.value))"
  }
  
  @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer) {
    let locationInView = sender.location(in: selectedPlayersTableView)
    if let indexPath = selectedPlayersTableView.indexPathForRow(at: locationInView) {
      if indexPath.row <= selectedPlayers.count - 1 {
        allPlayersFiltered.append(selectedPlayers[indexPath.row])
        selectedPlayers.remove(at: indexPath.row)
        selectedPlayersTableView.reloadData()
        allPlayersTableVIew.reloadData()
        updateCount()
      }
    }
  }
  
  @IBAction func pressSelectAll(_ sender: Any) {
    selectedPlayers = allPlayers
    allPlayersFiltered = [Player]()
    selectedPlayersTableView.reloadData()
    allPlayersTableVIew.reloadData()
    updateCount()
  }
  
  @IBAction func pressClearAll(_ sender: Any) {
    selectedPlayers = [Player]()
    allPlayersFiltered = allPlayers
    selectedPlayersTableView.reloadData()
    allPlayersTableVIew.reloadData()
    updateCount()
  }
  
  @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer) {
    let locationInView = sender.location(in: allPlayersTableVIew)
    if let indexPath = allPlayersTableVIew.indexPathForRow(at: locationInView) {
      if indexPath.row <= allPlayersFiltered.count - 1 {
        selectedPlayers.append(allPlayersFiltered[indexPath.row])
        allPlayersFiltered.remove(at: indexPath.row)
        selectedPlayersTableView.reloadData()
        allPlayersTableVIew.reloadData()
        updateCount()
      }
    }
  }
  
  @IBAction func doneAddPlayer(segue: UIStoryboardSegue) {
    allPlayers.append(newPlayer)
    allPlayersFiltered.append(newPlayer)
    allPlayersTableVIew.reloadData()
  }
  
  @IBAction func cancelAddPlayer(segue: UIStoryboardSegue) {
    
  }
  
  // MARK: - Navigation
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    if identifier == "createCourts" {
      if selectedPlayers.count < 4 {
        showErrorAlert(title: "Wait a Second!", message: "You need to select at least 4 players")
        return false
      } else {
        configureCourts()
      }
    }
    return true
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
  }
  
  
  // MARK: - Housekeeping
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
}

extension ConfigureCourtsViewController : UITableViewDataSource, UITableViewDelegate {
  
  // MARK: - Table view Methods
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == allPlayersTableVIew {
      return allPlayersFiltered.count
    } else {
      return selectedPlayers.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath) as! PlayerTableViewCell
    if tableView == allPlayersTableVIew {
      
      var name = ""
      name = "\(allPlayersFiltered[indexPath.row].firstName) \(allPlayersFiltered[indexPath.row].lastName)"
      cell.nameLabel.text = name
      cell.backgroundColor = UIColor.groupTableViewBackground
    } else {
      var name = ""
      name = "\(selectedPlayers[indexPath.row].firstName) \(selectedPlayers[indexPath.row].lastName)"
      cell.nameLabel.text = name
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    if tableView == allPlayersTableVIew {
      return .delete
    } else {
      return .none
    }
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    let player = allPlayersFiltered[indexPath.row]
    let success = SharedAssets.sharedInstance.deletePlayer(player: player)
    if success {
      allPlayers = SharedAssets.sharedInstance.loadPlayers()
      allPlayersFiltered.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
}
