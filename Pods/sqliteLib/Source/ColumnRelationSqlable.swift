//
//  ColumnRelationSqlable.swift
//  SqliteLib
//
//  Created by Umut BOZ on 14.09.2018.
//  Copyright © 2018 Kocsistem. All rights reserved.
//

import Foundation

internal class ColumnRelationSqlable{
    
    internal static func getColumnRelationsFromDb(sqlManager :  SqliteManager) -> [ColumnRelation]{
        var relations = [ColumnRelation]()
        do {
            
            let stmt = try sqlManager.db!.prepare("select \(ColumnRelation.ColumnRelationCodingKeys.parentTable.stringValue),\(ColumnRelation.ColumnRelationCodingKeys.parentId.stringValue), \(ColumnRelation.ColumnRelationCodingKeys.relationalTable.stringValue), \(ColumnRelation.ColumnRelationCodingKeys.childId.stringValue), \(ColumnRelation.ColumnRelationCodingKeys.columnRelationType.stringValue), \(ColumnRelation.ColumnRelationCodingKeys.parentProp.stringValue), \(ColumnRelation.ColumnRelationCodingKeys.childProp.stringValue) from ColumnRelation")
            for row in stmt {
                //init(parentId : String , relationalTableName: String, childId : String, relationType : ColumnRelationType, parentProperty : String, childProperty : String ) {
                var rowValueArray : [String:String] = [:]
                for (index, name) in stmt.columnNames.enumerated() {
                    do{
                        print ("\(name)=\(String(describing: row[index]))")
                        if name == ColumnRelation.ColumnRelationCodingKeys.parentTable.stringValue{
                            rowValueArray[ColumnRelation.ColumnRelationCodingKeys.parentTable.stringValue] = SqlTypeConverter.getSwiftType(data: row[index])
                        }
                        else if name == ColumnRelation.ColumnRelationCodingKeys.parentId.stringValue{
                            rowValueArray[ColumnRelation.ColumnRelationCodingKeys.parentId.stringValue] = SqlTypeConverter.getSwiftType(data: row[index])
                        }else if name == ColumnRelation.ColumnRelationCodingKeys.relationalTable.stringValue{
                            rowValueArray[ColumnRelation.ColumnRelationCodingKeys.relationalTable.stringValue] = SqlTypeConverter.getSwiftType(data: row[index])
                        }
                        else if name == ColumnRelation.ColumnRelationCodingKeys.childId.stringValue{
                            rowValueArray[ColumnRelation.ColumnRelationCodingKeys.childId.stringValue] = SqlTypeConverter.getSwiftType(data: row[index])
                        }
                        else if name == ColumnRelation.ColumnRelationCodingKeys.columnRelationType.stringValue{
                            rowValueArray[ColumnRelation.ColumnRelationCodingKeys.columnRelationType.stringValue] = SqlTypeConverter.getSwiftType(data: row[index])
                        }
                        else if name == ColumnRelation.ColumnRelationCodingKeys.parentProp.stringValue{
                            rowValueArray[ColumnRelation.ColumnRelationCodingKeys.parentProp.stringValue] = SqlTypeConverter.getSwiftType(data: row[index])
                        }
                        else if name == ColumnRelation.ColumnRelationCodingKeys.childProp.stringValue{
                            rowValueArray[ColumnRelation.ColumnRelationCodingKeys.childProp.stringValue] = SqlTypeConverter.getSwiftType(data: row[index])
                        }
                        else if name == ColumnRelation.ColumnRelationCodingKeys.columnRelationType.stringValue{
                            rowValueArray[ColumnRelation.ColumnRelationCodingKeys.columnRelationType.stringValue] = SqlTypeConverter.getSwiftType(data: row[index])
                        }
                    } catch let error as NSError  {
                        print("cast edilirken hata : \(error)")
                        return relations;
                    }
                }
                let columnRelationTypeValue = rowValueArray[ColumnRelation.ColumnRelationCodingKeys.columnRelationType.stringValue]!
                var columnRelationType = ColumnRelationType.None
                if  columnRelationTypeValue.description.localizedCaseInsensitiveContains("OneToOne"){
                    columnRelationType = ColumnRelationType.OneToOne
                }else if columnRelationTypeValue.description.localizedCaseInsensitiveContains("OneToMany") {
                    columnRelationType = ColumnRelationType.OneToMany
                }
                else if columnRelationTypeValue.description.localizedCaseInsensitiveContains("ManyToMany") {
                    columnRelationType = ColumnRelationType.ManyToMany
                }
                let columnRelation = ColumnRelation(parentId: rowValueArray[ColumnRelation.ColumnRelationCodingKeys.parentId.stringValue]!, relationalTableName: rowValueArray[ColumnRelation.ColumnRelationCodingKeys.relationalTable.stringValue]!, childId: rowValueArray[ColumnRelation.ColumnRelationCodingKeys.childId.stringValue]! , relationType: columnRelationType, parentProperty: rowValueArray[ColumnRelation.ColumnRelationCodingKeys.parentProp.stringValue]!, childProperty: rowValueArray[ColumnRelation.ColumnRelationCodingKeys.childProp.stringValue]!)
                columnRelation.parentTable = rowValueArray[ColumnRelation.ColumnRelationCodingKeys.parentTable.stringValue]!
                relations.append(columnRelation)
            }
        } catch let error as NSError {
            print("getColumnRelations edilirken hata : \(error)")
            return relations
        }
        return relations
        
    }
    
    internal static func insertColumnRelationsDataToDb(sqlManager :  SqliteManager) -> Void {
        var relations = BaseDatabase.relations
        if relations.count > 0{
            let BEGIN_TRAN : String = "BEGIN TRANSACTION;"
            let COMMIT_TRAN : String = "COMMIT TRANSACTION;"
            for relation in relations{
                do {
            
                    let parentTableValue = SqlTypeConverter.getSwiftType(data: relation.parentTable)
                    let parentIdValue = SqlTypeConverter.getSwiftType(data: relation.parentId)
                    let relationalTableValue = SqlTypeConverter.getSwiftType(data: relation.relationalTable)
                    let childIdValue = SqlTypeConverter.getSwiftType(data: relation.childId)
                    let parentPropValue = SqlTypeConverter.getSwiftType(data: relation.parentProp)
                    let childPropValue = SqlTypeConverter.getSwiftType(data :relation.childProp)
                    let columnRelationTypeValue = SqlTypeConverter.getSwiftType(data : String.init(describing:relation.columnRelationType))
                    
                    var relationInsertQueryScript = ""
                    relationInsertQueryScript   += BEGIN_TRAN
                    relationInsertQueryScript += "INSERT INTO ColumnRelation (\(ColumnRelation.ColumnRelationCodingKeys.parentTable.stringValue),\(ColumnRelation.ColumnRelationCodingKeys.parentId.stringValue),\(ColumnRelation.ColumnRelationCodingKeys.relationalTable.stringValue),\(ColumnRelation.ColumnRelationCodingKeys.childId.stringValue), \(ColumnRelation.ColumnRelationCodingKeys.parentProp.stringValue),\(ColumnRelation.ColumnRelationCodingKeys.childProp.stringValue), \(ColumnRelation.ColumnRelationCodingKeys.columnRelationType.stringValue)) VALUES ('\(parentTableValue)','\(parentIdValue)', '\(relationalTableValue)', '\(childIdValue)', '\(parentPropValue)','\(childPropValue)', '\(String.init(describing:columnRelationTypeValue))');"
                    relationInsertQueryScript += COMMIT_TRAN
                    _ = try sqlManager.db?.execute(relationInsertQueryScript)
                } catch let error as NSError  {
                    print("Column Relation tablosu insert hata : \(error)")
                    return;
                }
            }
        }
    }
    
    internal static func getColumnRelationsFromInMemory(tables : Array<Sqlable>) -> [ColumnRelation]{
        var relations = [ColumnRelation]()
        for table in tables{
            let reflection = Reflector.reflect(from:table)
            let values = reflection.values
            let types = reflection.types
            for (i,field) in types.enumerated(){
                if field.localizedCaseInsensitiveContains("class<ColumnRelation>") || field.localizedCaseInsensitiveContains("custom<ColumnRelation>"){
                    let relation = values[i] as! ColumnRelation
                    relation.parentTable = table.theClassName
                    relations.append(relation)
                }
            }
        }
        return relations
        
    }
    
    
    /* parentTable : String,parentId : String,relationalTable : String,childId : String,parentProp : String,childProp : String */
    internal static func getCreateRelationTableQuery() -> String{
        let createRelatioTableQuery = "CREATE TABLE ColumnRelation (id INTEGER PRIMARY KEY AUTOINCREMENT, \(ColumnRelation.ColumnRelationCodingKeys.columnRelationType.stringValue) TEXT, \(ColumnRelation.ColumnRelationCodingKeys.parentTable.stringValue) TEXT, \(ColumnRelation.ColumnRelationCodingKeys.parentId.stringValue) TEXT,  \(ColumnRelation.ColumnRelationCodingKeys.relationalTable.stringValue) TEXT,  \(ColumnRelation.ColumnRelationCodingKeys.childId.stringValue) TEXT,  \(ColumnRelation.ColumnRelationCodingKeys.parentProp.stringValue) TEXT,  \(ColumnRelation.ColumnRelationCodingKeys.childProp.stringValue) TEXT);"
        return createRelatioTableQuery
    }
    
    
    internal static  func removeAllRelationTableDataFromDb(sqlManager :  SqliteManager) -> Bool{
        do {
            var deleteQuery = ""
            let BEGIN_TRAN : String = "BEGIN TRANSACTION;"
            let COMMIT_TRAN : String = "COMMIT TRANSACTION;"
            
            deleteQuery += BEGIN_TRAN
            deleteQuery += "DELETE FROM ColumnRelation;"
            deleteQuery += COMMIT_TRAN
            _ = try sqlManager.db?.execute(deleteQuery)
            var listCount : Any?
            listCount = try sqlManager.db?.scalar("select Count(*) FROM ColumnRelation")
            return listCount as! Int64 == 0 ? true : false
            
        } catch  {
            print("insert yapılırken hata : \(error)")
            return false;
        }
    }
}
