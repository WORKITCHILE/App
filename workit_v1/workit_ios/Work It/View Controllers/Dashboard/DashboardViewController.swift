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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataFound: DesignableUILabel!

    private var categoriesData = [GetCategoryResponse]()
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
//
     
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
     
        if(Singleton.shared.getCategories.count == 0){
            //ActivityIndicator.show(view: self.view)
            CallAPIViewController.shared.getCategory(completionHandler: { response in
                Singleton.shared.getCategories = response
                 self.categoriesData = Singleton.shared.getCategories
                
                if(self.categoriesData.count == 0){
                    self.noDataFound.isHidden = false
                }else {
                    self.noDataFound.isHidden = true
                }
                
                self.tableView.reloadData()
                //ActivityIndicator.hide()
            })
            
        } else {
            self.categoriesData = Singleton.shared.getCategories
            self.tableView.reloadData()
        }
       
     
        
    }
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let myVC = segue.destination as! SubCategoryViewController
        
        myVC.category = self.categoriesData[self.tableView.indexPathForSelectedRow!.row]
        myVC.titleHeading = self.categoriesData[self.tableView.indexPathForSelectedRow!.row].category_name ?? ""
    
    }
    
}




extension DashboardViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoriesData.count
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardCell") as! DashboardCell
        
        let val = self.categoriesData[indexPath.row]
        cell.selectionStyle = .none
        cell.jobName.text = val.category_name?.uppercased()
        cell.jobImage.sd_setImage(with: URL(string: val.category_image ?? ""), placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        
       
        return cell
    }

}



class DashboardCell: UITableViewCell{
    //MARK: IBOutlets
    @IBOutlet weak var jobImage: UIImageView!
    @IBOutlet weak var jobName: UILabel!
}

