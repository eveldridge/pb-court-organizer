//
//  Common.swift
//  PBCourtOrganizer
//
//  Created by Evelyn Eldridge on 2017-09-19.
//  Copyright © 2017 codeDependent Software. All rights reserved.
//

import Foundation

struct Player {
  var firstName = "First Name"
  var lastName = "Last Name"
}

struct Team {
  var player1: Int!
  var player2: Int!
}

struct Court {
  var team1: Team?
  var team2: Team?
}

struct Game {
  var courts = [Court]()
  var spares = [Int]()
}
