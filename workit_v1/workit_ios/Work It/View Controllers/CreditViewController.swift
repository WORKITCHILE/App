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
        
        cell.userImage.sd_setImage(with: URL(string: val?.user_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        
        if(val?.payment_received ?? false){
            cell.status.text = "Pago recibido"
        } else {
            cell.status.text = "Pago realizado"
        }
        /*
        if( transaction.getPaymentReceived()){
              String creditStr = CurrencyFormat.Companion.format( String.valueOf(Double.valueOf(transaction.getAmount()) * 0.907F));
              holder.lStatus.setTitle("Pago recibido");
              holder.lStatus.setStatus(0);
              holder.creditValue.setText(context.getString(R.string.price_in_dollar, creditStr));
          } else {
              String creditStr = CurrencyFormat.Companion.format( transaction.getAmount());
              holder.lStatus.setTitle("Pago realizado");
              holder.lStatus.setStatus(1);
              holder.creditValue.setText(context.getString(R.string.price_in_dollar, creditStr));
          }
        */
      
        cell.jobAddress.text = val?.opposite_user ?? val?.user_name ?? ""
        cell.count.text = "$" + (val?.amount ?? "")
        
        cell.timeLabel.text = self.convertTimestampToDate(val?.created_at ?? 0, to: "dd/MM/YYYY")
        cell.card.defaultShadow()
        return cell
    }

    
}
