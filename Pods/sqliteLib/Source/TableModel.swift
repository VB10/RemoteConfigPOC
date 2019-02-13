//
//  TableModel.swift
//  SQLITE
//
//  Created by Umut BOZ on 04/09/2017.
//  Copyright © 2017 Kocsistem. All rights reserved.
//

import Foundation

class TableModel {
    
    init() {
        self.isDrop = true
    }
   static let type_key : String  = "table";
   static let tbl_name_key : String  = "tbl_name";
   static let sql_key : String  = "sql";
    
    
    
    var tableName : String?
    var sql : String?
    var isDrop : Bool = true
    
    
}
