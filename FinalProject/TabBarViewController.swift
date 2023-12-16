//
//  TabBarViewController.swift
//  FinalProject
//
//  Created by Nikethana N N on 12/15/23.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
                self.delegate = self
        // Customize the tab bar appearance
        tabBar.tintColor = UIColor(hexString: "#7B81F7") // The color of the selected tab item
        tabBar.unselectedItemTintColor = UIColor(hexString: "#939393") // The color of unselected tab items
        tabBar.barTintColor = UIColor(hexString: "#FFFFFF") // white bg
        
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1) // Shadow position
                tabBar.layer.shadowRadius = 5 // Shadow blur radius
                tabBar.layer.shadowColor = UIColor.black.cgColor // Shadow color
                tabBar.layer.shadowOpacity = 0.3 // Shadow opacity
                tabBar.layer.masksToBounds = false
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // Handle tab selection if needed
    }
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            return TabBarTransitionAnimator()
    }

}
