//
//  ReceivedJobViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class ReceivedJobViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


    }

}

extension ReceivedJobViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobTableView") as! JobTableView
        return cell
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "JobDetailViewController") as! JobDetailViewController
//        self.navigationController?.pushViewController(myVC, animated: true)
//    }
}
