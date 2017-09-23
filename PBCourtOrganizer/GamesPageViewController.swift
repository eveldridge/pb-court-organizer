//
//  GamesPageViewController.swift
//  PBCourtOrganizer
//
//  Created by Evelyn Eldridge on 2017-09-21.
//  Copyright © 2017 codeDependent Software. All rights reserved.
//

import UIKit

class GamesPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource  {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dataSource = self
    delegate = self
    let startingViewController: GameViewController =
      viewControllerAtIndex(index: 0)!
      title = "Game 1"
    
    let viewControllers: NSArray = [startingViewController]
    setViewControllers(viewControllers
      as? [UIViewController],
                                       direction: .forward,
                                       animated: false,
                                       completion: nil)
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func viewControllerAtIndex(index: Int) -> GameViewController? {
    if (SharedAssets.sharedInstance.games.count == 0) ||
      (index >= SharedAssets.sharedInstance.games.count) {
      return nil
    }
    
    let storyBoard = UIStoryboard(name: "Main",bundle: Bundle.main)
    let dataViewController = storyBoard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
    
    dataViewController.game = SharedAssets.sharedInstance.games[index]
    dataViewController.index = index
    
    return dataViewController
  }
  
  func indexOfViewController(viewController: GameViewController) -> Int {
    let gameVC = viewController as GameViewController
    return gameVC.index
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    
    var index = indexOfViewController(viewController: viewController
      as! GameViewController)
    
    if (index == 0) || (index == NSNotFound) {
      return nil
    }
    
    index -= 1
    return viewControllerAtIndex(index: index)
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    
    var index = indexOfViewController(viewController: viewController
      as! GameViewController)
    
    if index == NSNotFound {
      return nil
    }
    
    index += 1
    if index == SharedAssets.sharedInstance.games.count {
      return nil
    }
    return viewControllerAtIndex(index: index)
  }
}
