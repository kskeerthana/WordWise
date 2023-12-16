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
        tabBar.barTintColor = UIColor(hexString: "#D0D2F5") // light purple
        
        // Further customization
        // ...
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // Handle tab selection if needed
    }
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            return TabBarTransitionAnimator()
    }

}
