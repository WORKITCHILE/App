//
//  DashboardViewController.swift
//  Work It
//
//  Created by qw on 03/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import SDWebImage

class DashboardViewController: UIViewController {
    //MARK: IBOutlets
    @IBOutlet weak var dashboard: UICollectionView!
    @IBOutlet weak var noDataFound: DesignableUILabel!
    
    
    var categoriesData = [GetCategoryResponse]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(Singleton.shared.getCategories.count == 0){
            ActivityIndicator.show(view: self.view)
            CallAPIViewController.shared.getCategory(completionHandler: { (val) in
                Singleton.shared.getCategories = val
                 self.categoriesData = Singleton.shared.getCategories
                if(self.categoriesData.count == 0){
                    self.noDataFound.isHidden = false
                }else {
                    self.noDataFound.isHidden = true
                }
                self.dashboard.reloadData()
                ActivityIndicator.hide()
            })
        }else {
          self.categoriesData = Singleton.shared.getCategories
            dashboard.reloadData()
        }
    }
   
    
    //MARK: IBACtion
    @IBAction func sideMenuAction(_ sender: Any) {
        self.view.gestureRecognizers?.removeAll()
        self.menu()
    }
    
}

extension DashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.categoriesData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardCollection", for: indexPath) as! DashboardCollection
        let val = self.categoriesData[indexPath.row]
        cell.jobName.text = val.category_name
        cell.jobImage.sd_setImage(with: URL(string: val.category_image ?? ""), placeholderImage: #imageLiteral(resourceName: "appliances-white"))
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "SubCategoryViewController") as! SubCategoryViewController
        myVC.categoryId = self.categoriesData[indexPath.row].category_id ?? ""
        myVC.titleHeading = self.categoriesData[indexPath.row].category_name ?? ""
        self.navigationController?.pushViewController(myVC, animated: true)
    }
   
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width)/2
        return CGSize(width: width, height: 170)
    }
    
    
}

class DashboardCollection: UICollectionViewCell{
    //MARK: IBOutlets
    @IBOutlet weak var jobImage: UIImageView!
    @IBOutlet weak var jobName: DesignableUILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var deleteBtn: CustomButton!
    @IBOutlet weak var addBtn: CustomButton!
    
    var deleteButton: (()-> Void)? = nil
    var addButton: (()-> Void)? = nil
    
    @IBAction func deleteAction(_ sender: Any) {
        if let deleteButton = self.deleteButton {
            deleteButton()
        }
    }
    
    @IBAction func addBtnAction(_ sender: Any) {
        if let addButton = self.addButton {
            addButton()
        }
    }
    
}
