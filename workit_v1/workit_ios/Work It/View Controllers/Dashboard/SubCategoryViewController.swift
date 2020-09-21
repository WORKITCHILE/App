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
    @IBOutlet weak var selecteCategoryTable: UITableView!
    @IBOutlet weak var noDataLabel: DesignableUILabel!
   
    
    var subcategoryData = [GetSubcategoryResponse]()
    var categoryId = String()
    var selectedSubcategories = Set<String>()
    var titleHeading:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getSubCategoryData()
    
        setNavigationBar()
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
    }
    
    func getSubCategoryData(){
        ActivityIndicator.show(view: self.view)
        SessionManager.shared.methodForApiCalling(url: U_BASE + U_GET_SUBCATEGORIES + categoryId, method: .get, parameter: nil, objectClass: GetSubcategory.self, requestCode: U_GET_SUBCATEGORIES) { (response) in
            self.subcategoryData = response.data
            if(self.subcategoryData.count == 0){
                self.noDataLabel.isHidden = false
  
            }else {
                self.noDataLabel.isHidden = true
            }
            
            self.selecteCategoryTable.reloadData()
            ActivityIndicator.hide()
        }
    }
    
    @IBAction func nextAction(_ sender: Any) {
        /*
        if(self.selectedSubcategories.count == 0){
            Singleton.shared.showToast(text: "Select category")
        }else {
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryListViewController") as! CategoryListViewController
            myVC.subcategoryId = Array(self.selectedSubcategories)
            self.navigationController?.pushViewController(myVC, animated: true)
        }
        */
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let myVC = segue.destination as! CategoryListViewController
        myVC.subcategoryId = Array(self.selectedSubcategories)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.subcategoryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell") as! SideMenuTableViewCell
        let val = self.subcategoryData[indexPath.row]
        cell.menuImage?.image = #imageLiteral(resourceName: "ic_uncheck")
        cell.menuName.text = val.subcategory_name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SideMenuTableViewCell
        let val = self.subcategoryData[indexPath.row]
        if(cell.menuImage?.image == #imageLiteral(resourceName: "ic_check")){
            cell.menuImage?.image = #imageLiteral(resourceName: "ic_uncheck")
            self.selectedSubcategories.remove(val.subcategory_id ?? "")
        }else{
            cell.menuImage?.image = #imageLiteral(resourceName: "ic_check")
            self.selectedSubcategories.insert(val.subcategory_id ?? "")
        }
        print(self.selectedSubcategories)
    }

}
