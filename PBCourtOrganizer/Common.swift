//
//  Common.swift
//  PBCourtOrganizer
//
//  Created by Evelyn Eldridge on 2017-09-19.
//  Copyright © 2017 codeDependent Software. All rights reserved.
//

import Foundation
import UIKit

struct kcolour {
  static let navBar = UIColor(red: 69/255, green: 176/255, blue: 70/255, alpha: 1.0)
  static let fadedGreen = UIColor(red: 69/255, green: 176/255, blue: 70/255, alpha: 0.5)
  static let fadedOrange = UIColor(red: 255/255, green: 128/255, blue: 0/255, alpha: 0.5)
  static let orange = UIColor(red: 255/255, green: 128/255, blue: 0/255, alpha: 1.0)
}

struct Player {
  var firstName = "First Name"
  var lastName = "Last Name"
}

struct Team {
  var player1: Int!
  var player2: Int!
  var isDuplicate = false
}

struct Court {
  var team1: Team?
  var team2: Team?
}

struct Game {
  var courts = [Court]()
  var spares = [Int]()
}


func getPlayerName (p:Int?) -> String {
  guard let playerIndex = p else {
    return ""
  }
  
  guard playerIndex <= SharedAssets.sharedInstance.players.count - 1 else {
    return ""
  }
  
  var name = ""
  name = "\(SharedAssets.sharedInstance.players[playerIndex].firstName) \(SharedAssets.sharedInstance.players[playerIndex].lastName)"
  
  return name
}
