//
//  TableViewCell.swift
//  Work It
//
//  Created by Jorge Acosta on 07-11-20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit

@objc public protocol FieldTableViewCellDelegate {
    func tapButton(indexCell: IndexPath, tagButton: Int)
    func textFieldDidEnd(indexCell: IndexPath, text: String)
    @objc optional func textChange(indexCell: IndexPath, textField: UITextField, range: NSRange, string: String)
    @objc optional func tapCollectionItem(indexCell: IndexPath)
    @objc optional func tapCollectionDeleteItem(indexCell: IndexPath)
}

class FieldTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var fieldTextField: UITextField!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var fieldTextView: UITextView!
    @IBOutlet weak var prefixLabel : UILabel!
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var imageCollection : UICollectionView!
    
    public var indexPath : IndexPath? = nil
    public var placeHolder = ""
    
    weak var delegate : FieldTableViewCellDelegate?
    
    var images = ["camera"]
        
    override func awakeFromNib() {
        super.awakeFromNib()
        if(self.fieldTextField != nil){
            self.fieldTextField.delegate = self
            self.fieldTextField.text = placeHolder
        }
        
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func borderEditable(){
        if(self.border != nil){
        self.border.layer.borderColor = UIColor(named: "calendar_green")?.cgColor
        }
    }
    
    func borderNotEditable(){
        if(self.border != nil){
            self.border.layer.borderColor = UIColor(named: "border")?.cgColor
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(self.fieldTextView != nil){
            if( self.fieldTextView.text == placeHolder){
                self.fieldTextView.text = ""
            } else if(self.fieldTextView.text == ""){
                self.fieldTextView.text = placeHolder
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(delegate != nil){
            delegate?.textFieldDidEnd(indexCell: indexPath!, text: textField.text!)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(delegate != nil){
            self.delegate?.textChange?(indexCell: self.indexPath!, textField: textField, range: range, string: string)
        }
        return true
    }
    
    @IBAction func tapButton(_ sender: AnyObject){
        let button = sender as! UIButton
        
        if(delegate != nil){
            delegate?.tapButton(indexCell: indexPath!, tagButton: button.tag)
        }
    }

}



extension FieldTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource{
    func delete(index : Int) {
        
        let url = self.images[index]
        let store = storageRef.storage.reference(forURL: url)
        
        store.delete { error in
            if error != nil {
                
            }else {
                self.images.remove(at: index)
                self.imageCollection.reloadData()
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardCollection", for: indexPath) as! DashboardCollection
        
        if(images[indexPath.row] == "camera"){
            cell.jobImage.image = #imageLiteral(resourceName: "ic_plus_form_green")
            cell.addBtn.isHidden = false
            cell.deleteBtn.isHidden = true
            cell.addButton = {
               
                if(self.delegate != nil){
                    self.delegate?.tapCollectionItem?(indexCell: indexPath)
                }
               
            }
        } else {
            cell.addBtn.isHidden = true
            cell.deleteBtn.isHidden = false
            cell.jobImage.sd_setImage(with: URL(string: self.images[indexPath.row]),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.deleteButton = {
                
                if(self.delegate != nil){
                    self.delegate?.tapCollectionDeleteItem?(indexCell: indexPath)
                }
               
               
            }
        }
        return cell
    }
    
    /*
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        let newImageView = UIImageView()
        newImageView.sd_setImage(with: URL(string: self.imageString[indexPath.row]),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        sender.view?.removeFromSuperview()
    }
    
    */
    
   
    
}

