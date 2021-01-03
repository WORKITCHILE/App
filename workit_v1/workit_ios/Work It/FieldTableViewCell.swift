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
}

class FieldTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var fieldTextField: UITextField!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var fieldTextView: UITextView!
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var collectionView : UICollectionView!
    
    public var indexPath : IndexPath? = nil
    public var placeHolder = ""
    
    weak var delegate : FieldTableViewCellDelegate?
    
    var images : [String] = [""]
        
    override func awakeFromNib() {
        super.awakeFromNib()
        if(self.fieldTextField != nil){
            self.fieldTextField.delegate = self
            self.fieldTextField.text = placeHolder
        }
        
        if(self.collectionView != nil){
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            self.collectionView.isPagingEnabled = true
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
        if( self.fieldTextView.text == placeHolder){
            self.fieldTextView.text = ""
        } else if(self.fieldTextView.text == ""){
            self.fieldTextView.text = placeHolder
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

extension FieldTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoItem", for: indexPath)
    
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(delegate != nil){
            delegate?.tapCollectionItem?(indexCell: indexPath)
        }
    }
    
}
