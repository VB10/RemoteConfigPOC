//
//  Sqlable.swift
//  SqliteLib
//
//  Created by Umut BOZ on 05/06/2018.
//  Copyright © 2018 Kocsistem. All rights reserved.
//

import Foundation


public protocol Sqlable: Codable{
    
    init()
   // init(from decoder: Decoder)
    
    
    
}

/* add PRIMARY KEY UNIQUE */
public extension Sqlable
{
   
    public func serializable() -> Data?{
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
    public  func getPropertiesForSelect()-> [String:String] {
        var propArray = [String:String]()
        let reflection = Reflector.reflect(from:self)
        let names = reflection.names
        let values = reflection.values
        let types = reflection.types
        print(names)
        print(values)
        print(types)
        var index = 0
        for (name) in names {
            if types[index].localizedCaseInsensitiveContains("class<ColumnConstraint>"){
                index = index + 1
                continue
            }
            propArray[name] = types[index]
            index = index + 1
        }
        return propArray
    }
    
    
   public func getCreateTableQuery() -> String {
        var query = "CREATE TABLE " + theClassName + " ( "
        var index = 0;
        let properties = getReflectedModels()
        if properties.count>0{
            for (i, prop) in properties.enumerated(){
                if prop.noneUseTableCreationProperty(){
                    continue
                }
                let constraintOutput = (prop.constraints.count > 0  ? SqlTypeConverter.getConstraintString(constraint:prop.constraints.first!) : "")
                let nullString = (prop.constraints.count > 0  ? "" : " NULL ")
                if index > 0 {
                    query += " , " +  prop.propName  + " " + SqlTypeConverter.getSqlType(type:prop.type) + constraintOutput + nullString
                }else
                {
                    query += prop.propName + " " + SqlTypeConverter.getSqlType(type:prop.type) + constraintOutput + nullString
                }
                index += 1;
            }
            query += ");"
        }
        print(query)
        return query;
    }
    
    public func getUpdateQuery<T: Sqlable>(data: T) -> String {
        ////// UPDATE "users" SET "email" = 'alice@me.com' WHERE ("id" = 1)
        var query = "UPDATE " + theClassName + " SET "
        var index = 0;
        let realType = T.self
        var instance = realType.init()
        let instanceProps = instance.getReflectedSelectableModel().filter { $0.constraints.count > 0 }
        let properties = data.getReflectedSelectableModel()
        
        for prop in instanceProps{
            let tempProp = properties.filter{ $0.propName == prop.propName }
            if tempProp.count > 0{
                tempProp.first!.constraints = prop.constraints
            }
        }
        if properties.count>0{
            for (i, prop) in properties.enumerated(){
                if prop.isContraintType(){
                    continue
                }
                if prop.constraints.count > 0 &&  prop.constraints.first!.isAutoIncrement{
                    continue
                }
                var val = SwiftTypeConverter.getStringByAnyTypeForSql(data: prop.value) as! String
                if !(String(describing: val).localizedCaseInsensitiveContains(SqlTypeConverter.sqlNull)){
                    if val.contains("\'"){
                        val = val.replacingOccurrences(of:  "\'", with: "''")
                    }
                    val = "'" + val + "'"
                }else
                {
                    val = "null"
                }
                if index > 0{
                    query += " , " +  prop.propName +  " = " + val
                }else{
                    query +=  prop.propName +  " = " + val
                }
                index += 1
            }
        }
        print(query)
        return query;
    }
    public func getSelectQuery() -> String {
        var query = "SELECT "
        let properties = getReflectedSelectableModel()
        for (i,model) in properties.enumerated(){
            if i > 0{
                query += " , " + model.propName
            }
            else{
                query +=  model.propName
            }
        }
        query += " " + "FROM" + " " + theClassName
        return query
    }
    public func getRelationalSelectQuery(relationalQueryModel:RelationalQueryModel , mismatched : Bool = false,whereClause:String? = nil) ->String{
        var JOIN_TYPE : String  = "INNER "
        if mismatched{
            JOIN_TYPE = "LEFT OUTER "
        }
        
        let relation = relationalQueryModel.relation!
        let child = relationalQueryModel.child!
        let parent = relationalQueryModel.parent!
        let parentReflectedModel = parent.getReflectedModels()
        let childReflectedModel = child.getReflectedModels()
        let plusModels = parentReflectedModel + childReflectedModel
        var query = "SELECT "
        var index : Int  = 0
        for (i,model) in plusModels.enumerated(){
            if model.noneUseTableCreationProperty(){
                continue
            }
            if index > 0{
                query += " , " + model.className + "." + model.propName + " AS " + model.className + "_" + model.propName
            }
            else{
                query += model.className + "." + model.propName + " AS " + model.className + "_" + model.propName
            }
            index = index + 1
        }
        query += " " + "FROM" + " " + relationalQueryModel.left!.theClassName
        query += " " + JOIN_TYPE + "JOIN" + " " + relationalQueryModel.right!.theClassName + " ON "
        query += child.theClassName + "_" + relation.childId  + " = "
        query += parent.theClassName + "_" + relation.parentId
        if String(describing: whereClause).caseInsensitiveCompare("nil") != ComparisonResult.orderedSame{
            query += " WHERE " + whereClause!
        }
        return query
    }
    
    func getInsertQuery<T: Sqlable>(data: T) -> String {
        //INSERT INTO TestSqlModel (name,age) VALUES (?,?)
        let reflection = Reflector.reflect(from:data)
        var query = "INSERT INTO " + theClassName + " ("
        var index : Int = 0
        let properties = getReflectedSelectableModel()
        var valuesBeforeQuery : String = ""
        var valuesAfterQuery : String = ""
        if properties.count>0{
            for (i,prop) in properties.enumerated()
            {
                if prop.constraints.count > 0 &&  prop.constraints.first!.isAutoIncrement{
                    continue
                }
                if !(String(describing: prop.value).caseInsensitiveCompare("nil") == ComparisonResult.orderedSame){
                    let val = SwiftTypeConverter.getStringByAnyTypeForSql(data: prop.value) as! String
                    if index > 0{
                        valuesBeforeQuery +=  " , " + prop.propName
                        valuesAfterQuery +=  "," + "'" + val + "'"
                    }
                    else{
                        valuesBeforeQuery +=  prop.propName
                        valuesAfterQuery +=  "'" + val + "'"
                    }
                    index = index + 1
                }
            }
            query += valuesBeforeQuery + ") VALUES (" + valuesAfterQuery
            query += ")"
        }
        print(query)
        return query;
    }
    
    func getInsertQuery(data: Sqlable) -> String {
        //INSERT INTO TestSqlModel (name,age) VALUES (?,?)
        let reflection = Reflector.reflect(from:data)
        var query = "INSERT INTO " + theClassName + " ("
        var index : Int = 0
        let properties = getReflectedSelectableModel()
        var valuesBeforeQuery : String = ""
        var valuesAfterQuery : String = ""
        if properties.count>0{
            for (i,prop) in properties.enumerated()
            {
                if prop.constraints.count > 0 &&  prop.constraints.first!.isAutoIncrement{
                    continue
                }
                if !(String(describing: prop.value).caseInsensitiveCompare("nil") == ComparisonResult.orderedSame){
                    var val = SwiftTypeConverter.getStringByAnyTypeForSql(data: prop.value) as! String
                    if val.contains("\'"){
                        val = val.replacingOccurrences(of:  "\'", with: "''")
                    }
                    if index > 0{
                        valuesBeforeQuery +=  " , " + prop.propName
                        valuesAfterQuery +=  "," + "'" + val + "'"
                    }
                    else{
                        valuesBeforeQuery +=  prop.propName
                        valuesAfterQuery +=  "'" + val + "'"
                    }
                    index = index + 1
                }
            }
            query += valuesBeforeQuery + ") VALUES (" + valuesAfterQuery
            query += ")"
        }
        print(query)
        return query;
    }

   
    func getInsertQueryWithParentId(data: Sqlable, relationPropName : String, relationPropValue:Any) -> String {
        //INSERT INTO TestSqlModel (name,age) VALUES (?,?)
        let reflection = Reflector.reflect(from:data)
        var query = "INSERT INTO " + theClassName + " ("
        var index : Int = 0
        let properties = getReflectedSelectableModel()
        var valuesBeforeQuery : String = ""
        var valuesAfterQuery : String = ""
        if properties.count>0{
            for prop in properties{
                if prop.propName == relationPropName{
                    prop.value = relationPropValue
                    break
                }
            }
            for (i,prop) in properties.enumerated()
            {
                if prop.constraints.count > 0 &&  prop.constraints.first!.isAutoIncrement{
                        continue
                }
                if !(String(describing: prop.value).caseInsensitiveCompare("nil")  == ComparisonResult.orderedSame){
                    var val = SwiftTypeConverter.getStringByAnyTypeForSql(data: prop.value) as! String
                    if val.contains("\'"){
                        val = val.replacingOccurrences(of:  "\'", with: "''")
                    }
                    if index > 0{
                        valuesBeforeQuery +=  " , " + prop.propName
                        valuesAfterQuery +=  "," + "'" + val + "'"
                    }
                    else{
                        valuesBeforeQuery +=  prop.propName
                        valuesAfterQuery +=  "'" + val + "'"
                    }
                    index = index + 1
                }
            }
            query += valuesBeforeQuery + ") VALUES (" + valuesAfterQuery
            query += ")"
        }
        print(query)
        return query;
    }
    
    var theClassName: String {
        let className = NSStringFromClass(type(of: self) as! AnyClass)
        if className.range(of:".") != nil {
            var classNamarArray : [String] = className.components(separatedBy: ".");
            return classNamarArray[classNamarArray.count-1];
        }
        else
        {
            return className
        }
    }

    
    internal func getReflectedSelectableModel() -> [ReflecedModel]{
        let reflectedModels =  getReflectedModels()
        var selectableReflectedModels : [ReflecedModel] = []
        for field in reflectedModels{
            if !field.noneUseTableCreationProperty(){
                selectableReflectedModels.append(field)
            }
        }
        return selectableReflectedModels
    }
    internal func getReflectedModels() -> [ReflecedModel]{
        let constraints = getConstraints()
        var reflectedModels : [ReflecedModel] = []
        let reflection = Reflector.reflect(from:self)
        let names = reflection.names
        let values = reflection.values
        let types = reflection.types
        for (i,field) in types.enumerated(){
            let filterConstraints = constraints.filter{ $0.columnName ==  names[i] }
            let reflectedModel = ReflecedModel(propName: names[i], value: values[i], type: field,columnConstraint: filterConstraints)
            reflectedModel.className = theClassName
            reflectedModels.append(reflectedModel)
        }
        return reflectedModels
    }
    
    internal func getConstraints() -> [ColumnConstraint]
    {
        var constraints : [ColumnConstraint] = []
        let reflection = Reflector.reflect(from:self)
        let names = reflection.names
        let values = reflection.values
        let types = reflection.types
        for (i,field) in types.enumerated(){
            if field.localizedCaseInsensitiveContains("class<ColumnConstraint>"){
                constraints.append(values[i] as! ColumnConstraint)
            }
        }
        return constraints
    }
    public func getType<T>(type:T) -> T.Type {
        return T.self
    }
    
    func toJSON() -> String {
        do {
            return try JSONSerializer.toJson(self)
        } catch  {
            return (error.localizedDescription)
        }
        
    }
}
//public extension Any{
//    public func getConstraints() -> [ColumnConstraint]
//    {
//        var constraints : [ColumnConstraint] = []
//        let reflection = Reflector.reflect(from:self)
//        let names = reflection.names
//        let values = reflection.values
//        let types = reflection.types
//        for (i,field) in types.enumerated(){
//            if field.localizedCaseInsensitiveContains("class<ColumnConstraint>"){
//                constraints.append(values[i] as! ColumnConstraint)
//            }
//        }
//        return constraints
//    }
//    internal func getReflectedModels() -> [ReflecedModel]{
//        let constraints = getConstraints()
//        var reflectedModels : [ReflecedModel] = []
//        let reflection = Reflector.reflect(from:self)
//        let names = reflection.names
//        let values = reflection.values
//        let types = reflection.types
//        for (i,field) in types.enumerated(){
//            let filterConstraints = constraints.filter{ $0.columnName ==  names[i] }
//            let reflectedModel = ReflecedModel(propName: names[i], value: values[i], type: field,columnConstraint: filterConstraints)
//            reflectedModel.className = theClassName
//            reflectedModels.append(reflectedModel)
//        }
//        return reflectedModels
//    }
    
//}


