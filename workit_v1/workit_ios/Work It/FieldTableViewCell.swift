//
//  TableViewCell.swift
//  Work It
//
//  Created by Jorge Acosta on 07-11-20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import MapKit

@objc public protocol FieldTableViewCellDelegate {
    func tapButton(indexCell: IndexPath, tagButton: Int)
    func textFieldDidEnd(indexCell: IndexPath, text: String, _ tag: Int)
    @objc optional func textChange(indexCell: IndexPath, textField: UITextField, range: NSRange, string: String)
    @objc optional func tapCollectionItem(indexCell: IndexPath)
    @objc optional func tapCollectionDeleteItem(indexCell: IndexPath)
    @objc optional func changeTextView(indexCell: IndexPath,text: String)
}

class FieldTableViewCell: UITableViewCell, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var mapView : MapVC!
    @IBOutlet weak var fieldTextField: UITextField!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var card : UIView!
    @IBOutlet weak var fieldTextView: UITextView!
    @IBOutlet weak var prefixLabel : UILabel!
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var imageCollection : UICollectionView!
    
    public var indexPath : IndexPath? = nil
    public var placeHolder = ""
    public var placeHolder2 = ""
    public var maxLength = 20
    
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
        
        if(self.fieldTextView != nil){
            self.fieldTextView.delegate = self
            
        }
    }
    
    func reloadData(){
        if(self.imageCollection != nil){
            self.imageCollection.reloadData()
        }
    }
    
    func setLocation(_ location : CLLocation){
        DispatchQueue.main.async {
       
            self.mapView.latitude = location.coordinate.latitude
            self.mapView.longitude = location.coordinate.longitude
      

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
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if(self.delegate != nil){
            
            self.delegate?.changeTextView?(indexCell: self.indexPath!, text: textView.text)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(delegate != nil){
            delegate?.textFieldDidEnd(indexCell: indexPath!, text: textField.text!, textField.tag)
        }
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == self.placeHolder2 {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
 
        if textView.text.isEmpty {
            textView.text = self.placeHolder2
            textView.textColor = UIColor.lightGray
            
        }
        
        if(delegate != nil){
            delegate?.textFieldDidEnd(indexCell: indexPath!, text: textView.text!, textView.tag)
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
       
        
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= maxLength
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(delegate != nil){
            self.delegate?.textChange?(indexCell: self.indexPath!, textField: textField, range: range, string: string)
        }
       
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

   
        return updatedText.count <= maxLength
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
            if(cell.deleteBtn != nil){
                cell.deleteBtn.isHidden = false
            }
            cell.jobImage.sd_setImage(with: URL(string: self.images[indexPath.row]),placeholderImage: #imageLiteral(resourceName: "dummyProfile"))
            cell.deleteButton = {
                
                if(self.delegate != nil){
                    self.delegate?.tapCollectionDeleteItem?(indexCell: indexPath)
                }
               
               
            }
        }
        
        
        return cell
    }
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(self.delegate != nil){
            self.delegate?.tapCollectionItem?(indexCell: indexPath)
        }
    }
   
    
}

