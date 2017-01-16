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
    public var gm501:GameManager501?
    public var gmCricket:CricketGameManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.pageIndex = 0
        
        self.setViewControllers([self.viewControllerAtIndex(index: 0)!],
                                direction: UIPageViewControllerNavigationDirection.forward,
                                animated: true,
                                completion: nil)
    }
    
    //MARK: - PageView DataSource
    func viewControllerAtIndex(index:Int) -> UIViewController? {
        switch index {
        case 0:
            let view = storyboard?.instantiateViewController(withIdentifier: "turn") as! TurnViewController
            if self.gm501 == nil {
                view.cricketGM = self.gmCricket
            }
            return view
        case 1:
            guard (self.gm501 != nil) else {
                let summary = (storyboard?.instantiateViewController(withIdentifier: "cricketSummary") as! SummaryCricketViewController)
                summary.gameManager = self.gmCricket
                return summary
            }
            let summary = (storyboard?.instantiateViewController(withIdentifier: "501Summary") as! Summary501ViewController)
            summary.gm = self.gm501
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
