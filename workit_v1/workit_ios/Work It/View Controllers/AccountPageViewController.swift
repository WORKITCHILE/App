//
//  AccountPageViewController.swift
//  Work It
//
//  Created by qw on 01/06/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

protocol ScrollAccount {
    func scrollAccountView(index: Int)
}

class AccountPageViewController: UIPageViewController {
    static var dataSource: UIPageViewControllerDataSource?
    
    static var indexDelegate:ScrollAccount? = nil
    
    var historyViewControllers: [UIViewController] = []
    var pageControl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        handleView()
        setControllers()
        AccountPageViewController.dataSource = self
        for view in self.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = false
            }
        }
    }
    
    func setControllers() {
        if let firstViewController = historyViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        HistoryPageViewController.dataSource = self
    }
    
    func handleView() {
        historyViewControllers = [ self.newColoredViewController(controller:"AccountSettingViewController"),
                                   self.newColoredViewController(controller: "CreditViewController"),]
        
    }
    
    
    func setControllerFirst() {
        if let firstViewController = historyViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .reverse,
                               animated: false,
                               completion: nil)
        }
    }
    
    func setControllerSecond() {
        setViewControllers([historyViewControllers[1]], direction: .forward, animated: false, completion: nil)
    }
    
    func setControllerLast() {
        if let lastViewController = historyViewControllers.last {
            setViewControllers([lastViewController],
                               direction: .forward,
                               animated: false,
                               completion: nil)
        }
    }
    
    
    private func newColoredViewController(controller: String)->UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: controller)
    }
}

extension AccountPageViewController: UIPageViewControllerDataSource
{
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = historyViewControllers.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard historyViewControllers.count > previousIndex else {
            return nil
        }
        return historyViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = historyViewControllers.index(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard historyViewControllers.count != nextIndex else {
            return nil
        }
        guard historyViewControllers.count > nextIndex else {
            return nil
        }
        return historyViewControllers[nextIndex]
    }
}

extension AccountPageViewController : UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = historyViewControllers.index(of: pageContentViewController)!
        //AccountPageViewController.self.indexDelegate!.scrollAccountView(index:self.pageControl.currentPage)
    }
}


