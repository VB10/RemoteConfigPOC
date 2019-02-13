                          //
//  KSDbManager.swift
//  SQLITE
//
//  Created by Umut BOZ on 29/08/2017.
//  Copyright © 2017 Kocsistem. All rights reserved.
//

import Foundation




open  class BaseDatabase  {
    
    
    let sqlManager = SqliteManager.instance
    var dbName : String
    var dbVersion : Int64
    var tables : Array<Sqlable> = []
    static var relations : [ColumnRelation] = []
    
    public init(databaseName : String = "", db_version : Int64 = 1) {
    
        self.dbVersion = db_version
        if databaseName != nil && !databaseName.isEmpty {
            self.dbName = databaseName + ".sqlite"
        }
        else {
            self.dbName = NSStringFromClass(type(of: self))  + ".sqlite"
        }
 
    /*
        do {

        }
        catch let error as NSError {
            print("db silinirken hata: \(error)")
            return;
        }
 */
    }
    ///DB CREATE
    public func connectionOrCreateDb(append : Bool = false) -> Void {
        print("dbName : " + self.dbName)
        sqlManager.connectionOrCreateDb(database:self,append:append)
    }
    public func addTable(table:Sqlable) -> Void {
        tables.append(table)
    }
    internal static func initRelationsDbToMemory() -> Void{
        BaseDatabase.relations = ColumnRelationSqlable.getColumnRelationsFromDb(sqlManager: SqliteManager.instance)
    }

    internal func createTables() -> Void {
        let currentVersion = getDbVersion()
        if self.dbVersion > currentVersion
        {
            //mevcut tablolar
        let currentTables = getCurrentTables()
        var dropForTables = [String]()
        let dbVersionStr = String(self.dbVersion)
        var CREATE_QUERY : String = ""
        //INIT INMEMORY ColumnRelation DATA
        BaseDatabase.relations = ColumnRelationSqlable.getColumnRelationsFromInMemory(tables: tables)
        let BEGIN_TRAN : String = "BEGIN TRANSACTION;"
        let COMMIT_TRAN : String = "COMMIT TRANSACTION;"
        
        if self.tables.count > currentTables.count
        {
            //yeni tablo eklenmis
            let newTables = self.tables.filter{ item in !currentTables.contains(where: { $0.tableName! == item.theClassName}) }
            // CREATE EDILECEK TABLO BULUNDU
            if newTables.count>0 {
               var CREATE_TABLES : String = "";
                CREATE_QUERY = BEGIN_TRAN
                
                newTables.forEach{ model in
                    
                        CREATE_TABLES += model.getCreateTableQuery()
                }
                
                CREATE_QUERY += CREATE_TABLES
                CREATE_QUERY += ColumnRelationSqlable.getCreateRelationTableQuery()
                CREATE_QUERY += "PRAGMA user_version = " + dbVersionStr + ";"
                CREATE_QUERY += COMMIT_TRAN
                print(CREATE_QUERY)
                
                do {
                    _ = try sqlManager.db?.execute(CREATE_QUERY);
                } catch let error as NSError  {
                    print("Tablolar oluşturulurken hata : \(error)")
                    return;
                }
            }
            
            // CREATE EDILECEK TABLOLAR BITTI
           
        }
        else if self.tables.count < currentTables.count
        {
            //tablo kaldırılmıs
            for table in currentTables {
                for newTable in self.tables {
                    if table.tableName!.caseInsensitiveCompare(newTable.theClassName)  ==  ComparisonResult.orderedSame{
                        table.isDrop = false
                        break
                    }
                }
            }
            var hasDropTable : Bool = false
            currentTables.forEach{ model in
                if model.isDrop{
                    hasDropTable = true
                }
            }
            if hasDropTable
            {
                var DROP_TABLES : String = "";
                DROP_TABLES = BEGIN_TRAN
                currentTables.forEach{ model in
                    
                    if model.isDrop{
                     DROP_TABLES += "DROP TABLE " + model.tableName! + ";"
                     
                    }
                }
                DROP_TABLES += "PRAGMA user_version = " + dbVersionStr + ";"
                DROP_TABLES += COMMIT_TRAN
                
                do {
                    _ = try sqlManager.db?.execute(DROP_TABLES);
                    print(DROP_TABLES)
                }
                catch
                {
                    print("Tablolar drop edilirken hata : \(error)")
                    return;
                }
            }
        }
        else if  self.tables.count == currentTables.count
        {
            //update edilecek bir tablo olabilir
            //columns kontrol
            for newTable in self.tables {
                let props = newTable.getReflectedModels()
                for table in currentTables {
                    
                    if newTable.theClassName.caseInsensitiveCompare(table.tableName!) ==  ComparisonResult.orderedSame{
                            
                            let columns = getColumnsOfTable(name: table.tableName!)
                            if columns.count > props.count{
                                //drop table  after create
                                dropForTables.append(table.tableName!)
                                
                                break
                            }
                            else if columns.count == props.count{
                                //degisiklik yok
                                break
                            }
                            else if columns.count < props.count{
                                //alter column once yeni column u bul
                                let addColumns = props.filter{ item in !columns.contains(item.propName) }
                                
                                var ALTER_TABLES : String = "";
                                ALTER_TABLES = BEGIN_TRAN
                                for col in addColumns {
                                    for key in props {
                                        if col.propName.caseInsensitiveCompare(key.propName) ==  ComparisonResult.orderedSame{
                                            ALTER_TABLES += "ALTER TABLE " + newTable.theClassName + " ADD COLUMN " + col.propName + " " + SqlTypeConverter.getSqlType(type:key.type) + " NULL;"
                                            break
                                        }
                                    }
                                }
                               
                                ALTER_TABLES += "PRAGMA user_version = " + dbVersionStr + ";"
                                ALTER_TABLES += COMMIT_TRAN
                                
                                do {
                                    
                                    _ = try sqlManager.db?.execute(ALTER_TABLES);
                                    print(ALTER_TABLES)
                                }
                                catch
                                {
                                    print("Tablolar drop edilirken hata : \(error)")
                                    return;
                                    
                                }
                            }
                      break
                        
                    }
                }
            }
            
            //drop columndan oturu drop edilecek ve sonra create edilecek tablo operasyonu
            
            if dropForTables.count>0{
                
              for drop in dropForTables {
                do{
                    let DROP_QUERY = "DROP TABLE " + drop
                   _ = try sqlManager.db?.execute(DROP_QUERY);
                    print(DROP_QUERY)
                    //create
                    for table in self.tables {
                        
                        if table.theClassName.caseInsensitiveCompare(drop) ==  ComparisonResult.orderedSame{
                            
                            var CREATE_TABLES : String = "";
                            CREATE_QUERY = BEGIN_TRAN
                            CREATE_TABLES += table.getCreateTableQuery()
                            CREATE_QUERY += CREATE_TABLES
                            CREATE_QUERY += "PRAGMA user_version = " + dbVersionStr + ";"
                            CREATE_QUERY += COMMIT_TRAN
                            
                            do {
                                _ = try sqlManager.db?.execute(CREATE_QUERY);
                                
                                print(CREATE_QUERY)
                            } catch let error as NSError  {
                                print("Tablolar oluşturulurken hata : \(error)")
                                return;
                            }
                            //DROP COLUMN ICIN
                            //CREATE TABLE END
                            break
                        }
                    }
                    
                  } catch let error as NSError  {
                    print("Tablolar drop olurken hata : \(error)")
                    return;
                 }
              }
            }
            // end drop operation
            }
         
            // COLUMN RELATION MEMORY TO DATA
            if ColumnRelationSqlable.removeAllRelationTableDataFromDb(sqlManager: sqlManager){
                ColumnRelationSqlable.insertColumnRelationsDataToDb(sqlManager: sqlManager)
            }
            
            
        }
        else
        {
             print("tabloların creati icin Pragma version girilen versiondan büyük olmalı : \(currentVersion)")
        }
    }
    
    
   
  
    private func hasTableByName(name : String )-> Bool{
        var hasFind : Bool = false
        if self.tables.count > 0 {
            for model in self.tables {
                if model.theClassName.caseInsensitiveCompare(name) ==  ComparisonResult.orderedSame{
                    hasFind = true
                    break;
                }
            }
        }
        return hasFind;
    }
    
    private func getTableForClassName(className : String) -> Sqlable? {
        if self.tables.count > 0 {
            for model in self.tables {
                if model.theClassName.caseInsensitiveCompare(className) ==  ComparisonResult.orderedSame{
                    return model
                }
            }
        }
        return nil;
    }
    
    
    internal func relationalSelectQuery<T:Sqlable & Decodable>(type: T.Type , mismatched : Bool = false, whereClause : String? = nil) ->  String {
        let clazzName = String(describing: T.self)
        let relation = relationalQuery(type: type)
        let clazz = getTableForClassName(className: clazzName)
        return clazz!.getRelationalSelectQuery(relationalQueryModel:relation, mismatched: mismatched,whereClause:whereClause)
    }
    //RELATIONAL DELETE
    public func relationalDelete<T:Sqlable>(instance : T) -> Bool {
        let relation = relationalQuery(type: T.self)
        let reflectedModel = instance.getReflectedModels()
        let parentId = SqlTypeConverter.getSwiftType(type: instance, fieldName: (relation.relation?.parentId)!, data: reflectedModel.filter{$0.propName == relation.relation?.parentId}.first?.value)
        var parentIdString = ""
        if !relation.hasRelation {
            return false
        }
        
        do {
            var listChildCountBefore : Any?
            var deleteQuery = "DELETE FROM " + (relation.child?.theClassName)!
            var deleteWhereQuery = " WHERE " + (relation.relation?.childId)! + " = "
            parentIdString = SqlTypeConverter.getSwiftType(type: instance, fieldName: (relation.relation?.parentId)!, data: parentId)
            deleteWhereQuery += parentIdString
            
            listChildCountBefore = try sqlManager.db?.scalar("select Count(*) FROM \((relation.child?.theClassName)!)" + deleteWhereQuery)
            if listChildCountBefore as! Int64 == 0{
                print("select Count(*) FROM \((relation.child?.theClassName)!)" + deleteWhereQuery + " no data for deleted count!")
                return false
            }
            _ = try sqlManager.db?.execute(deleteQuery + deleteWhereQuery)
            var listChildCountAfter : Any?
            listChildCountAfter = try sqlManager.db?.scalar("select Count(*) FROM \((relation.child?.theClassName)!)" + deleteWhereQuery)
            var isChildDeleteSuccess = false
            if listChildCountBefore as! Int64 == listChildCountAfter as! Int64{
                print(deleteQuery + deleteWhereQuery + " deletion failed")
            }else{
                isChildDeleteSuccess = true
            }
            if isChildDeleteSuccess{
                let deleteQuery = "DELETE FROM " + (relation.parent?.theClassName)!
                let deleteWhereQuery = " WHERE " + (relation.relation?.parentId)! + " = " + parentIdString
                let listParentCountBefore = try sqlManager.db?.scalar("select Count(*) FROM \((relation.parent?.theClassName)!)" + deleteWhereQuery)
                _ = try sqlManager.db?.execute(deleteQuery + deleteWhereQuery)
                let listParentCountAfter = try sqlManager.db?.scalar("select Count(*) FROM \((relation.parent?.theClassName)!)" + deleteWhereQuery)
                
                if listParentCountBefore as! Int64 == listParentCountAfter as! Int64{
                    print(deleteQuery + deleteWhereQuery + " deletion failed")
                    return false
                }else{
                   return true
                }
            }
            return false
            
        }
        catch  {
            print("insert yapılırken hata : \(error)")
            return false;
        }
            /*
         var hasWhereClause : Bool = false
            if !whereClause!.isEmpty{
                deleteQuery +=
                //try sqlManager.db?.execute(insertQuery)
                hasWhereClause = true
            }
            _ = try sqlManager.db?.execute(deleteQuery)
            
            var deletedCount : Int
            if hasWhereClause{
                deletedCount = (listByFilter(type: type, whereClause: whereClause)?.count)!
            }else{
                deletedCount = (list(type: type)?.count)!
            }
            return deletedCount == 0 ? true : false
            
        }
        var hasWhereClause : Bool
        var deleteWhereClauseQuery : String = ""
        if !whereClause!.isEmpty{
            deleteWhereClauseQuery += " WHERE " + whereClause!
            //try sqlManager.db?.execute(insertQuery)
            hasWhereClause = true
        }
        let firstChildDeleteStatus = self.delete(type: , whereClause: "")
        if clazzName ==  relation.parent?.theClassName{
            
        }else{
            
        }
        */
        return false
    }
    
    //RELATIONAL INSERT
    public func relationalInsert<T:Sqlable & Decodable>(data: T) -> Int {
        let clazzName = String(describing: T.self)
        let relation = relationalQuery(type: T.self)
        //let clazz = getTableForClassName(className: clazzName)
        if relation.hasRelation{
            if clazzName ==  relation.parent?.theClassName{
                //first ParentInsert
                var insertedCount = insert(data: data)
                var lastParentId : Any? 
                // get last inserted Parent id
                //sqlManager.db?.scalar("select last_insert_rowid()")
                if insertedCount > 0{
                    do{
                        lastParentId = try sqlManager.db?.scalar("select \(relation.relation!.parentId) FROM " + relation.relation!.parentTable + " ORDER BY \(relation.relation!.parentId) desc LIMIT 1")
                    }
                    catch{
                        return -1
                    }
                        let childModelProp = data.getReflectedModels().filter{$0.propName == relation.relation?.parentProp}
                        if childModelProp.count > 0{
                            //array mi
                            let childIsArray =  childModelProp.first?.type.localizedCaseInsensitiveContains("Array")
                            if childIsArray!{
                                let childArray = childModelProp.first?.value as! [Sqlable]
                                insertedCount = insertAllChildMembers(data:  childArray, relationPropName: (relation.relation?.childId)!, relationPropValue: lastParentId) + insertedCount
                            }else{
                                let reflectedChildValue = Reflector.reflect(from:childModelProp.first?.value).values.first as! Sqlable
                                insertedCount = insertChildMember(data:  reflectedChildValue, relationPropName: (relation.relation?.childId)!, relationPropValue: lastParentId) + insertedCount
                            }
                        }
                  return insertedCount
                }
            }else{
                //only Child Insert
                //child tabloda parent alan verilmiş mi, value var mı?
                var insertedCount = 0
                let childModelRelationProp = data.getReflectedModels().filter{$0.propName == relation.relation?.childId}
                if (String(describing: childModelRelationProp.first?.value).caseInsensitiveCompare("nil") ==  ComparisonResult.orderedSame){
                    //önce parent insert et sonra child'lar
                    var lastParentId : Any?
                 
                    let parentModelProp = data.getReflectedModels().filter{$0.propName == relation.relation?.childProp}
                    if parentModelProp.count > 0{
                    let reflectedParentValue = Reflector.reflect(from:parentModelProp.first!.value).values.first as! Sqlable
                     insertedCount = insertAny(data: reflectedParentValue)
                        do{
                            lastParentId = try sqlManager.db?.scalar("select \(relation.relation!.parentId) FROM " + relation.relation!.parentTable + " ORDER BY \(relation.relation!.parentId) desc LIMIT 1")
                            print(lastParentId)
                             insertedCount = insertChildMember(data:  data, relationPropName: (relation.relation?.childId)!, relationPropValue: lastParentId) + insertedCount
                        }
                        catch{
                            return -1
                        }
                    }
                    return insertedCount
                }else
                {
                   insertedCount = insertChildMember(data:  data, relationPropName: (relation.relation?.childId)!, relationPropValue: childModelRelationProp.first?.value) + insertedCount
                    return insertedCount
                }
            }
        }else{
            return -1
        }
        return -1
    }
    internal func relationalQuery<T:Sqlable & Decodable>(type: T.Type) -> RelationalQueryModel {
        let clazzName = String(describing: T.self)
        let clazz = getTableForClassName(className: clazzName)
        var relationFilter : [ColumnRelation] = []
        for relation in BaseDatabase.relations {
            if relation.parentTable.caseInsensitiveCompare(clazzName) == ComparisonResult.orderedSame || relation.relationalTable.caseInsensitiveCompare(clazzName) == ComparisonResult.orderedSame {
                relationFilter.append(relation)
                break
            }
        }
        let relationalQuery = RelationalQueryModel()
        if relationFilter.count > 0 {
            let relation = relationFilter.first!
            //let isParent = relation.isParentTable(tableName: clazzName)
            let parentTable = getTableForClassName(className: relation.parentTable)!
            let childTable = getTableForClassName(className: relation.relationalTable)!
            
            relationalQuery.hasRelation = true
            relationalQuery.child = childTable
            relationalQuery.parent = parentTable
            relationalQuery.relation = relation
            
            if clazzName == parentTable.theClassName{
                relationalQuery.left = parentTable
                relationalQuery.right = childTable
            }
            else{
                relationalQuery.left = childTable
                relationalQuery.right = parentTable
            }
            return relationalQuery
            
        }else{
            relationalQuery.hasRelation = false
            relationalQuery.parent = clazz
        }
        return relationalQuery
    }
    //RELATIONAL LIST QUERY
    public func relationalList<T:Sqlable & Decodable>(type : T.Type , mismatched : Bool = false) -> Array<T>?{
        let relation = relationalQuery(type: type)
        if !relation.hasRelation{
            return Array<T>()
        }
        let relationalSelectQueryString = self.relationalSelectQuery(type: type,mismatched:mismatched)
        print(relationalSelectQueryString)
        var list = Array<T>()
        let clazzName = String(describing: T.self)
        var isParentType : Bool = false
        if relation.parent?.theClassName == clazzName{
            isParentType = true
        }
        if hasTableByName(name: clazzName){
            //let clazz = getTableForClassName(className: clazzName)
            do {
                let stmt = try sqlManager.db!.prepare(relationalSelectQueryString)
                var relationParentObjectArray  = [RelationObject]()
                var relationChildObjectArray  = [RelationObject]()
                let parentInstance = getTableForClassName(className: (relation.relation?.parentTable)!)
                let childInstance = getTableForClassName(className: (relation.relation?.relationalTable)!)
                for row in stmt {
                    let relationParentObject = RelationObject()
                    let relationChildObject = RelationObject()
                    var parentRowValueArray : [String:String] = [:]
                    var childRowValueArray : [String:String] = [:]
        
                    for (index, name) in stmt.columnNames.enumerated() {
                        do{
                            print ("\(name)=\(row[index])")
                            let tableName = String(describing:name.split(separator: "_")[0])
                            let columnName = String(describing:name.split(separator: "_")[1])
                            if tableName == relation.parent?.theClassName{
                                let sqlValue = SqlTypeConverter.getSwiftType(type: parentInstance!, fieldName: columnName, data: row[index])
                                parentRowValueArray[columnName] = sqlValue.toJsonValue(type: parentInstance!, fieldName: columnName)
                                if relation.relation?.parentId == columnName{
                                    relationParentObject.parentValue = sqlValue
                                }
                                print("converted sql data : \(sqlValue)")
                            }else{
                                let sqlValue = SqlTypeConverter.getSwiftType(type: childInstance!, fieldName: columnName, data: row[index])
                                childRowValueArray[columnName] = sqlValue.toJsonValue(type: childInstance!, fieldName: columnName)
                                if relation.relation?.childId == columnName{
                                    relationChildObject.parentValue = sqlValue
                                }
                                print("converted sql data : \(sqlValue)")
                            }
                        } catch let error as NSError  {
                            print("cast edilirken hata : \(error)")
                            return nil;
                        }
                    }
                    relationParentObject.dictionary = parentRowValueArray
                    relationChildObject.dictionary = childRowValueArray
                    if !relationParentObjectArray.contains(where: { $0.parentValue == relationParentObject.parentValue}){
                            relationParentObjectArray.append(relationParentObject)
                    }
                    relationChildObjectArray.append(relationChildObject)
                }
                //GELEN TYPE RELATION CHILD MI?
                if isParentType{
                    for parent in relationParentObjectArray{
                        var childJson = ""
                        let childsList = relationChildObjectArray.filter{$0.parentValue == parent.parentValue}
                        switch relation.relation?.columnRelationType{
                        case .OneToOne? :
                            childJson = (childsList.first?.dictionary.jsonString)!
                        case .OneToMany?:
                            childJson = childsList.jsonStringArray
                        case .None?:
                            break
                        case .ManyToMany?:
                            childJson = childsList.jsonStringArray
                            break
                        case .none:
                            break
                        }
                        print(childsList.jsonStringArray)
                        let parentJson =  parent.dictionary.jsonStringAddChild(name: (relation.relation?.parentProp)!, value: childJson)
                        print(parentJson)
                        let obj = try JSONDecoder().decode(T.self, from:parentJson.data(using: .utf8)!)
                        list.append(obj)
                    }
                }
                else{
                    for child in relationChildObjectArray{
                        var parentJson = ""
                        if child.parentValue != SqlTypeConverter.sqlNull{
                            let parentList = relationParentObjectArray.filter{$0.parentValue == child.parentValue}
                            switch relation.relation?.columnRelationType{
                            case .OneToOne? :
                                parentJson = (parentList.first?.dictionary.jsonString)!
                            case .OneToMany?:
                                parentJson = (parentList.first?.dictionary.jsonString)!
                            case .None?:
                                break
                            case .ManyToMany?:
                                parentJson = parentList.jsonStringArray
                                break
                            case .none:
                                break
                            }
                            print(parentList.jsonStringArray)
                        }
                        let childJson =  child.dictionary.jsonStringAddChild(name: (relation.relation?.childProp)!, value: parentJson)
                        print(childJson)
                        let obj = try JSONDecoder().decode(T.self, from:childJson.data(using: .utf8)!)
                        list.append(obj)
                    }
                }
             
                return list;
            } catch let error as NSError  {
                print("Liste çekilirken hata : \(error)")
                return list;
            }
        }
        return list
    }
    //RELATIONAL LIST QUERY
    public func relationalListByFilter<T:Sqlable & Decodable>(type : T.Type , mismatched : Bool = false, whereClause: String) -> Array<T>?{
        let relation = relationalQuery(type: type)
        if !relation.hasRelation{
            return Array<T>()
        }
        let relationalSelectQueryString = self.relationalSelectQuery(type: type,mismatched:mismatched,whereClause:whereClause)
        print(relationalSelectQueryString)
        var list = Array<T>()
        let clazzName = String(describing: T.self)
        var isParentType : Bool = false
        if relation.parent?.theClassName == clazzName{
            isParentType = true
        }
        if hasTableByName(name: clazzName){
            //let clazz = getTableForClassName(className: clazzName)
            do {
                let stmt = try sqlManager.db!.prepare(relationalSelectQueryString)
                var relationParentObjectArray  = [RelationObject]()
                var relationChildObjectArray  = [RelationObject]()
                let parentInstance = getTableForClassName(className: (relation.relation?.parentTable)!)
                let childInstance = getTableForClassName(className: (relation.relation?.relationalTable)!)
                for row in stmt {
                    let relationParentObject = RelationObject()
                    let relationChildObject = RelationObject()
                    var parentRowValueArray : [String:String] = [:]
                    var childRowValueArray : [String:String] = [:]
                    
                    for (index, name) in stmt.columnNames.enumerated() {
                        do{
                            print ("\(name)=\(row[index])")
                            let tableName = String(describing:name.split(separator: "_")[0])
                            let columnName = String(describing:name.split(separator: "_")[1])
                            if tableName == relation.parent?.theClassName{
                                let sqlValue = SqlTypeConverter.getSwiftType(type: parentInstance!, fieldName: columnName, data: row[index])
                                parentRowValueArray[columnName] = sqlValue.toJsonValue(type: parentInstance!, fieldName: columnName)
                                if relation.relation?.parentId == columnName{
                                    relationParentObject.parentValue = sqlValue
                                }
                                print("converted sql data : \(sqlValue)")
                            }else{
                                let sqlValue = SqlTypeConverter.getSwiftType(type: childInstance!, fieldName: columnName, data: row[index])
                                childRowValueArray[columnName] = sqlValue.toJsonValue(type: childInstance!, fieldName: columnName)
                                if relation.relation?.childId == columnName{
                                    relationChildObject.parentValue = sqlValue
                                }
                                print("converted sql data : \(sqlValue)")
                            }
                        } catch let error as NSError  {
                            print("cast edilirken hata : \(error)")
                            return nil;
                        }
                    }
                    relationParentObject.dictionary = parentRowValueArray
                    relationChildObject.dictionary = childRowValueArray
                    if !relationParentObjectArray.contains(where: { $0.parentValue == relationParentObject.parentValue}){
                        relationParentObjectArray.append(relationParentObject)
                    }
                    relationChildObjectArray.append(relationChildObject)
                }
                //GELEN TYPE RELATION CHILD MI?
                if isParentType{
                    for parent in relationParentObjectArray{
                        var childJson = ""
                        let childsList = relationChildObjectArray.filter{$0.parentValue == parent.parentValue}
                        switch relation.relation?.columnRelationType{
                        case .OneToOne? :
                            childJson = (childsList.first?.dictionary.jsonString)!
                        case .OneToMany?:
                            childJson = childsList.jsonStringArray
                        case .None?:
                            break
                        case .ManyToMany?:
                            childJson = childsList.jsonStringArray
                            break
                        case .none:
                            break
                        }
                        print(childsList.jsonStringArray)
                        let parentJson =  parent.dictionary.jsonStringAddChild(name: (relation.relation?.parentProp)!, value: childJson)
                        print(parentJson)
                        let obj = try JSONDecoder().decode(T.self, from:parentJson.data(using: .utf8)!)
                        list.append(obj)
                    }
                }
                else{
                    for child in relationChildObjectArray{
                        var parentJson = ""
                        if child.parentValue != SqlTypeConverter.sqlNull{
                            let parentList = relationParentObjectArray.filter{$0.parentValue == child.parentValue}
                            switch relation.relation?.columnRelationType{
                            case .OneToOne? :
                                parentJson = (parentList.first?.dictionary.jsonString)!
                            case .OneToMany?:
                                parentJson = (parentList.first?.dictionary.jsonString)!
                            case .None?:
                                break
                            case .ManyToMany?:
                                parentJson = parentList.jsonStringArray
                                break
                            case .none:
                                break
                            }
                            print(parentList.jsonStringArray)
                        }
                        let childJson =  child.dictionary.jsonStringAddChild(name: (relation.relation?.childProp)!, value: parentJson)
                        print(childJson)
                        let obj = try JSONDecoder().decode(T.self, from:childJson.data(using: .utf8)!)
                        list.append(obj)
                    }
                }
                
                return list;
            } catch let error as NSError  {
                print("Liste çekilirken hata : \(error)")
                return list;
            }
        }
        return list
    }
    public func list<T:Sqlable & Decodable>(type : T.Type) -> Array<T>?{
        var list = Array<T>()
        let clazzName = String(describing: T.self);
        if hasTableByName(name: clazzName){
            let clazz = getTableForClassName(className: clazzName)
            do {
                let selectQuery = clazz!.getSelectQuery()
                let stmt = try sqlManager.db!.prepare(selectQuery)
                for row in stmt {
                    let realType = T.self
                    var instance = realType.init()
                    var rowValueArray : [String:String] = [:]
                    for (index, name) in stmt.columnNames.enumerated() {
                        do{
                            print ("\(name)=\(row[index])")
                            let sqlValue = SqlTypeConverter.getSwiftType(type: instance, fieldName: name, data: row[index])
                            rowValueArray[name] = sqlValue.toJsonValue(type: instance, fieldName: name)
                            print("converted sql data : \(sqlValue)")
                        } catch let error as NSError  {
                            print("cast edilirken hata : \(error)")
                            return nil;
                        }
                    }
                    let obj = try JSONDecoder().decode(T.self, from:rowValueArray.jsonString.data(using: .utf8)!)
                    list.append(obj)
                }
                return list;
            } catch let error as NSError  {
                print("Liste çekilirken hata : \(error)")
                return list;
            }
        }
        return list
    }
    public func listByFilter<T:Sqlable & Decodable>(type : T.Type, whereClause: String) -> Array<T>?{
        var list = Array<T>()
        let clazzName = String(describing: T.self);
        if hasTableByName(name: clazzName){
            let clazz = getTableForClassName(className: clazzName)
            do {
                let whereClauseQuery = clazz!.getSelectQuery() + " WHERE " + whereClause
                let stmt = try sqlManager.db!.prepare(whereClauseQuery) 
                for row in stmt {
                    let realType = T.self
                    var instance = realType.init()
                    var rowValueArray : [String:String] = [:]
                    for (index, name) in stmt.columnNames.enumerated() {
                        do{
                            print ("\(name)=\(row[index])")
                            let sqlValue = SqlTypeConverter.getSwiftType(type: instance, fieldName: name, data: row[index])
                            rowValueArray[name] = sqlValue.toJsonValue(type: instance, fieldName: name)
                            print("converted sql data : \(sqlValue)")
                        } catch let error as NSError  {
                            print("cast edilirken hata : \(error)")
                            return nil;
                        }
                    }
                    let obj = try JSONDecoder().decode(T.self, from:rowValueArray.jsonString.data(using: .utf8)!)
                    list.append(obj);
                }
                return list;
            } catch let error as NSError  {
                print("Liste çekilirken hata : \(error)")
                return list;
            }
        }
        return list
    }
    
    public func dictionary<T:Sqlable & Decodable>(type : T.Type) -> Array<[String:String?]>?{
        var dictionary = Array<[String:String?]>()
        let clazzName = String(describing: T.self);
        if hasTableByName(name: clazzName){
            let clazz = getTableForClassName(className: clazzName)
            do {
                let selectQuery = clazz!.getSelectQuery()
                let stmt = try sqlManager.db!.prepare(selectQuery)
                for row in stmt {
                    let realType = T.self
                    var instance = realType.init()
                    var rowValueArray : [String:String?] = [:]
                    for (index, name) in stmt.columnNames.enumerated() {
                        do{
                            print ("\(name)=\(row[index])")
                            let sqlValue = SqlTypeConverter.getSwiftType(type: instance, fieldName: name, data: row[index])
                            rowValueArray[name] = sqlValue.toDictionaryValue(type: instance, fieldName: name)
                            print("converted sql data : \(sqlValue)")
                        } catch let error as NSError  {
                            print("cast edilirken hata : \(error)")
                            return nil;
                        }
                    }
                    dictionary.append(rowValueArray)
                }
                return dictionary;
            } catch let error as NSError  {
                print("Liste çekilirken hata : \(error)")
                return dictionary;
            }
        }
        return dictionary
    }
    
    public func dictionaryByFilter<T:Sqlable & Decodable>(type : T.Type, whereClause: String) -> Array<[String:String?]>?{
        var dictionary = Array<[String:String?]>()
        let clazzName = String(describing: T.self);
        if hasTableByName(name: clazzName){
            let clazz = getTableForClassName(className: clazzName)
            do {
                let selectQuery = clazz!.getSelectQuery() + " WHERE " + whereClause
                let stmt = try sqlManager.db!.prepare(selectQuery)
                for row in stmt {
                    let realType = T.self
                    var instance = realType.init()
                    var rowValueArray : [String:String?] = [:]
                    for (index, name) in stmt.columnNames.enumerated() {
                        do{
                            print ("\(name)=\(row[index])")
                            let sqlValue = SqlTypeConverter.getSwiftType(type: instance, fieldName: name, data: row[index])
                            rowValueArray[name] = sqlValue.toDictionaryValue(type: instance, fieldName: name)
                            print("converted sql data : \(sqlValue)")
                        } catch let error as NSError  {
                            print("cast edilirken hata : \(error)")
                            return nil;
                        }
                    }
                    dictionary.append(rowValueArray)
                }
                return dictionary;
            } catch let error as NSError  {
                print("Liste çekilirken hata : \(error)")
                return dictionary;
            }
        }
        return dictionary
    }
    
  /*
    public func listFilter<T:SqlModel>(type : T.Type, whereClause: String) -> Array<T>?{
        var list = Array<T>()
        let clazzName = String(describing: T.self);
        if hasTableByName(name: clazzName){
            let clazz = getTableForClassName(className: clazzName)
            do {
                let selectQuery = clazz.getSelectQuery() + " WHERE " + whereClause
                let stmt = try sqlManager.db!.prepare(selectQuery)
                
                for row in stmt {
                    let realType = T.self
                    var instance = type.init()
                    for (index, name) in stmt.columnNames.enumerated() {
                        do{
                            print ("\(name)=\(row[index]!)")
                            instance.setValue(row[index], forKey: name)
                        } catch let error as NSError  {
                            print("cast edilirken hata : \(error)")
                            return nil;
                        }
                    }
                    list.append(instance);
                }
                return list;
            } catch let error as NSError  {
                print("Liste çekilirken hata : \(error)")
                return list;
            }
        }
        return list
    }
    */
    
    public func insertAll<T:Sqlable>(data:Array<T>) -> Int {
        var rows : Int = 0
        let clazzName = String(describing: T.self);
        if hasTableByName(name: clazzName){
                for instance in data {
                    do {
                        let insertQuery = instance.getInsertQuery(data: instance)
                        _ = try sqlManager.db?.execute(insertQuery)
                        rows += 1
                    } catch let error as NSError  {
                        print("insert yapılırken hata : \(error)")
                        return -1;
                    }
                }
    
        }
        return rows
    }
    
    internal func insertChildMember(data : Any, relationPropName : String, relationPropValue:Any) -> Int {
        var rows : Int = 0
        var childArray = data as! [Sqlable]
        let clazzName = String(describing: childArray.first);
        //if hasTableByName(name: clazzName){
        for instance in childArray {
            do {
                let insertQuery = instance.getInsertQueryWithParentId(data: instance,relationPropName:relationPropName, relationPropValue : relationPropValue)
                _ = try sqlManager.db?.execute(insertQuery)
                rows += 1
            } catch let error as NSError  {
                print("insert yapılırken hata : \(error)")
                return -1;
            }
        }
        
        //}
        return rows
    }
    
    internal func insertAllChildMembers(data : Any, relationPropName : String, relationPropValue:Any) -> Int {
        var rows : Int = 0
        var childArray = data as! [Sqlable]
        let clazzName = String(describing: childArray.first);
        //if hasTableByName(name: clazzName){
            for instance in childArray {
                do {
                    let insertQuery = instance.getInsertQueryWithParentId(data: instance,relationPropName:relationPropName, relationPropValue : relationPropValue)
                    _ = try sqlManager.db?.execute(insertQuery)
                    rows += 1
                } catch let error as NSError  {
                    print("insert yapılırken hata : \(error)")
                    return -1;
                }
            }
            
        //}
        return rows
    }
    internal func insertAny(data:Any) -> Int {
        var rows : Int = 0
        var table : Sqlable? = data as? Sqlable
        let clazzName = String(describing: table!.theClassName);
        if hasTableByName(name: clazzName){
            do {
                let insertQuery = table!.getInsertQuery(data: table!)
                _ = try sqlManager.db?.execute(insertQuery)
                rows += 1
            } catch let error as NSError  {
                print("insert yapılırken hata : \(error)")
                return -1;
            }
        }
        return rows
    }
    public func insert<T:Sqlable>(data:T) -> Int {
        var rows : Int = 0
        let clazzName = String(describing: T.self);
        if hasTableByName(name: clazzName){
            do {
                let insertQuery = data.getInsertQuery(data: data)
                _ = try sqlManager.db?.execute(insertQuery)
                rows += 1
            } catch let error as NSError  {
                print("insert yapılırken hata : \(error)")
                return -1;
            }
        }
        return rows
    }
    internal func insertChildMember<T:Sqlable>(data:T, relationPropName : String, relationPropValue:Any) -> Int {
        var rows : Int = 0
        let clazzName = String(describing: T.self);
        if hasTableByName(name: clazzName){
            do {
                let insertQuery = data.getInsertQueryWithParentId(data: data,relationPropName:relationPropName, relationPropValue : relationPropValue)
                _ = try sqlManager.db?.execute(insertQuery)
                rows += 1
            } catch let error as NSError  {
                print("insert yapılırken hata : \(error)")
                return -1;
            }
        }
        return rows
    }
    
    public func update<T:Sqlable>(instance:T, whereClause: String? = nil) -> Int {
        var rows : Int = 0
        let clazzName = String(describing: T.self);
        var updateQuery : String
        if hasTableByName(name: clazzName){
            do {
                if String(describing: whereClause).caseInsensitiveCompare("nil") == ComparisonResult.orderedSame{
                   updateQuery = instance.getUpdateQuery(data:  instance)
                }
                else{
                    updateQuery = instance.getUpdateQuery(data:  instance) + " WHERE " + whereClause!
                }
                _ = try sqlManager.db?.execute(updateQuery)
                rows += 1
            } catch let error as NSError  {
                print("insert yapılırken hata : \(error)")
                return -1;
            }
        }
        return rows
    }
    public func delete<T:Sqlable>(type : T.Type, whereClause: String = "") -> Bool {
        let clazzName = String(describing: T.self);
        if hasTableByName(name: clazzName){
            do {
                var hasWhereClause : Bool = false
                var deleteQuery = "DELETE FROM " + clazzName
                if !whereClause.isEmpty{
                    deleteQuery += " WHERE " + whereClause
                    //try sqlManager.db?.execute(insertQuery)
                    hasWhereClause = true
                }
                _ = try sqlManager.db?.execute(deleteQuery)
                
                var deletedCount : Int
                if hasWhereClause{
                    deletedCount = (listByFilter(type: type, whereClause: whereClause)?.count)!
                }else{
                    deletedCount = (list(type: type)?.count)!
                }
                return deletedCount == 0 ? true : false
            
            } catch  {
                print("insert yapılırken hata : \(error)")
                return false;
            }
        }else{
            return false;
        }
    }
    func getDbVersion() -> Int64 {
        var pragmaVersion : Int64 = 0
        do {
            let pragma = try sqlManager.db!.prepare("PRAGMA user_version;")
            for row in pragma {
                for (index, name) in pragma.columnNames.enumerated() {
                    do{
                        print ("\(name)=\(row[index]!)")
                         pragmaVersion = row[index] as! Int64
                        return pragmaVersion
                    } catch let error as NSError  {
                        print("cast edilirken hata : \(error)")
                        return 0
                    }
                }
            }
            return pragmaVersion
        }
        catch let error as NSError  {
            print("PRAGMA çekilirken hata : \(error)")
            return 0;
        }
    }
    //PRAGMA table_info('table_name')
    
    func getColumnsOfTable(name : String) -> [String] {
        var columns = [String]()
        do {
            let query = "PRAGMA table_info('" + name + "')"
            let tables = try sqlManager.db!.prepare(query)
            for row in tables {
                for (index, name) in tables.columnNames.enumerated() {
                    if name.caseInsensitiveCompare("name") ==  ComparisonResult.orderedSame{
                        columns.append(String(describing:row[index].unsafelyUnwrapped))
                    }
                }
            }
        }
        catch let error as NSError  {
            print("currentTables çekilirken hata : \(error)")
            return columns;
        }
        return columns
    }
    func getCurrentTables() -> Array<TableModel> {
        var arrays = Array<TableModel>()
        do {
            let tables = try sqlManager.db!.prepare("SELECT * FROM sqlite_master WHERE type='table'")
            for row in tables {
                var tableModel = TableModel()
                for (index, name) in tables.columnNames.enumerated() {
                    if name.caseInsensitiveCompare(TableModel.sql_key) ==  ComparisonResult.orderedSame{
                        tableModel.sql = String(describing:row[index].unsafelyUnwrapped)
                    }
                    else if name.caseInsensitiveCompare(TableModel.tbl_name_key) ==  ComparisonResult.orderedSame{
                        tableModel.tableName =  String(describing:row[index].unsafelyUnwrapped)
                    }
                }
                arrays.append(tableModel)
            }        
        }
            catch let error as NSError  {
            print("currentTables çekilirken hata : \(error)")
            return arrays;
       }
        return arrays
    }
    
   
}

/*
 public func delete<T: Sqlable>(type : T.Type) -> Bool {
 let clazzName = String(describing: T.self);
 if hasTableByName(name: clazzName){
 let deletedTable = Table(clazzName)
 do {
 let a = deletedTable.delete().asSQL()
 if try (sqlManager.db?.run(deletedTable.delete()))! > 0 {
 return true
 } else {
 return false
 }
 } catch  {
 print("delete yapılırken hata : \(error)")
 return false;
 }
 }else
 {
 return false
 }
 }
 */

/*
 /*
 do {
 var testModel = TestSqlModel();
 
 let createQueries = "BEGIN TRANSACTION;" +
 testModel.getCreateTableQuery()
 +
 "COMMIT TRANSACTION;";
 let  createStmnt = try sqlManager.db?.execute(createQueries);
 
 
 let stmt = try sqlManager.db?.prepare("INSERT INTO TestSqlModel (name,age) VALUES (?,?)")
 
 let elemans:Array<Dictionary<String,String>> = [["name":"Kamil", "age":"30"], ["Umut":"Joe", "age":"33"]]
 
 for eleman in elemans {
 var index = 0;
 for (key,value) in eleman {
 if index == 0
 {
 try stmt?.run(value,33)
 }
 print("\(key): \(value)")
 index += 1;
 }
 }
 
 */
 /*
 var elemans : [[String:String]] = [["umt@icloud.com" : "33"]];
 elemans.append(["betty@icloud.com" : "30"])
 elemans.forEach { print($0) }
 */
 // for mem in elemans {
 
 
 //try stmt?.run(email,age)
 // }
 
 
 
 
 /*
 for row in try sqlManager.db!.prepare("SELECT name, age FROM TestSqlModel") {
 print("name: \(row[0]), age: \(row[1])")
 // id: Optional(2), email: Optional("betty@icloud.com")
 // id: Optional(3), email: Optional("cathy@icloud.com")
 }
 */
 */
 
