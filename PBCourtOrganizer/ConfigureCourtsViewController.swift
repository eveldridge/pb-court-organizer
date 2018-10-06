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
  var notAllocatedCount = 0
  var worstNotAllocatedCount = 0
  var bestAllocatedCount = 0
  var bestGames = [Game]()
  var allPlayers = [Player]()               // All players in db
  var allPlayersFiltered = [Player]()       // All players not yet selected
  var selectedPlayers = [Player]()          // Selected players
  var latePlayers = [Player]()          // Late players
  var newPlayer = Player()
  var duplicateCount = 0
  var bestFirstDuplicateGame = 0
  
  // MARK: - ViewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Add the Activity Indicator
    //    activityIndicator.startAnimating()
    activityIndicator.center = view.center
    view.addSubview(activityIndicator)
    
    // Initialize the view
    self.navigationController?.styleForPB()
    selectedPlayersTableView.tableFooterView = UIView()
    allPlayersTableVIew.backgroundColor = UIColor.groupTableViewBackground
    allPlayersTableVIew.tableFooterView = UIView()
    numberOfCourtsStepper.value = Double(totalCourts)
    numberOfCourtsLabel.text = "\(Int(numberOfCourtsStepper.value))"
    
    // Set the delegates
    allPlayersTableVIew.delegate = self
    allPlayersTableVIew.dataSource = self
    selectedPlayersTableView.delegate = self
    selectedPlayersTableView.dataSource = self
    
    // Create the database and load the players
    SharedAssets.sharedInstance.createDatabase()
    allPlayersFiltered = SharedAssets.sharedInstance.loadPlayers()
    allPlayers = allPlayersFiltered
    allPlayersTableVIew.reloadData()
    updateCountLabel()
  }

  // MARK: - This is called when the user taps the Generage Games Button
  func configureCourts () {
    activityIndicator.startAnimating()

    // The players are saved in the shared instance for use later.
    SharedAssets.sharedInstance.players = selectedPlayers
    
    
    // Determine the miniumum number of courts we can use (it may be less than what the user specified)
    let minCourtCount = Int(SharedAssets.sharedInstance.players.count / 4)
    if minCourtCount < Int(numberOfCourtsStepper.value) {
      totalCourts = minCourtCount
    } else {
      totalCourts = Int(numberOfCourtsStepper.value)
    }
    
    // Create the list of unique teams based on the Selected List
    createTeams()
    
    // Determine the number of games to create
    totalGames = teams.count / (totalCourts * 2)

    
    // This tracks the worst number of teams NOT allocated
    worstNotAllocatedCount = teams.count
    
    // Repeat the algoritm x times and save the best result
    // Results of each iteration are saved in games.
    // If a better result is generated, save it in bestGames
    for _ in 0...500 {

      // Creates the correct number of games and courts
      createGames()
      
      // Randomly assign spares to each game (it's shuffled each time)
      assignSpares()
      
      // Put each team onto courts, not allowing any player to be on court twice.
      assignCourts()
      
      if notAllocatedCount == 0 {
        // If all teams are allocated then we have a perfect scenario
        bestAllocatedCount = 0
        bestGames = games
        break
      } else if worstNotAllocatedCount == notAllocatedCount {
        // Keep the result where any duplicate teams are later in the set
        let firstDuplicate = firstDuplicateGame(games: games)
        if firstDuplicate > bestFirstDuplicateGame {
          bestFirstDuplicateGame = firstDuplicate
          bestGames = games
        }
      } else if worstNotAllocatedCount > notAllocatedCount {
        // Keep the result where we have the fewest number of teams that didn't get allocated
        worstNotAllocatedCount = notAllocatedCount
        bestFirstDuplicateGame = firstDuplicateGame(games: games)
        bestGames = games
      }
      games.removeAll()
    }
    
    // Fix any games with missing teams
    for (g, game) in bestGames.enumerated() {
      for court in game.courts {
        if court.team1 == nil || court.team2 == nil {
          fixGame(g: g)
        }
      }
    }
    
    // Save the best result in bestGames to be used in the next view.
    SharedAssets.sharedInstance.games = bestGames
    
    // Update the view with the number of duplicates and where the duplicates begin
    if duplicateCount == 0 {
      SharedAssets.sharedInstance.teamsAllocated = "No duplicate teams"
    } else {
      SharedAssets.sharedInstance.teamsAllocated = "\(duplicateCount) Duplicate Teams, starting in Game \(bestFirstDuplicateGame + 1) of \(totalGames)"
    }
    
    // Reset all the counters in the view in case the user wants to try it again
    games.removeAll()
    bestGames.removeAll()
    teams.removeAll()
    bestFirstDuplicateGame = 0
    duplicateCount = 0
    bestAllocatedCount = 0
    //    printSchedule()
    activityIndicator.stopAnimating()
  }
  
  // MARK: Put each team onto Courts.  This is the main function
  func assignCourts () {
    notAllocatedCount = 0
    processTeams: for team in teams {
      var isTeamAllocated = false
      
      // Check each Game
      checkGames: for i in 0...games.count - 1 {
        var currentGame = games[i]
        var inThisGame = false
        
        if isInThisGame(game: currentGame, player: team.player1) {
          inThisGame = true
        } else if isInThisGame(game: currentGame, player: team.player2) {
          inThisGame = true
        }
        
        // IF not in this game, then add them.
        if !inThisGame {
          // Add to the first available court
          
          checkCourts: for j in 0...totalCourts - 1 {
            let court = currentGame.courts[j]
            if court.team1 == nil {
              games[i].courts[j].team1 = team
              isTeamAllocated = true
              break checkGames
            } else if court.team2 == nil {
              games[i].courts[j].team2 = team
              isTeamAllocated = true
              break checkGames
            }
          }
        }
      }  // END of checking each game
      
      if isTeamAllocated == false {
        notAllocatedCount = notAllocatedCount + 1
      }
      if notAllocatedCount > worstNotAllocatedCount {
        break processTeams
      }
    } //END of allocating Teams
  }

  
  // This function tells us where the first duplicate game will occur.
  func firstDuplicateGame (games:[Game]) -> Int {
    for (g, game) in games.enumerated() {
      for (_, court) in game.courts.enumerated() {
        if court.team1 == nil || court.team2 == nil {
          return g
        }
      }
    }
    
    // If no null team exists, return the last game
    return totalGames
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
          duplicateCount = duplicateCount + 1
          bestGames[g].courts[c].team1 = team
          needToAdd.removeFirst(2)
        }
      }
      if court.team2 == nil {
        if needToAdd.count > 1 {
          let team = Team(player1: needToAdd[0], player2: needToAdd[1], isDuplicate: true)
          duplicateCount = duplicateCount + 1
          bestGames[g].courts[c].team2 = team
          needToAdd.removeFirst(2)
        }
      }
      if needToAdd.count < 2 {
        break
      }
    }
  }
  
  // Print the schedule
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
  
  func updateCountLabel () {
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
        selectedPlayers = selectedPlayers.sorted(by: { $0.lastName < $1.lastName })
        selectedPlayersTableView.reloadData()
        allPlayersFiltered = allPlayersFiltered.sorted(by: { $0.lastName < $1.lastName })
        allPlayersTableVIew.reloadData()
        updateCountLabel()
      }
    }
  }
  
  @IBAction func pressSelectAll(_ sender: Any) {
    selectedPlayers = allPlayers.sorted(by: { $0.lastName < $1.lastName })
    allPlayersFiltered = [Player]().sorted(by: { $0.lastName < $1.lastName })
    selectedPlayersTableView.reloadData()
    allPlayersTableVIew.reloadData()
    updateCountLabel()
  }
  
  @IBAction func pressClearAll(_ sender: Any) {
    selectedPlayers = [Player]().sorted(by: { $0.lastName < $1.lastName })
    allPlayersFiltered = allPlayers.sorted(by: { $0.lastName < $1.lastName })
    selectedPlayersTableView.reloadData()
    allPlayersTableVIew.reloadData()
    updateCountLabel()
    latePlayers.removeAll()
  }
  
  @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer) {
    let locationInView = sender.location(in: allPlayersTableVIew)
    if let indexPath = allPlayersTableVIew.indexPathForRow(at: locationInView) {
      if indexPath.row <= allPlayersFiltered.count - 1 {
        selectedPlayers.append(allPlayersFiltered[indexPath.row])
        allPlayersFiltered.remove(at: indexPath.row)
        selectedPlayers = selectedPlayers.sorted(by: { $0.lastName < $1.lastName })
        selectedPlayersTableView.reloadData()
        allPlayers = allPlayers.sorted(by: { $0.lastName < $1.lastName })
        allPlayersTableVIew.reloadData()
        updateCountLabel()
      }
    }
  }
  
  @IBAction func doneAddPlayer(segue: UIStoryboardSegue) {
    allPlayers.append(newPlayer)
    allPlayersFiltered.append(newPlayer)
    allPlayersFiltered = allPlayersFiltered.sorted(by: { $0.lastName < $1.lastName })
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
  
//  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//    let cell = tableView.cellForRowAtIndexPath(indexPath)
    
//    if cell != nil {
//      let player = allPlayersFiltered [indexPath.row]
//      latePlayers.append(player)
//    }
//  }
  
//  override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//    let cell = tableView.cellForRowAtIndexPath(indexPath)
    
//    if cell != nil {
//      let player = allPlayersFiltered [indexPath.row]
//      latePlayers.remove(player)
//    }
//  }
  
  
}
