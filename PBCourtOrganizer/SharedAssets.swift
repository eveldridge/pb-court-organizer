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
  
  var databasePath = String()

  
  
  init () {
//    connectDB()
    
  }
  

  // MARK: Generic DB Functions
//  func connectDB () {
//    let filemgr = FileManager.default
//    let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)
//    
//    databasePath = dirPaths[0].appendingPathComponent("pbCourtOrganizer.db").path
//    
//    if !filemgr.fileExists(atPath: databasePath as String) {
//      let pickleballDB = FMDatabase(path: databasePath as String)
//      if pickleballDB == nil {
//        print("Error: \(pickleballDB?.lastErrorMessage())")
//      }
//      
//        // Create Player Table
//        let sqlPlayerTable = "CREATE TABLE IF NOT EXISTS Player (Id Integer PRIMARY KEY, photo Blob, firstName Text, lastName Text, Sex Text, Age Text, Rating Double, DominantHand Text, Notes Text)"
//        if !(pickleballDB?.executeStatements(sqlPlayerTable))! {
//          print("Error: \(pickleballDB?.lastErrorMessage())")
//        }
//      
//        pickleballDB?.close()
//      } else {
//        print("Error: \(pickleballDB?.lastErrorMessage())")
//      }
//    }
//  }
  
  
//  func insertPlayer (player:Player!)-> Int? {
//    guard player != nil else {
//      return nil
//    }
//    
//    let pickleballDB = FMDatabase(path: databasePath as String)
//    guard (pickleballDB?.open())! else  {
//      print("Error: \(pickleballDB?.lastErrorMessage())")
//      return nil
//    }
//    
//    let insertSQL = "INSERT INTO Player (Id,firstName, lastName, Sex, Age, Rating, DominantHand, Notes) VALUES (null,'\(player.firstName!)', '\(player.lastName!)', '\(player.sex)', '\(player.age)', '\(player.rating)', '\(player.dominantHand)', '\(player.notes)')"
//    
//    let result = pickleballDB?.executeUpdate(insertSQL, withArgumentsIn: nil)
//    if !result! {
//      print("Error: \(pickleballDB?.lastErrorMessage())")
//      return nil
//    }
//    NotificationCenter.default.post(name: kplayersUpdatedNotification, object: nil, userInfo: nil)
//    let querySQL = "SELECT last_insert_rowid() as id FROM Player"
//    
//    let results:FMResultSet? = pickleballDB?.executeQuery(querySQL, withArgumentsIn: nil)
//    
//    while results?.next() == true {
//      if let idInt = results?.int(forColumn: "id") {
//        return Int(idInt)
//      }
//    }
//    
//    return nil
//  }
  

//  func deletePlayer(id:Int!)->Bool {
//    let pickleballDB = FMDatabase(path: databasePath as String)
//    guard (pickleballDB?.open())! else  {
//      print("Error: \(pickleballDB?.lastErrorMessage())")
//      return false
//    }
//    
//    let updateSQL = "DELETE FROM Player WHERE Id = ?"
//    
//    do {
//      try pickleballDB?.executeUpdate(updateSQL, values: [id])
//      
//    } catch let error as NSError {
//      print("Error: \(error.localizedDescription)")
//      return false
//    }
//    return true
//  }
}
