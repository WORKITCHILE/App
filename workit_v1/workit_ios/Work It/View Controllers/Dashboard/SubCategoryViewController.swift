//
//  SubCategoryViewController.swift
//  Work It
//
//  Created by qw on 15/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class SubCategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    //MARKL: IBOutlets
    @IBOutlet private weak var selecteCategoryTable: UITableView!
    @IBOutlet private weak var buttonContinue: UIButton!
    
    private var subcategoryData = [GetSubcategoryResponse]()
    
    private var selectedSubcategories = Set<GetSubcategoryResponse>()
    var category: GetCategoryResponse?
    var titleHeading = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getSubCategoryData()
    
        setNavigationBar()
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
        
        buttonContinue.isEnabled = false
        buttonContinue.alpha = 0.5
    }
    
    func getSubCategoryData(){
        ActivityIndicator.show(view: self.view)
        let url = "\(U_BASE)\(U_GET_SUBCATEGORIES)\(category?.category_id ?? "")"
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetSubcategory.self, requestCode: U_GET_SUBCATEGORIES) { (response) in
            self.subcategoryData = response.data
            self.selecteCategoryTable.reloadData()
            ActivityIndicator.hide()
            
            if(self.subcategoryData.count == 0){
                let storyboard  = UIStoryboard(name: "HomeWorker", bundle: nil)
                let myVC = storyboard.instantiateViewController(withIdentifier: "CategoryListViewController") as! CategoryListViewController
                
                myVC.subcategories = [GetSubcategoryResponse(subcategory_image: self.category?.category_image, category_id: self.category?.category_id, subcategory_name: self.category?.category_name, subcategory_id: self.category?.category_id, types: self.category?.types)]
               
              
               
                
                var navigationArray = self.navigationController?.viewControllers
                navigationArray!.remove(at: 1)
                
                
                self.navigationController?.viewControllers = navigationArray!
                
                self.navigationController?.pushViewController(myVC, animated: true)
                
            }
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let myVC = segue.destination as! CategoryListViewController
        myVC.subcategories = Array(self.selectedSubcategories)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.subcategoryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell") as! SideMenuTableViewCell
        let val = self.subcategoryData[indexPath.row]
        cell.menuImage?.image = (selectedSubcategories.contains(val)) ? UIImage(named: "ic_check"): UIImage(named: "ic_uncheck")
        cell.menuName.text = val.subcategory_name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let val = self.subcategoryData[indexPath.row]
        
        if(selectedSubcategories.contains(val)){
            selectedSubcategories.remove(val)
        } else {
            selectedSubcategories.insert(val)
        }
        
        buttonContinue.isEnabled = self.selectedSubcategories.count != 0
        buttonContinue.alpha = self.selectedSubcategories.count == 0 ? 0.5 : 1.0
        
        self.selecteCategoryTable.reloadData()
    
    }

}
