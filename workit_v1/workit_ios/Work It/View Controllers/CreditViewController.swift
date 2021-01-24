//
//  CreditViewController.swift
//  Work It
//
//  Created by qw on 20/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import Lottie

class CreditViewController: UIViewController {
    
    
    //MARK: IBOutlets
    @IBOutlet weak var transactionTable: UITableView!
    @IBOutlet weak var emptyView : UIView!
    @IBOutlet weak var animation: AnimationView?
     
    var transactionData : GetTransactionResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getWalletInfo()
        
        let starAnimation = Animation.named("wallet")
        animation!.animation = starAnimation
        animation?.loopMode = .loop
        
        self.setNavigationBar()
        
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animation?.play()
    }
        
    
    func getWalletInfo(){
        ActivityIndicator.show(view: self.view)
        
        let url =  "\(U_BASE)\(U_GET_CREDIT)\(Singleton.shared.userInfo.user_id ?? "")"
        debugPrint("URL", url)
        SessionManager.shared.methodForApiCalling(url: url, method: .get, parameter: nil, objectClass: GetHistorialPaymentResponse.self, requestCode: url) {  response in
            
            
            ActivityIndicator.hide()
            
            if(response != nil){
                self.transactionData = response?.data
                self.emptyView.isHidden = (self.transactionData?.transactions!.count ?? 0) > 0
                self.transactionTable.reloadData()
          
            }
            
            
          
          
        }
    }
    
}

extension CreditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactionData?.transactions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EvaluationTableView") as! EvaluationTableView
        let val = self.transactionData?.transactions?[indexPath.row]

        if(val?.detail != nil) {
         
            cell.userName.text = val?.detail?.uppercased()
        } else {
            cell.userName.text = val?.transaction_for?.uppercased()
        
        }
        
        cell.userImage.sd_setImage(with: URL(string: val?.opposite_user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        
        let formater = NumberFormatter()
        formater.groupingSeparator = "."
        formater.numberStyle = .decimal
        
        var paymentAmount = 0
        
        if(val?.payment_received ?? false){
            cell.status.text = "Pago recibido"
            
            cell.statusContainer.backgroundColor = UIColor(named:"light_blue")
            cell.status.textColor = UIColor(named:"calendar_blue")
            let amount = Double(val?.amount ?? "0")
            paymentAmount = Int(floor(amount! * 0.907))
                 
        } else {
            cell.status.text = "Pago realizado"
            
            cell.statusContainer.backgroundColor = UIColor(named:"calendar_border_red")
            cell.status.textColor = UIColor(named:"calendar_red")
            
            paymentAmount = Int(val?.amount ?? "0")!
            
        }

        let formattedNumber = formater.string(from: NSNumber(value: paymentAmount) )
        cell.count.text = "$\(formattedNumber ?? "")"
        
       
        cell.jobAddress.text = val?.opposite_user ?? val?.user_name ?? ""
       
        
        cell.timeLabel.text = self.convertTimestampToDate(val?.created_at ?? 0, to: "dd/MM/YYYY")
        cell.card.defaultShadow()
        return cell
    }

    
}
