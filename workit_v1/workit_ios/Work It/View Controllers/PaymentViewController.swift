

import UIKit

class PaymentViewController: UIViewController {
    //MARK: IBOutlets
    @IBOutlet weak var payView: UIView!
    
    
    var isBackBtnHidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(K_CURRENT_USER == K_POST_JOB || isBackBtnHidden){
            self.payView.isHidden = true
        }
    }
    
    //MARK: IBActions
    @IBAction func backAction(_ sender: Any) {
        self.back()
    }
    
    @IBAction func payNowAction(_ sender: Any) {
        if(K_CURRENT_USER == K_WANT_JOB){
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
            self.navigationController?.pushViewController(myVC, animated: true)
        }else if(K_CURRENT_USER == K_POST_JOB){
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "PostedJobViewController") as! PostedJobViewController
            K_CURRENT_TAB = ""
            self.navigationController?.pushViewController(myVC, animated: true)
        }
    }
    
}
