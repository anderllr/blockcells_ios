//
//  OnBoardingPage.swift
//  BlockCells
//
//  Created by Anderson Rocha on 30/11/2017.
//  Copyright © 2017 BlockCells. All rights reserved.
//

import UIKit

class OnBoardingPage: UIPageViewController {

    func getSlide1() -> Slide1 {
        return storyboard!.instantiateViewController(withIdentifier: "Slide1") as! Slide1
    }
    
    func getSlide2() -> Slide2 {
        return storyboard!.instantiateViewController(withIdentifier: "Slide2") as! Slide2
    }
    
    func getSlide3() -> Slide3 {
        return storyboard!.instantiateViewController(withIdentifier: "Slide3") as! Slide3
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .darkGray
        self.dataSource = self
        setViewControllers([getSlide1()], direction: .forward, animated: false, completion: nil)
    }
    
}

extension OnBoardingPage : UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if viewController.isKind(of: Slide3.self) {
            // 3 -> 2
            return getSlide2()
        } else if viewController.isKind(of: Slide2.self) {
            // 2 -> 1
            return getSlide1()
        } else {
            // 0 -> end of the road
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: Slide1.self) {
            // 0 -> 1
            return getSlide2()
        } else if viewController.isKind(of: Slide2.self) {
            // 1 -> 2
          //  Slide2.player.pause()
            return getSlide3()
        } else {
            // 3 -> end of the road
            return nil
        }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 3
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}

