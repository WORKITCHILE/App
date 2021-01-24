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
import SwiftPhotoGallery


class BidDetailViewController: UIViewController {

    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var userImage : ImageView!
    @IBOutlet weak var verifyIcon : UIImageView!
    @IBOutlet weak var userName : UILabel!
    
    var data: [[String: Any]] = []
    var jobData: GetJobResponse?
    var bidData : BidResponse?
    var fromNotification = false
    
    var mode = "HIRE"
    
    var galleryImages: [String] = []
 
    override func viewDidLoad() {
        super.viewDidLoad()

        self.verifyIcon.isHidden = true
        self.tableView.dataSource = self
        self.tableView.delegate = self
       
        if(jobData?.vendor_image != nil){
            userImage.sd_setImage(with: URL(string: jobData?.vendor_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            userName.text = jobData?.vendor_name
            self.verifyIcon.isHidden = !(jobData?.have_vendor_document ?? false)
        } else if(bidData == nil){
                userName.text = "NINGÚN WORKER TOMO ESTE TRABAJO"
            userImage.image = UIImage(named:"ic_user_not_found")
        } else {
            userImage.sd_setImage(with: URL(string: bidData?.vendor_image ?? ""),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            self.verifyIcon.isHidden = !(bidData?.have_vendor_document ?? false)
            userName.text = bidData?.vendor_name
        }
        
        if(self.fromNotification){
            self.setNavigationBarForClose()
        } else {
            self.setNavigationBar()
        }
        
    }

    
    func renderJobData(){
        
        data = []
        
        if(!(jobData?.vendor_image == nil && bidData == nil)){
            data.append([ "type": "userRanking" ])
            data.append([ "type":"category" ])
        }
        
        
        
         if(jobData?.vendor_image == nil && bidData == nil){
            data.append([
                "type": "positiveButton",
                "title": "Republicar trabajo",
                "action": "repostJob"
            ])
         }
        
        data.append([ "type": "statusCard" ])
        
        // PAID
        
        if(jobData?.status == "PAID") {
            data.append([ "type":"disclaimer", "text": "Recuerda que dentro de 3 días hábiles recibiras tu pago en tu cuenta" ])
        }
        
        if(mode == "HIRE"){
            if(jobData?.status == "CANCELED" && jobData?.canceled_by == "WORK") {
                data.append([ "type":"disclaimer", "text": "Dentro de 3 días hábiles recibiras tu devolución en tu cuenta bancaria." ])
            }
        }
       
        
        data.append([
            "type": "oneLabel",
            "title": "Trabajo",
            "label1": "TITULO",
            "detail1": jobData?.job_name ?? ""
        ])
        
        
    
        let counteroffer_amount: Int = (bidData == nil) ? (Int(jobData?.service_amount ?? 0.0)) : (bidData?.counteroffer_amount ?? 0)
        
        data.append([
            "type":"fiveLabel",
            "title":"Detalles del trabajo",
            "label1":"PUBLICADO POR",
            "detail1": jobData?.user_name ?? "",
            "label2":"MONTO OFERTADO",
            "detail2": "$\(counteroffer_amount.formattedWithSeparator)" ,
            "label3":"CATEGORIA",
            "detail3": jobData?.category_name ?? "",
            "label4":"SUBCATEGORIA",
            "detail4": jobData?.subcategory_name ?? "",
            "label5":"TIPO DE TRABAJO",
            "detail5": jobData?.job_approach ?? "",
        ])
        
        
        data.append([
            "type": "dataBidOneWithoutDetail",
            "title": "Descripción",
            "label1": jobData?.job_description ?? ""
        ])
        
       
        
        if(jobData?.vendor_image != nil){
        
            let comment : String = (bidData == nil) ? (jobData?.comment as! String) : (bidData?.comment as! String)
            data.append([
                "type": "dataBidOneWithoutDetail",
                "title": "Comentarios del Worker",
                "label1": comment
            ])
        }

        
        if(self.jobData?.images != nil && (self.jobData?.images?.count ?? 0) > 0){
            data.append([
                "type": "fieldCollection",
                "title": "Fotos del trabajo",
                "value": self.jobData?.images
            ])
        }
      
        if(bidData?.vendor_images != nil && (bidData?.vendor_images.count ?? 0) > 0){
            data.append([
                "type": "fieldCollection",
                "title": "Portafolio del worker",
                "value": bidData?.vendor_images
            ])
        }
        
        let address_reference = jobData?.job_address_reference! ?? ""
        let address_number = jobData?.job_address_number! ?? ""
        
        data.append([
            "type": "threeLabel",
            "title": "Trabajo",
            "label1": "DIRECCIÓN",
            "detail1": jobData?.job_address ?? "",
            "label2": "CASA / DEPARTAMENTO",
            "detail2": (address_number == "") ? "-" : address_number,
            "label3": "REFERENCIA",
            "detail3": (address_reference == "") ? "-" : address_reference
        ])
        
        //
        
       
        data.append([
            "type": "threeLabel",
            "title": "Calendario",
            "label1": "PUBLICADO",
            "detail1": self.convertTimestampToDate(jobData?.job_time ?? 0, to: "dd/MM/YYY"),
            "label2": "FECHA DE INICIO",
            "detail2": jobData?.job_date! ?? "",
            "label3": "HORARIO",
            "detail3": self.convertTimestampToDate(jobData?.job_time ?? 0, to: "h:mm a")
        ])
        
        if(mode == "HIRE"){
            validateButtonsFromJob()
        } else {
            validateButtonsFromJobWorker()
        }
       
    }
    

    func renderNotVendorStatus(_ animation : AnimationView, _ statusLabel : UILabel){
        if(jobData?.vendor_image == nil && bidData == nil){

            animation.animation = Animation.named("work_cancel")
            statusLabel.text = "Trabajo Cancelado"
            animation.loopMode = .loop
            animation.play()
           
        }
    }
    
    func validateButtonsFromJobWorker(){
        
    
       if(jobData?.status == "POSTED"){
            
            if(bidData?.owner_status != "REJECTED" && bidData?.owner_status != "ACCEPTED"){

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
              
        } else if(jobData?.status == "ACCEPTED") {
           
            data.append([
                "type": "positiveButton",
                "title": "Mensaje",
                "action": "message"
            ])
            
            // validate
        
            let jobDate = Date(timeIntervalSince1970: TimeInterval((jobData?.job_time)!)).formatWithZoneTime()
            let now = Date().formatWithZoneTime()
            
    
         
            if(jobDate <= now){
                data.append([
                    "type": "positiveButton",
                    "title": "Comenzar Trabajo",
                    "action": "StartWorkerJob"
                ])
            }
          
            
           
            
            data.append([
                "type": "negativeButton",
                "title": "Cancelar Trabajo",
                "action": "CancelJob"
            ])
            
        }  else if(jobData?.status == "STARTED") {
            
          
            data.append([
                "type": "positiveButton",
                "title": "Mensaje",
                "action": "message"
            ])
            
            if( self.jobData?.started_by != nil &&   self.jobData?.started_by == "HIRE"){
               
                data.append([
                    "type": "positiveButton",
                    "title": "Finalizar trabajo",
                    "action": "finishWorkerJob"
                ])
                
            }
            
          
        } else if(jobData?.status == "FINISHED") {

            data.append([
                "type": "positiveButton",
                "title": "Mensaje",
                "action": "message"
            ])
            
        }
    }
    
    func renderStatusFromJobWorker(_ animation : AnimationView, _ statusLabel : UILabel){
        
       
        if(jobData?.status == "CANCELED"){
            animation.animation = Animation.named("work_cancel")
            statusLabel.text = "Trabajo Cancelado"
        } else if(jobData?.status == "POSTED"){
            
            if(bidData?.owner_status == "REJECTED"){
               
                animation.animation = Animation.named("bid_rejected_by_you")
                statusLabel.text = "Oferta Rechazada por ti"
                
                
            } else if(bidData?.owner_status == "ACCEPTED") {
                
                animation.animation = Animation.named("work_accepted")
                statusLabel.text = "Trabajo aceptado"
                
                
            } else {
                animation.animation = Animation.named("work_start")
                statusLabel.text = "Oferta Creada"
                
            }
              
        } else if(jobData?.status == "CLOSED") {
            
        } else if(jobData?.status == "ACCEPTED") {
            animation.animation = Animation.named("work_accepted")
            statusLabel.text = "Trabajo aceptado"
            
        } else if(jobData?.status == "REJECTED") {
            
        } else if(jobData?.status == "STARTED") {
            
            
            if( self.jobData?.started_by != nil &&   self.jobData?.started_by == "HIRE"){
                animation.animation = Animation.named("rocket")
                statusLabel.text = "Trabajo en progreso"
                
            } else {
                
                animation.animation = Animation.named("waiting_for_worker")
                statusLabel.text = "Esperando que el cliente confirme inicio del trabajo"

            }
            
          
        } else if(jobData?.status == "FINISHED") {
            
            animation.animation = Animation.named("work_finish_release_payment")
            statusLabel.text = "Esperando liberación de pago"

            
        } else if(jobData?.status == "PAID") {
            animation.animation = Animation.named("wallet_credit")
            statusLabel.text = "Trabajo finalizado"
        }
        
        animation.loopMode = .loop
        animation.play()
    }
    
    func validateButtonsFromJob(){
       
            if(jobData?.status == "POSTED"){
                
                if(bidData?.owner_status != "REJECTED" && bidData?.owner_status != "ACCEPTED"){
                   
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
                 
            } else if(jobData?.status == "ACCEPTED") {
               
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
                
            } else if(jobData?.status == "STARTED") {
                
                if( self.jobData?.started_by != nil &&   self.jobData?.started_by == "HIRE"){
                    
                } else {
                    
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
                
                data.append([
                    "type": "positiveButton",
                    "title": "Finalizar y Liberar Pago",
                    "action": "finishHireJob"
                ])
                
            }
            
         
    }
    
    func renderStatusFromJob(_ animation : AnimationView?, _ statusLabel : UILabel){
        
      
        if(jobData?.status == "CANCELED"){
            animation!.animation = Animation.named("work_cancel")
            statusLabel.text = "Trabajo Cancelado"
        }else if(jobData?.status == "POSTED"){
            
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
        self.tableView.reloadData()
    }
  

}


extension BidDetailViewController: SwiftPhotoGalleryDataSource, SwiftPhotoGalleryDelegate{
    
    func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
        return galleryImages.count
    }

    func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
        let newImageView = UIImageView()
        newImageView.sd_setImage(with: URL(string: galleryImages[forIndex]),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        
        return  newImageView.image
    }

    func galleryDidTapToClose(gallery: SwiftPhotoGallery) {
        dismiss(animated: true, completion: nil)
    }
}



extension BidDetailViewController: BidCellDetailDelegate{
    
    func tapCollectionItem(indexCell: IndexPath, parentCell: IndexPath) {
        
      
        galleryImages = (self.data[parentCell.row]["value"] as? [String])!
       
        let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
        
        gallery.backgroundColor = UIColor.black
        gallery.pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.5)
        gallery.currentPageIndicatorTintColor = UIColor.white
        gallery.hidePageControl = false
        gallery.currentPage = indexCell.row
    

        present(gallery, animated: true, completion: nil)
     
    }
    
    func tapButton(indexCell: IndexPath, tagButton: Int) {
        let item = data[indexCell.row]
        
        if(item["action"] as! String == "AceptBid"){
            aceptBid()
        } else if(item["action"] as! String == "RejectBid"){
            rejectBid()
        } else if(item["action"] as! String == "CancelJob"){
            cancelJob()
        } else if(item["action"] as! String == "message"){
            openChat()
        } else if(item["action"] as! String == "StartWorkerJob"){
            startWorkerJob()
        } else if(item["action"] as! String == "StartHireJob"){
            startHireJob()
        } else if(item["action"] as! String == "finishWorkerJob"){
            finishWorkerJob()
        } else if(item["action"] as! String == "finishHireJob"){
            releasePayment()
        } else if(item["action"] as! String == "repostJob"){
            
            let alert = UIAlertController(title: "Workit", message: "¿Quieres volver a publicar con una nueva hora y fecha?", preferredStyle: .alert)
          
            alert.addAction(UIAlertAction(title: "Republicar Trabajo", style: .default, handler: { action in
                let storyboard  = UIStoryboard(name: "Home", bundle: nil)
                let nav = storyboard.instantiateViewController(withIdentifier: "PostJobContainer") as! UINavigationController
                let myVC = nav.viewControllers[0] as! PostJobViewController
                myVC.jobDetail = self.jobData
                myVC.isRepostJob = true
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            
         
        }
      
    }
}

extension BidDetailViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        let item = data[indexPath.row]
        let type : String = (item["type"] as? String)!
        
        if(type == "threeLabel"){
            return 280.0
        } else if(type == "fiveLabel") {
            return 420.0
        }  else if(type == "positiveButton" || type == "negativeButton") {
            return 70.0
        } else if(type == "category" || type == "userRanking") {
            return 40.0
        } else if(type == "disclaimer"){
            return 74.0
        } else if(type == "statusCard"){
            return 115.0
        } else if(type == "fieldCollection"){
            return 180.0
        } else if(type == "dataBidOneWithoutDetail"){
            
            let attribString =  NSMutableAttributedString(string: item["label1"]! as! String)
            
           
           
            return  attribString.height(self.view.frame.size.width - 80.0) + 98.0
        }
             
        return 140.0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = data[indexPath.row]
        
        var identifier = "dataBidOne"
        let type : String = (item["type"] as! String)
        
        if(type == "threeLabel"){
            identifier = "dataBidThree"
        } else if(type  == "fiveLabel") {
            identifier = "dataBidFive"
        } else if(type  == "positiveButton"){
            identifier = "positiveButton"
        } else if(type  == "negativeButton"){
            identifier = "negativeButton"
        } else if(type == "statusCard"){
            identifier = "animationCard"
        } else if(type  == "userRanking"){
            identifier = "userRanking"
        }  else if(type  == "category"){
            identifier = "category"
        } else if(type  == "dataBidOneWithoutDetail"){
            identifier = "dataBidOneWithoutDetail"
        } else if(type == "fieldCollection"){
            identifier = "fieldCollection"
        } else if(type == "disclaimer"){
            identifier = "disclaimer"
        }
             
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! BidCellDetail
       
        cell.indexPath = indexPath
        
        if(type == "statusCard"){
            if(mode == "HIRE"){
                renderStatusFromJob(cell.animation, cell.statusLabel)
            } else {
                renderStatusFromJobWorker(cell.animation, cell.statusLabel)
            }
            renderNotVendorStatus(cell.animation, cell.statusLabel)
        } else if(type == "userRanking"){
            
          
            if(jobData?.vendor_image != nil){
                cell.cosmoRating.rating = Double(jobData?.vendor_average_rating ?? "0")!
                
            } else  if(bidData != nil){
                cell.cosmoRating.rating = Double(bidData?.average_rating ?? "0")!
            }
        }else if(type == "category"){
            if(jobData?.vendor_image != nil){
                cell.categoryLabel.text = jobData?.vendor_occupation
            } else  if(bidData != nil){
                cell.categoryLabel.text = bidData?.vendor_occupation
            }
        }else if(type == "disclaimer"){
            cell.categoryLabel.text = item["text"] as? String
        }  else if(type == "dataBidOneWithoutDetail"){
            cell.title.text = item["title"] as? String
            cell.label1.text = item["label1"] as? String
            cell.card.defaultShadow()
        } else if(type == "fieldCollection"){
            cell.title.text = item["title"] as? String
            
            cell.images = item["value"] as! [String]
            
            cell.reloadData()
            cell.card.defaultShadow()
        } else {
            if(type != "positiveButton" && type != "negativeButton"){
                cell.title.text = item["title"] as? String
                cell.card.defaultShadow()
            } else {
                cell.button.setTitle(item["title"] as? String, for: .normal)
                cell.button.setTitle(item["title"] as? String, for: .highlighted)
                cell.button.setTitle(item["title"] as? String, for: .selected)
            }
            
            if(item["label1"] != nil){
                cell.label1.text = item["label1"] as? String
                cell.detail1.text = item["detail1"] as? String
                
            }
            
            if(item["label2"] != nil){
                cell.label2.text = item["label2"] as? String
                cell.detail2.text = item["detail2"] as? String
            }
            
            if(item["label3"] != nil){
                cell.label3.text = item["label3"] as? String
                cell.detail3.text = item["detail3"] as? String
            }
            
            if(item["label4"] != nil){
                cell.label4.text = item["label4"] as? String
                cell.detail4.text = item["detail4"] as? String
            }
            
            if(item["label5"] != nil){
                cell.label5.text = item["label5"] as? String
                cell.detail5.text = item["detail5"] as? String
            }
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
        
        let message = (mode == "WORK") ? "¿Quieres cancelar el trabajo?" : "La cancelación del trabajo será sancionada con el 15% del monto del trabajo publicado. ¿Todavia quieres cancelar el trabajo?"
        
        let alert = UIAlertController(title: "Work It", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .default){ _ in
            
        })
        
        alert.addAction(UIAlertAction(title: "Si", style: .default){ _ in
            self.confirmCancelJob()
        })
        
       
         
        self.present(alert, animated: true)
    }
    
    func confirmCancelJob(){
        
        
        ActivityIndicator.show(view: self.view)
        let param : [String : Any] = [
           "job_id": self.jobData?.job_id,
           "user_id": Singleton.shared.userInfo.user_id
        ]
        
        
        let url = (mode == "WORK") ?  "\(U_BASE)\(U_VENDOR_CANCEL_JOB)" : "\(U_BASE)\(U_CANCEL_JOB)"
        SessionManager.shared.methodForApiCalling(url: url, method: .post, parameter: param, objectClass: Response.self, requestCode: U_CANCEL_JOB) { (response) in
           ActivityIndicator.hide()
        
            self.navigationController?.popViewController(animated: true)
           
        }
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
        myVC.marketplace = self.bidData!.marketplace
        myVC.vendor_id = self.bidData!.vendor_id
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
    @objc optional func tapCollectionItem(indexCell: IndexPath, parentCell: IndexPath)
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
    
    @IBOutlet weak var animation : AnimationView!
    @IBOutlet weak var statusLabel : UILabel!
    @IBOutlet weak var categoryLabel : UILabel!
    @IBOutlet weak var cosmoRating : CosmosView!
    
    @IBOutlet weak var imageCollection : UICollectionView!
    
    var images : [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()

        if(self.imageCollection != nil){
            self.imageCollection.delegate = self
            self.imageCollection.dataSource = self
            self.imageCollection.isPagingEnabled = true
        }
    }
    
    func reloadData(){
        if(self.imageCollection != nil){
            self.imageCollection.reloadData()
        }
    }
    
    @IBAction func pressButton(_ sender : AnyObject){
        let button = sender as! UIButton
        
        if(delegate != nil){
            delegate?.tapButton(indexCell: indexPath!, tagButton: button.tag)
        }
    }
    
}


extension BidCellDetail: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardCollection", for: indexPath) as! DashboardCollection
        
        cell.addBtn.isHidden = true
    
        cell.jobImage.sd_setImage(with: URL(string: self.images[indexPath.row]),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(self.delegate != nil){
            
          
            self.delegate?.tapCollectionItem?(indexCell: indexPath, parentCell:   self.indexPath!)
        }
    }
 
   
    
}


