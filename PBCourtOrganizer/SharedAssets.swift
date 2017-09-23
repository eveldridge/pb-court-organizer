//
//  SharedAssets.swift
//  PBCourtOrganizer
//
//  Created by Evelyn Eldridge on 2017-09-19
//  Copyright © 2017 codeDependentSoftware. All rights reserved.
//

import UIKit


class SharedAssets  {
  static let sharedInstance = SharedAssets()
  var players = [Player]()
  var games = [Game]()
  let totalCourts = 2
  var sparesCount = 0
  var totalGames = 10
  
  let databaseFileName = "PBCourtOrganizerDB.sqlite"
  var pathToDatabase: String!
  var database: FMDatabase!
  var databasePath = String()
  
  init () {
    let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
    pathToDatabase = documentsDirectory.appending("/\(databaseFileName)")
    
  }
  

  // MARK: Generic DB Functions
  
  func createDatabase() -> Bool {
    var created = false
    
    if !FileManager.default.fileExists(atPath: pathToDatabase) {
      database = FMDatabase(path: pathToDatabase!)
      
      if database != nil {
        // Open the database.
        if database.open() {
          let createPlayerTableQuery = "create table players (playerID integer primary key not null, firstName text, lastName text, photo blob)"
          
          do {
            try database.executeUpdate(createPlayerTableQuery, values: nil)
            created = true
          }
          catch {
            print("Could not create table.")
            print(error.localizedDescription)
          }
          
          // At the end close the database.
          database.close()
        }
        else {
          print("Could not open the database.")
        }
      }
    }
    
    return created
  }
  
  func openDatabase() -> Bool {
    if database == nil {
      if FileManager.default.fileExists(atPath: pathToDatabase) {
        database = FMDatabase(path: pathToDatabase)
      }
    }
    
    if database != nil {
      if database.open() {
        return true
      }
    }
    
    return false
  }
  
  func insertPlayerData(firstName:String, lastName:String)->Bool {
    if openDatabase() {
      do {
        
        let query = "insert into players (playerID, firstName, lastName) values (null, '\(firstName)', '\(lastName)');"
        
        if !database.executeStatements(query) {
          print("Failed to insert initial data into the database.")
          print(database.lastError(), database.lastErrorMessage())
          return false
        }
      }
//      catch {
//        print(error.localizedDescription)
//        return false
//      }
      database.close()
    }
    return true
  }
  
  func loadPlayers() -> [Player]! {
    var players = [Player]()
    
    if openDatabase() {
      let query = "select * from players order by lastName asc"
      
      do {
        print(database)
        let results = try database.executeQuery(query, values: nil)
        
        while results.next() {
          let player = Player(firstName: results.string(forColumn: "firstName")!,
                              lastName: results.string(forColumn: "lastName")!)
          
          players.append(player)
        }
      }
      catch {
        print(error.localizedDescription)
      }
      
      database.close()
    }
    
    return players
  }
  
  func deletePlayer(player:Player) -> Bool {
      var deleted = false
    
      
      if openDatabase() {
        let query = "delete from players where firstName=? AND lastName =?"
        
        do {
          try database.executeUpdate(query, values: [player.firstName, player.lastName])
          deleted = true
        }
        catch {
          print(error.localizedDescription)
        }
        
        database.close()
      }
      
      return deleted
    }
}
