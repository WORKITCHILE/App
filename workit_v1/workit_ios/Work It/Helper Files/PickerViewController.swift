
import UIKit

class PickerViewController: ParentViewController, UIPickerViewDelegate, UIPickerViewDataSource {
   //MARK: IBOutlets
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var backgroundOverlay: UIView!
    @IBOutlet weak var pickerLabel: DesignableUILabel!
    
    
    var pickerDelegate:SelectFromPicker? = nil
    var pickerData = [String]()
    var pickerHeading = String()
    
    var index = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backgroundOverlay.alpha = 0.0
        if(self.pickerData.count == 0){
            self.dismiss(animated: true, completion: nil)
        }
        self.pickerView.delegate = self
//        self.pickerLabel.text = self.pickerHeading
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.5) {
            self.backgroundOverlay.alpha = 1.0
        } completion: { isComplited in
            
        }

    }


   //MARK: IBActions
    @IBAction func doneAction(_ sender: Any) {
        self.pickerDelegate?.selectedItem(name: self.pickerData[index], id: self.index)
        self.dismiss(animated: false, completion: nil)
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
}
