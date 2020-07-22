//
//  PublicationViewController.swift
//  Work It
//
//  Created by qw on 04/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

class PublicationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    //MARK: IBActions
    
    @IBAction func backActions(_ sender: Any) {
        self.back()
    }
    
}

extension PublicationViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobTableView") as! JobTableView
        return cell
    }
    
}
