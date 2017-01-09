//
//  GamePageViewController.swift
//  cricket501keeper
//
//  Created by Matthew Mauro on 2016-12-23.
//  Copyright © 2016 Matthew Mauro. All rights reserved.
//

import UIKit
import Parse

class GamePageViewController: UIPageViewController, UIPageViewControllerDataSource {

    var rules:String?
    public var pageIndex:Int?
    public var gameQueryInfo:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.pageIndex = 0
        
        guard self.gameQueryInfo != nil else {
            // test has failed, we have no objectId for the current game
            print("segue from 'ViewController' failed, have to objectId to search (GamePageViewController - 26")
            return
        }
        let currentGameArray = gameQueryInfo?.components(separatedBy: ":")
        self.rules = (currentGameArray?[0])! as String
    }
    
    
    //MARK: - PageView DataSource
    func viewControllerAtIndex(index:Int) -> UIViewController? {
        switch index {
        case 0:
            let view = storyboard?.instantiateViewController(withIdentifier: "turn") as! TurnViewController
            view.gameQueryInfo = self.gameQueryInfo
            return view
        case 1:
            guard (self.rules?.isEqual("501"))! else {
                let summary = (storyboard?.instantiateViewController(withIdentifier: "cricketSummary") as! SummaryCricketViewController)
                summary.gameQueryInfo = self.gameQueryInfo
                return summary
            }
            let summary = (storyboard?.instantiateViewController(withIdentifier: "501Summary") as! Summary501ViewController)
            summary.gameQueryInfo = self.gameQueryInfo
            return summary
        default:
            return nil
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return self.viewControllerAtIndex(index: self.pageIndex!-1)
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return self.viewControllerAtIndex(index: self.pageIndex!+1)
    }
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 2
    }
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
