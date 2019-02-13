//
//  App.swift
//  RemoteConfigPOC
//
//  Created by Veli Bacik on 7.02.2019.
//  Copyright © 2019 Veli Bacik. All rights reserved.
//

import Foundation
import sqliteLib

public class App : Sqlable {
    var id : Int = 0
    var version : String = "1.0.0"
    var website : String?
    
    
    var constaintId : ColumnConstraint? = ColumnConstraint(columnName: "id", constraintType: ColumnConstraintType.PrimaryKey, autoIncrement: false)
    public required init(){
        
    }
    
}
