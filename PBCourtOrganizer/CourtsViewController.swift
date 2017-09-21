//
//  CourtsViewController.swift
//  PBCourtOrganizer
//
//  Created by Evelyn Eldridge on 2017-09-19.
//  Copyright © 2017 codeDependent Software. All rights reserved.
//

import UIKit
import GameKit



class CourtsViewController: UIViewController {
  
  let totalCourts = 2
  var players = [Player]()
  var teams = [Team]()
  var sparesCount = 0
  var games = [Game]()
  var totalGames = 10
  var allocatedCount = 0
  var bestAllocatedCount = 0
  var bestGames = [Game]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addPlayers()
    createTeams()
    
    for _ in 0...100 {
      createGames()
      assignSpares()
      assignCourts()
      if allocatedCount > bestAllocatedCount {
        bestGames = games
        bestAllocatedCount = allocatedCount
        if allocatedCount == teams.count {
          print("PERFECT")
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
    
    printSchedule()
    
    // Do any additional setup after loading the view.
  }
  func fixGame (g:Int) {
    let game = bestGames[g]
    var needToAdd = [Int]()
    for p in 0...players.count - 1 {
      if !isInThisGame(game: game, player: p) {
        needToAdd.append(p)
      }
    }
    
    for c in 0...game.courts.count - 1 {
      let court = game.courts[c]
      if court.team1 == nil {
        if needToAdd.count > 1 {
          let team = Team(player1: needToAdd[0], player2: needToAdd[1])
          bestGames[g].courts[c].team1 = team
          needToAdd.removeFirst(2)
        }
      }
      if court.team2 == nil {
        if needToAdd.count > 1 {
          let team = Team(player1: needToAdd[0], player2: needToAdd[1])
          bestGames[g].courts[c].team2 = team
          needToAdd.removeFirst(2)
        }
      }
      if needToAdd.count < 2 {
        break
      }
    }
    
    
    
    
  }
  func addPlayers () {
    let player = Player(firstName: "Evelyn", lastName: "ELdridge")
    players.append(player)
    
    let player1 = Player(firstName: "Pat", lastName: "Bertrand")
    players.append(player1)
    
    //    let player2 = Player(firstName: "Keith", lastName: "Davidson")
    //    players.append(player2)
    
    let player3 = Player(firstName: "Adnan", lastName: "Farhad")
    players.append(player3)
    
    let player4 = Player(firstName: "Mike", lastName: "D")
    players.append(player4)
    
    let player5 = Player(firstName: "Mike", lastName: "G")
    players.append(player5)
    
    let player6 = Player(firstName: "Mark", lastName: "De Abreau")
    players.append(player6)
    
    let player7 = Player(firstName: "Don", lastName: "Thompson")
    players.append(player7)
    
    let player8 = Player(firstName: "Luc", lastName: "Milmot")
    players.append(player8)
    
    let player9 = Player(firstName: "Rob", lastName: "Lutz")
    players.append(player9)
    //
    let player10 = Player(firstName: "Jim", lastName: "MacLaughlin")
    players.append(player10)
    
    //      let player11 = Player(firstName: "Trudy", lastName: "Donnely")
    //      players.append(player11)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func printSchedule () {
    for i in 0...bestGames.count - 1 {
      let game = bestGames[i]
      print("GAME: \(i)")
      //      print("GAME: \(i) spares: \(bestGames[i].spares)")
      for j in 0...game.courts.count - 1 {
        let court = game.courts[j]
        
        var t1p1 = ""
        var t1p2 = ""
        if let t1 = court.team1 {
          if let p1 = t1.player1 {
            t1p1 = "\(players[p1].firstName) \(players[p1].lastName)"
          }
          if let p2 = t1.player2 {
            t1p2 = "\(players[p2].firstName) \(players[p2].lastName)"
          }
        }
        
        var t2p1 = ""
        var t2p2 = ""
        if let t2 = court.team2 {
          if let p1 = t2.player1 {
            t2p1 = "\(players[p1].firstName) \(players[p1].lastName)"
          }
          if let p2 = t2.player2 {
            t2p2 = "\(players[p2].firstName) \(players[p2].lastName)"
          }
        }
        print("court: \(j) team1: \(t1p1)     \(t1p2)")
        print("            team2: \(t2p1)     \(t2p2)")
      }
      print ("SPARES:")
      for spare in game.spares {
        print ("        \(players[spare].firstName) \(players[spare].lastName)")
      }
    }
  }
  
  // Create a unique list of ALL possible teams
  func createTeams () {
    var count = 0
    for i in 0...players.count - 1 {
      if i < players.count - 1 {
        for j in i + 1...players.count - 1 {
          let team = Team(player1: i, player2: j)
          count = count + 1
          //          print ("\(count) \(team)")
          teams.append(team)
        }
      }
    }
    let shuffled = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: teams)
    teams = shuffled as! [Team]
    //    print ("total teams = \(teams.count)")
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
    sparesCount = players.count - (totalCourts * 4)
    guard sparesCount > 0 else {
      return
    }
    
    var spares = [Int]()
    for i in 0...players.count - 1 {
      spares.append(i)
    }
    let shuffled = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: spares)
    spares = shuffled as! [Int]
    
    var currentSpare = 0
    
    for i in 0...games.count - 1{
      //      print ("GAME: \(i)")
      for j in 1...sparesCount {
        games[i].spares.append(spares[currentSpare])
        //        print("Spare \(j) \(spares[currentSpare])")
        currentSpare = currentSpare + 1
        if currentSpare > players.count - 1 {
          currentSpare = 0
        }
      }
      
    }
  }
  
  // Put each team onto Courts, some teams won't fit
  func assignCourts () {
    allocatedCount = 0
    for team in teams {
      //      print("Team \(team.player1!) \(team.player2!)")
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
    }
  }
  
  func isInThisGame(game:Game, player:Int) -> Bool {
    var inThisGame = false
    
    // Check each court for this Game
    for currentCourt in game.courts {
      if isPlayingOnCourt(player: player, court: currentCourt) {
        inThisGame = true
      }
    }  // END of checking Courts
    
    // Check the spares for this game
    for spare in game.spares {
      if player == spare {
        inThisGame = true
      }
    }
    return inThisGame
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
  
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowGame" {
      let detailVC = segue.destination as! GameTableViewController
      detailVC.game = bestGames[0]
      detailVC.players = players
    }
  }

}
