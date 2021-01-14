//
//  WorkerSearchViewController.swift
//  Work It
//
//  Created by Jorge Acosta on 22-11-20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import Lottie
import Cosmos

protocol WorkerSearchDelegate {
    func selectWorker(worker: UserInfo)
}

class WorkerSearchViewController: UIViewController {

    
    @IBOutlet weak var searchBar : UISearchBar!
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var animation: AnimationView?
    @IBOutlet weak var emptyView : UIView!
    
    
    var delegate : WorkerSearchDelegate?
    var workers = [UserInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let starAnimation = Animation.named("search_worker")
        animation!.animation = starAnimation
        animation?.loopMode = .loop
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.searchBar.delegate = self
        
        setNavigationBar()
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animation?.play()
    }

    func search(query : String){
        
      
        let url = "\(U_BASE)\(U_SEARCH_WORKER)?query=\(query)"
        
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetWorkers.self, requestCode: U_POST_JOB) { (response) in
            
            self.workers = response!.data
            
            self.emptyView.isHidden = self.workers.count > 0
            self.tableView.reloadData()
            
           
        }
    }
    
}

extension WorkerSearchViewController : UISearchBarDelegate {
   
    
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        
        self.search(query: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
        {
           
            self.searchBar.endEditing(true)
        }

}

extension WorkerSearchViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkerCell") as! WorkerCell
        
        let worker = self.workers[indexPath.row]
        cell.selectionStyle = .none
     
        cell.userNameLabel.text = "\(worker.name!) \(worker.father_last_name!) \(worker.mother_last_name!)"
        
        cell.avatarImage.sd_setImage(with: URL(string: worker.profile_picture
                                                ?? ""), placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
      
        cell.occupationLabel.text = worker.occupation
        cell.rating.rating = Double(worker.average_rating ?? "0")!
        cell.descriptionLabel.text = worker.profile_description
        cell.cardView.defaultShadow()
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let workerSelected = self.workers[indexPath.row]
        
        if(self.delegate != nil){
            self.delegate?.selectWorker(worker: workerSelected)
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
}


class WorkerCell: UITableViewCell{
   
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var occupationLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    
}


