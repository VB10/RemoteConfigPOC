//
//  BaseDatabase.swift
//  RemoteConfigPOC
//
//  Created by Veli Bacik on 7.02.2019.
//  Copyright © 2019 Veli Bacik. All rights reserved.
//

import Foundation
import sqliteLib

class BaseDB : BaseDatabase  {
    
    static var instance :  BaseDB?
    let databaseName : String = "VB_Sample"
    
    static let shared : BaseDB? = {
        if instance == nil {
            instance = BaseDB()
        }
        return instance
    } ()
    
    init() {
        super.init(databaseName : databaseName, db_version : 1)
        addTable(table: App())
    }
    
    func getList<T : Sqlable>(with model : T.Type) -> [T] {
        let list = BaseDB.shared!.list(type: T.self)!
        return list
    }
    
    func addItem<T : Sqlable>(with model : T) -> Bool {
        BaseDB.shared?.delete(type: T.self)
        guard let count = BaseDB.shared?.insert(data: model) else { return false }
        return count > 0 ? true : false
    }
    
}
