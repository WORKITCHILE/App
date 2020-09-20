//
//  AddCreditViewController.swift
//  Work It
//
//  Created by Jorge Acosta on 20-09-20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class AddCreditViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {

    //MARK: IBOutlets
       @IBOutlet weak var pickerView: UIPickerView!
       
       
       var pickerDelegate:SelectFromPicker? = nil
       var pickerData = [String]()
       var pickerHeading = String()
       
       var index = Int()
       var values = [5000,10000,15000,20000,25000,30000,35000,40000,450000]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let img = UIImage(named: "header_rect_green")
        navigationController?.navigationBar.setBackgroundImage(img, for: .default)
      
        self.pickerView.delegate = self
        
        pickerData.append("$5.000")
        pickerData.append("$10.000")
        pickerData.append("$15.000")
        pickerData.append("$20.000")
        pickerData.append("$25.000")
        pickerData.append("$30.000")
        pickerData.append("$35.000")
        pickerData.append("$40.000")
        pickerData.append("$45.000")
    }

    
    //MARK: IBActions
     
     @IBAction func dismissView(_ sender: AnyObject){
        self.dismiss(animated: true, completion: nil)
     }
    

     func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
     }
        
     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData.count
     }
     
     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         return self.pickerData[row]
     }
     
     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
         self.index = row
     }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc =  segue.destination as! PaymentFlowViewController
        vc.amount = self.values[self.index]
    }
}



