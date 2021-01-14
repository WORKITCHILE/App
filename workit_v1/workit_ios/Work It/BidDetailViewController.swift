//
//  BidDetailViewController.swift
//  Work It
//
//  Created by Jorge Acosta on 03-01-21.
//  Copyright © 2021 qw. All rights reserved.
//

import UIKit
import Cosmos
import Lottie

class BidDetailViewController: UIViewController {

    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var userImage : ImageView!
    @IBOutlet weak var userName : UILabel!
    @IBOutlet weak var userImageView : UIView!
    @IBOutlet weak var categoryLabel : UILabel!
    @IBOutlet weak var cosmoRating : CosmosView!
    @IBOutlet weak var animation: AnimationView?
    @IBOutlet weak var statusCard: View!
    @IBOutlet weak var statusLabel : UILabel!
    
    var data: [[String:String]] = []
    var jobData: GetJobResponse?
    var bidData : BidResponse?
    
    var mode = "HIRE"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let starAnimation = Animation.named("search_worker")
        animation!.animation = starAnimation
        animation?.loopMode = .loop
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        if(jobData?.vendor_image != nil){
            userImage.sd_setImage(with: URL(string: jobData?.vendor_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            userName.text = jobData?.vendor_name
            categoryLabel.text = jobData?.vendor_occupation
        } else {
            userImage.sd_setImage(with: URL(string: bidData?.vendor_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            userName.text = bidData?.vendor_name
            categoryLabel.text = bidData?.vendor_occupation
            cosmoRating.rating =  Double(bidData?.average_rating ?? "0")!
        }
        
       
    
        self.statusCard.defaultShadow()
        self.setNavigationBar()
        
        self.userImageView.defaultShadow()
        
    }
    
    func renderJobData(){
        data = []
        
        data.append([
            "type": "oneLabel",
            "title": "Trabajo",
            "label1": "TITULO",
            "detail1": jobData?.job_name ?? ""
        ])
        
        data.append([
            "type":"fiveLabel",
            "title":"Detal del trabajo",
            "label1":"PUBLICADO POR",
            "detail1": jobData?.user_name ?? "",
            "label2":"MONTO OFERTADO",
            "detail2": "$\(jobData?.initial_amount?.formattedWithSeparator ?? "0")" ,
            "label3":"CATEGORIA",
            "detail3": jobData?.category_name ?? "",
            "label4":"SUBCATEGORIA",
            "detail4": jobData?.subcategory_name ?? "",
            "label5":"TIPO DE TRABAJO",
            "detail5": jobData?.job_approach ?? "",
        ])
        
        data.append([
            "type": "threeLabel",
            "title": "Trabajo",
            "label1": "DIRECCIÓN",
            "detail1": jobData?.job_address ?? "",
            "label2": "CASA / DEPARTAMENTO",
            "detail2": jobData?.job_address_number! ?? "",
            "label3": "REFERENCIA",
            "detail3": jobData?.job_address_reference! ?? ""
        ])
        
        
        data.append([
            "type": "threeLabel",
            "title": "Caledario",
            "label1": "PUBLICADO",
            "detail1": jobData?.job_date ?? "",
            "label2": "FECHA DE INICIO",
            "detail2": jobData?.job_date! ?? "",
            "label3": "HORARIO",
            "detail3": jobData?.job_date! ?? ""
        ])
        
        if(mode == "HIRE"){
            renderStatusFromJob()
        } else {
            renderStatusFromJobWorker()
        }
    }
    

    
    func renderStatusFromJobWorker(){
        
       
        if(jobData?.status == "POSTED"){
            
            if(bidData?.owner_status == "REJECTED"){
               
                animation!.animation = Animation.named("bid_rejected_by_you")
                statusLabel.text = "Oferta Rechazada por ti"
                
                
            } else if(bidData?.owner_status == "ACCEPTED") {
                
                animation!.animation = Animation.named("work_accepted")
                statusLabel.text = "Trabajo aceptado"
                
                
            } else {
                animation!.animation = Animation.named("work_start")
                statusLabel.text = "Oferta Creada"
                
                data.append([
                    "type": "positiveButton",
                    "title": "Aceptar",
                    "action": "AceptBid"
                ])
                
                data.append([
                    "type": "negativeButton",
                    "title": "Rechazar",
                    "action": "RejectBid"
                ])
                
            }
              
        } else if(jobData?.status == "CLOSED") {
            
        } else if(jobData?.status == "ACCEPTED") {
            animation!.animation = Animation.named("work_accepted")
            statusLabel.text = "Trabajo aceptado"
            
            data.append([
                "type": "positiveButton",
                "title": "Mensaje",
                "action": "message"
            ])
            
            data.append([
                "type": "positiveButton",
                "title": "Comenzar Trabajo",
                "action": "StartWorkerJob"
            ])
            
            data.append([
                "type": "negativeButton",
                "title": "Cancelar Trabajo",
                "action": "CancelJob"
            ])
            
        } else if(jobData?.status == "REJECTED") {
            
        } else if(jobData?.status == "STARTED") {
            
          
            data.append([
                "type": "positiveButton",
                "title": "Mensaje",
                "action": "message"
            ])
            
            if( self.jobData?.started_by != nil &&   self.jobData?.started_by == "HIRE"){
                animation!.animation = Animation.named("rocket")
                statusLabel.text = "Trabajo en progreso"
                
                data.append([
                    "type": "positiveButton",
                    "title": "Finalizar trabajo",
                    "action": "finishWorkerJob"
                ])
                
            } else {
                
                animation!.animation = Animation.named("waiting_for_worker")
                statusLabel.text = "Esperando que el cliente confirme inicio del trabajo"

            }
            
          
        } else if(jobData?.status == "FINISHED") {
            
            animation!.animation = Animation.named("work_finish_release_payment")
            statusLabel.text = "Esperando liberación de pago"
            
            data.append([
                "type": "positiveButton",
                "title": "Mensaje",
                "action": "message"
            ])
            
        } else if(jobData?.status == "PAID") {
            animation!.animation = Animation.named("wallet_credit")
            statusLabel.text = "Trabajo finalizado"
        }
        
        animation?.loopMode = .loop
        animation?.play()
    }
    
    func renderStatusFromJob(){
        
       
        if(jobData?.status == "POSTED"){
            
            if(bidData?.owner_status == "REJECTED"){
               
                animation!.animation = Animation.named("bid_rejected_by_you")
                statusLabel.text = "Oferta Rechazada por ti"
                
                
            } else if(bidData?.owner_status == "ACCEPTED") {
                animation!.animation = Animation.named("work_accepted")
                statusLabel.text = "Trabajo aceptado"
            } else {
                animation!.animation = Animation.named("work_start")
                statusLabel.text = "Oferta Creada"
                
                data.append([
                    "type": "positiveButton",
                    "title": "Aceptar",
                    "action": "AceptBid"
                ])
                
                data.append([
                    "type": "negativeButton",
                    "title": "Rechazar",
                    "action": "RejectBid"
                ])
                
            }
            
            
          
            
        } else if(jobData?.status == "CLOSED") {
            
        } else if(jobData?.status == "ACCEPTED") {
            animation!.animation = Animation.named("work_accepted")
            statusLabel.text = "Trabajo aceptado"
            data.append([
                "type": "positiveButton",
                "title": "Mensaje",
                "action": "message"
            ])
            
            data.append([
                "type": "negativeButton",
                "title": "Cancelar Trabajo",
                "action": "CancelJob"
            ])
            
        } else if(jobData?.status == "REJECTED") {
            
        } else if(jobData?.status == "STARTED") {
            
            if( self.jobData?.started_by != nil &&   self.jobData?.started_by == "HIRE"){
                animation!.animation = Animation.named("rocket")
                statusLabel.text = "Trabajo en progreso"
            } else {
                animation!.animation = Animation.named("work_start")
                statusLabel.text = "Trabajo iniciado"
                
                data.append([
                    "type": "positiveButton",
                    "title": "Confirmar inicio de trabajo",
                    "action": "StartHireJob"
                ])
            }
        
            data.append([
                "type": "positiveButton",
                "title": "Mensaje",
                "action": "message"
            ])
            
         
            
        } else if(jobData?.status == "FINISHED") {
            animation!.animation = Animation.named("work_finish_release_payment")
            statusLabel.text = "Trabajo terminado, liberar pago!"
            
            data.append([
                "type": "positiveButton",
                "title": "Finalizar y Liberar Pago",
                "action": "finishHireJob"
            ])
            
        } else if(jobData?.status == "PAID") {
            animation!.animation = Animation.named("wallet_credit")
            statusLabel.text = "Trabajo finalizado"
        } 
        
        animation?.loopMode = .loop
        animation?.play()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        renderJobData()
    }
  

}

extension BidDetailViewController: BidCellDetailDelegate{
    func tapButton(indexCell: IndexPath, tagButton: Int) {
        let item = data[indexCell.row]
        
        if(item["action"] == "AceptBid"){
            aceptBid()
        } else if(item["action"] == "RejectBid"){
            rejectBid()
        } else if(item["action"] == "CancelJob"){
            cancelJob()
        } else if(item["action"] == "message"){
            openChat()
        } else if(item["action"] == "StartWorkerJob"){
            startWorkerJob()
        } else if(item["action"] == "StartHireJob"){
            startHireJob()
        } else if(item["action"] == "finishWorkerJob"){
            finishWorkerJob()
        } else if(item["action"] == "finishHireJob"){
            releasePayment()
        }
      
    }
}

extension BidDetailViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        let item = data[indexPath.row]
        
        if(item["type"] == "threeLabel"){
            return 280.0
        } else if(item["type"] == "fiveLabel") {
            return 420.0
        }  else if(item["type"] == "positiveButton" || item["type"] == "negativeButton") {
            return 70.0
        }
             
        return 140.0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = data[indexPath.row]
        
        var identifier = "dataBidOne"
        let type = item["type"]
        
        if(type == "threeLabel"){
            identifier = "dataBidThree"
        } else if(type == "fiveLabel") {
            identifier = "dataBidFive"
        } else if(type == "positiveButton"){
            identifier = "positiveButton"
        } else if(type == "negativeButton"){
            identifier = "negativeButton"
        }
             
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! BidCellDetail
       
        cell.indexPath = indexPath
        
        if(type != "positiveButton" && type != "negativeButton"){
            cell.title.text = item["title"]
            cell.card.defaultShadow()
        } else {
            cell.button.setTitle(item["title"], for: .normal)
            cell.button.setTitle(item["title"], for: .highlighted)
            cell.button.setTitle(item["title"], for: .selected)
        }
        
        if(item["label1"] != nil){
            cell.label1.text = item["label1"]
            cell.detail1.text = item["detail1"]
        }
        
        if(item["label2"] != nil){
            cell.label2.text = item["label2"]
            cell.detail2.text = item["detail2"]
        }
        
        if(item["label3"] != nil){
            cell.label3.text = item["label3"]
            cell.detail3.text = item["detail3"]
        }
        
        if(item["label4"] != nil){
            cell.label4.text = item["label4"]
            cell.detail4.text = item["detail4"]
        }
        
        if(item["label5"] != nil){
            cell.label5.text = item["label5"]
            cell.detail5.text = item["detail5"]
        }
        
        cell.delegate = self
    
        return cell
       
     
    }
    
    func aceptBid(){
        
        let storyboard  = UIStoryboard(name: "Home", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "PickerViewController") as! PaymentPickerViewController
        myVC.delegate = self
        self.view.window?.rootViewController?.present(myVC, animated: true, completion: nil)
        
    }
    
    func rejectBid(){
        ActivityIndicator.show(view: self.view)
        let param : [String:Any] = [
            "job_id": self.jobData?.job_id,
            "bid_id": self.bidData?.bid_id,
            "status": K_REJECT
            ]
        
        let url = "\(U_BASE)\(U_BID_ACTION)"
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_BID_ACTION) { (response) in
          
            ActivityIndicator.hide()
            
            let alert = UIAlertController(title: "Work It", message: "La oferta fue rechazada exitosamente", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
                self.navigationController?.popViewController(animated: true)
                  
            })
             
            self.present(alert, animated: true)
        }
    }
    
    func cancelJob(){
        
        let message = (mode == "HIRE") ? "¿Quieres cancelar el trabajo?" : "La cancelación del trabajo será sancionada con el 15% del monto del trabajo publicado. ¿Todavia quieres cancelar el trabajo?"
        
        let alert = UIAlertController(title: "Work It", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .default){ _ in
             
        })
        
        alert.addAction(UIAlertAction(title: "Si", style: .default){ _ in
             
        })
        
       
         
        self.present(alert, animated: true)
    }
    
    func openChat(){
        
        let storyboard  = UIStoryboard(name: "Main", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        myVC.jobDetail = self.jobData
        self.navigationController?.pushViewController(myVC, animated: true)
    }
    
    func startHireJob(){
        
        ActivityIndicator.show(view: self.view)

        let url = "\(U_BASE)\(U_OWNER_JOB_APPROVAL)"
        
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: ["job_id": self.jobData?.job_id ?? ""], objectClass: Response.self, requestCode: U_OWNER_JOB_APPROVAL) { (response) in
            
            ActivityIndicator.hide()
           
            self.jobData?.started_by = "HIRE"
            self.jobData?.status = "STARTED"
            
            self.renderJobData()
            self.tableView.reloadData()
            
        }
        
    }
    
    func startWorkerJob(){
        ActivityIndicator.show(view: self.view)
      
        var param :  [String:Any] = [
            "job_id": self.jobData?.job_id,
            "vendor_id": self.jobData?.job_vendor_id,
            "status": "STARTED"
        ]
        
        let url = "\(U_BASE)\(U_JOB_ACTION)"
        
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_JOB_ACTION) { response in
            
            self.jobData?.status = "STARTED"
            self.jobData?.started_by = "WORK"
            self.renderJobData()
            self.tableView.reloadData()
            ActivityIndicator.hide()
        }
    }
    
    func finishWorkerJob(){
        
        ActivityIndicator.show(view: self.view)
        
        var param :  [String:Any] = [
            "job_id":self.jobData?.job_id,
            "vendor_id":self.jobData?.job_vendor_id,
            "status": "FINISHED"
        ]
        
        let url = "\(U_BASE)\(U_JOB_ACTION)"
        
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_JOB_ACTION) { (response) in
            
            ActivityIndicator.hide()
            self.jobData?.status = "FINISHED"
            self.renderJobData()
            self.tableView.reloadData()
        }
        
    }
    
    
    func releasePayment(){
        ActivityIndicator.show(view: self.view)
        
        let param:  [String:Any] = ["job_id": jobData?.job_id!]
        
        let url = "\(U_BASE)\(U_RELEASE_JOB_PAYMENT)"
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_RELEASE_JOB_PAYMENT) { (response) in
            
            ActivityIndicator.hide()
            
            let storyboard  = UIStoryboard(name: "Home", bundle: nil)
            
            let navC = storyboard.instantiateViewController(withIdentifier: "RatingViewController") as! UINavigationController
            
      
            Singleton.shared.jobData = []
            Singleton.shared.postedHistoryData = []
            Singleton.shared.receivedHistoryData = []
            Singleton.shared.runningJobData = []
            
            let myVC = navC.viewControllers[0] as! RatingViewController
            myVC.jobId = self.jobData?.job_id ?? ""
           
            self.present(navC, animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
          
            
        }
    }
    
}

extension BidDetailViewController : PaymentPickerViewDelete {
    func aceptPayment() {
        
        let myVC  = UIStoryboard(name: "PaymentFlow", bundle: nil).instantiateInitialViewController() as! PaymentFlowViewController
        myVC.amount = self.bidData?.counteroffer_amount ?? 0
        myVC.delegate = self
        self.navigationController?.pushViewController(myVC, animated: true)
    }
    
}

extension BidDetailViewController : PaymentDelegate {
    func paymentComplete(response: GetTransaction?) {
        self.validatePayment(response?.data?.id ?? "")
    }
    
    func validatePayment(_ transactionId : String){
        
        ActivityIndicator.show(view: self.view)
        
        let param : [String:Any] = [
            "transanction_id": transactionId,
            "amount":  self.bidData?.counteroffer_amount ?? 0,
            "user_id": Singleton.shared.userInfo.user_id ?? ""
            ]
        
        let url = "\(U_BASE)\(U_GET_VERIFY)"
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: GetTransaction.self, requestCode: U_GET_VERIFY) { response in

            if((response?.data?.status ?? "") == "success"){
                self.confirmPayment(transactionId)
            } else {
                ActivityIndicator.hide()
            }
            
        }
    }
    
    func confirmPayment(_ transactionId: String){
     
        let param : [String:Any] = [
            "vendor_name": self.bidData?.vendor_name,
            "vendor_image": self.bidData?.vendor_image,
            "job_name": self.jobData?.job_name,
            "job_amount": self.bidData?.counteroffer_amount,
            "have_document": self.bidData?.have_document,
            "job_id": self.jobData?.job_id,
            "payment_option": "PAYKU",
            "transaction_id": transactionId,
            "user_id": Singleton.shared.userInfo.user_id ?? ""
        ]
        
        let url = "\(U_BASE)\(U_OWNER_JOB_PAYMENT)"
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_OWNER_JOB_PAYMENT) { response in
            
            self.AceptBidAction()
            
        }
    }
    
    func AceptBidAction(){
        ActivityIndicator.show(view: self.view)
        let param : [String:Any] = [
            "job_id": self.jobData?.job_id,
            "bid_id": self.bidData?.bid_id,
            "status": K_ACCEPT
            ]
        
        let url = "\(U_BASE)\(U_BID_ACTION)"
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_BID_ACTION) { (response) in
          
            ActivityIndicator.hide()
            
            let alert = UIAlertController(title: "Workit", message: "Tú pago fue realizado exitosamente", preferredStyle: .alert)
                      
            alert.addAction(UIAlertAction(title: "Ok", style: .default){ _ in
                self.navigationController?.popToRootViewController(animated: true)
            })
             
            self.present(alert, animated: true)
        }
    }
}

@objc public protocol BidCellDetailDelegate {
    func tapButton(indexCell: IndexPath, tagButton: Int)
}

class BidCellDetail : UITableViewCell {
    
    public var indexPath : IndexPath? = nil
    weak var delegate : BidCellDetailDelegate?
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var detail1: UILabel!
    
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var detail2: UILabel!
    
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var detail3: UILabel!
    
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var detail4: UILabel!
    
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var detail5: UILabel!
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var card: UIView!
    
    @IBAction func pressButton(_ sender : AnyObject){
        let button = sender as! UIButton
        
        if(delegate != nil){
            delegate?.tapButton(indexCell: indexPath!, tagButton: button.tag)
        }
    }
    
}
