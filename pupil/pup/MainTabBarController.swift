//
//  ViewController.swift
//  pup
//
//  Created by Miguel Tamayo on 3/19/21.
//

import UIKit
import Gallery
import SwiftDataTables

class MainTabBarController: UITabBarController {
        
        lazy public var galleryController: ImageGalleryController = {
            let galleryController = ImageGalleryController()
            let title = "Image Selection"
            let defaultImage = UIImage(systemName: "photo")!.withTintColor(.black)
            let selectedImage = UIImage(systemName: "photo.fill")!.withTintColor(.black)
            let tabBarItems = (title: title, image: defaultImage, selectedImage: selectedImage)
            let tabBarItem = UITabBarItem(title: tabBarItems.title, image: tabBarItems.image, selectedImage: tabBarItems.selectedImage)
            galleryController.tabBarItem = tabBarItem
            return galleryController
        }()
    
        lazy public var tableController: MeasurementsSwiftDataTableController = {
            let tableController = MeasurementsSwiftDataTableController()
            let title = "Measurements"
            let defaultImage = UIImage(systemName: "tablecells")!.withTintColor(.black)
            let selectedImage = UIImage(systemName: "tablecells.fill")!.withTintColor(.black)
            let tabBarItems = (title: title, image: defaultImage, selectedImage: selectedImage)
            let tabBarItem = UITabBarItem(title: tabBarItems.title, image: tabBarItems.image, selectedImage: tabBarItems.selectedImage)
            tableController.tabBarItem = tabBarItem
            return tableController
        }()
    
        lazy public var aboutController: AboutViewController = {
            let tableController = AboutViewController()
            let title = "About"
            let defaultImage = UIImage(systemName: "info.circle")!.withTintColor(.black)
            let selectedImage = UIImage(systemName: "info.circle.fill")!.withTintColor(.black)
            let tabBarItems = (title: title, image: defaultImage, selectedImage: selectedImage)
            let tabBarItem = UITabBarItem(title: tabBarItems.title, image: tabBarItems.image, selectedImage: tabBarItems.selectedImage)
            tableController.tabBarItem = tabBarItem
            return tableController
        }()
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(true)
            tabBar.backgroundColor = .white
            tabBar.tintColor = .black
            self.viewControllers = [tableController, galleryController, aboutController]
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }

}
