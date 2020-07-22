//
//  Protocol.swift
//  Agile Sports
//
//  Created by qw on 23/12/19.
//  Copyright © 2019 AM. All rights reserved.
//

import Foundation


protocol SelectDate {
    func selectedDate(date: Int)
}

protocol SelectFromPicker {
    func selectedItem(name:String, id: Int)
}

protocol AddNewTeam {
    func updateTeamTable()
}
