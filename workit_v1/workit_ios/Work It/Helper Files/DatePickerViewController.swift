//
//  DatePickerViewController.swift
//  Rated Sitter
//
//  Created by qw on 14/11/19.
//  Copyright © 2019 qualwebs. All rights reserved.
//

import UIKit

class DatePickerViewController: ParentViewController {
    //MARK: IBOutlets
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var dateDelegate:SelectDate? = nil
    var selectedDate = Int()
    var pickerMode = 1
    var minDate:Date? = nil
    var maxDate:Date? = nil
    var isCalenderScreen = false
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(isCalenderScreen){
            self.datePicker.datePickerMode = .date
           
        }else{
            if(pickerMode == 1){
                self.datePicker.datePickerMode = .date
            }else if(pickerMode == 2){
                self.datePicker.datePickerMode = .time
            }else {
                self.datePicker.datePickerMode = .dateAndTime
            }
            if(minDate != nil){
                datePicker.minimumDate = minDate!
            }
            
            if(selectedDate != 0){
                datePicker.date = Date(timeIntervalSince1970: TimeInterval(exactly: Double(self.selectedDate))!)
            }
            if(maxDate != nil){
                datePicker.maximumDate = maxDate!
            }
        }
        
    }
    
    //MARK: IBActions
    @IBAction func doneAction(_ sender: Any) {
        let time = datePicker.date.timeIntervalSince1970
        self.dateDelegate?.selectedDate(date: Int(time))
        self.dismiss(animated: true, completion: nil)
    }
    
}
