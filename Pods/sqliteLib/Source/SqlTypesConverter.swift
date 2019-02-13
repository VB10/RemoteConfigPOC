//
//  SqlTypesConverter.swift
//  SQLITE
//
//  Created by Umut BOZ on 30/08/2017.
//  Copyright © 2017 Kocsistem. All rights reserved.
//

import Foundation

open class SqlTypeConverter
{
    
    public class func isInsertableConstraint(constraint : ColumnConstraint)-> Bool{
        
        let constraintType = constraint.columnConstraintType
        switch constraintType {
        case .None:
            return true
        case .Default(let value):
            return true
        case .Check(let value):
            return true
        case .PrimaryKey:
            if constraint.isAutoIncrement{
            return false
            }
            else{
            return true
            }
        case .Unique:
            return true
        case .NotNull:
            return false
        }

    }
    
    
    public class func getConstraintString(constraint : ColumnConstraint)-> String{
        var returnString : String = ""
        let constraintType = constraint.columnConstraintType
        switch constraintType {
        case .None:
            returnString = ""
        case .Default(let value):
            returnString = " DEFAULT " + value
        case .Check(let value):
            returnString = " CHECK(" + value + ")"
        case .PrimaryKey:
            returnString = " PRIMARY KEY " + (constraint.isAutoIncrement ? " AUTOINCREMENT " : "")
        case .Unique:
            returnString = " UNIQUE "
        case .NotNull:
            returnString = " NOT NULL "
        }
        return returnString
    }
    
    public class func getSwiftType(type: Sqlable, fieldName: String, data : Any?)-> String {
        let reflection = Reflector.reflect(from:data)
        let typeString = reflection.type.description
        var propTypeString : String? = nil
        var nonOptinalStringValue : String?
        propTypeString = typeString
        
        //value null mi?
        if !(String(describing: data).caseInsensitiveCompare("nil") == ComparisonResult.orderedSame){
            //data Optional bir type mı !
            if(Mirror.init(reflecting: data).displayStyle == Mirror.DisplayStyle.optional){
                if data == nil {
                    nonOptinalStringValue = nil
                }else{
                    if (propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swString)){
                        nonOptinalStringValue =  String(describing: data as? String)
                    }
                    else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swBool){
                        nonOptinalStringValue =  String(describing: data as? Bool)
                    }
                    else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swDate) {
                        nonOptinalStringValue =  String(describing: data as? Date)
                    }
                    else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt8) {
                        nonOptinalStringValue =  String(describing: data as? Int8)
                    }
                    else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt16){
                        nonOptinalStringValue =  String(describing: data as? Int16)
                    }
                    else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt32){
                        nonOptinalStringValue  = String(describing: data as? Int32)
                    }
                    else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt64){
                        nonOptinalStringValue =  String(describing: data as? Int64)
                    }
                    else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swDouble){
                        nonOptinalStringValue =  String(describing: data as? Double)
                    }
                    else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt){
                        nonOptinalStringValue =  String(describing: data as? Int)
                    }
                    else
                    {
                        nonOptinalStringValue = SqlTypeConverter.sqlNull
                    }
                    nonOptinalStringValue = SwiftTypeConverter.controlOptionalValue(dataString: nonOptinalStringValue!, data: data)
                }
            }else{
                if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swString){
                    nonOptinalStringValue =  String(describing: data as! String)
                }
                else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swBool) {
                    nonOptinalStringValue =  String(describing: data as! Bool)
                }
                else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swDate){
                    nonOptinalStringValue =  String(describing: data as! Date)
                }
                else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt8){
                    nonOptinalStringValue =  String(describing: data as! Int8)
                }
                else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt16){
                    nonOptinalStringValue =  String(describing: data as! Int16)
                }
                else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt32){
                    nonOptinalStringValue =  String(describing: data as! Int32)
                }
                else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt64){
                    nonOptinalStringValue =  String(describing: data as! Int64)
                }
                else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swDouble){
                    nonOptinalStringValue =  String(describing: data as! Double)
                }
                else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt){
                    nonOptinalStringValue =  String(describing: data as! Int)
                }
                else
                {
                    nonOptinalStringValue = SqlTypeConverter.sqlNull
                }
            }
        }else
        {
            nonOptinalStringValue = SqlTypeConverter.sqlNull
        }
        return nonOptinalStringValue!
    }
    
    internal class func getSwiftType(data : Any?)-> String{
        let reflection = Reflector.reflect(from:data)
        let typeString = reflection.type.description
        var nonOptinalStringValue : String?
        var propTypeString : String? = nil
        propTypeString = typeString
        //value null mi?
        if !(String(describing: data).caseInsensitiveCompare("nil") == ComparisonResult.orderedSame){
            //data Optional bir type mı !
            if(Mirror.init(reflecting: data).displayStyle == Mirror.DisplayStyle.optional){
                if data == nil {
                    nonOptinalStringValue = nil
                }else{
                    if (propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swString)){
                        nonOptinalStringValue =  String(describing: data as? String)
                    }
                    else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swBool){
                        nonOptinalStringValue =  String(describing: data as? Bool)
                    }
                    else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swDate) {
                        nonOptinalStringValue =  String(describing: data as? Date)
                    }
                    else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt8){
                        nonOptinalStringValue =  String(describing: data as? Int8)
                    }
                    else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt16){
                        nonOptinalStringValue =  String(describing: data as? Int16)
                    }
                    else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt32){
                        nonOptinalStringValue  = String(describing: data as? Int32)
                    }
                    else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt64){
                        nonOptinalStringValue =  String(describing: data as? Int64)
                    }
                    else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swDouble) {
                        nonOptinalStringValue =  String(describing: data as? Double)
                    }
                    else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt){
                        nonOptinalStringValue =  String(describing: data as? Int)
                    }
                    else
                    {
                        nonOptinalStringValue = SqlTypeConverter.sqlNull
                    }
                    nonOptinalStringValue = SwiftTypeConverter.controlOptionalValue(dataString: nonOptinalStringValue!, data: data)
                }
            }else{
                if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swString){
                    nonOptinalStringValue =  String(describing: data as! String)
                }
                else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swBool){
                    nonOptinalStringValue =  String(describing: data as! Bool)
                }
                else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swDate){
                    nonOptinalStringValue =  String(describing: data as! Date)
                }
                else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt8){
                    nonOptinalStringValue =  String(describing: data as! Int8)
                }
                else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt16){
                    nonOptinalStringValue =  String(describing: data as! Int16)
                }
                else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt32){
                    nonOptinalStringValue =  String(describing: data as! Int32)
                }
                else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt64){
                    nonOptinalStringValue =  String(describing: data as! Int64)
                }
                else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swDouble){
                    nonOptinalStringValue =  String(describing: data as! Double)
                }
                else if propTypeString!.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt){
                    nonOptinalStringValue =  String(describing: data as! Int)
                }
                else
                {
                    nonOptinalStringValue = SqlTypeConverter.sqlNull
                }
            }
        }else
        {
            nonOptinalStringValue = SqlTypeConverter.sqlNull
        }
        return nonOptinalStringValue!
    }
    
  public  class func getSqlType(type : String) -> String {
        var sqlType = "";
        if type.localizedCaseInsensitiveContains(swString) {
            sqlType =  sqlText;
        }
        else if type.localizedCaseInsensitiveContains(swNSString) {
        sqlType =  sqlText;
        }
        else if type.localizedCaseInsensitiveContains(swBool) {
            sqlType =  sqlText;
        }
        else if type.localizedCaseInsensitiveContains(swDate) {
            sqlType =  sqlText;
        }
        else if type.localizedCaseInsensitiveContains(swInt){
            sqlType =  sqlInteger;
        }
        else if type.localizedCaseInsensitiveContains(swInt8){
            sqlType =  sqlInteger;
        }
        else if type.localizedCaseInsensitiveContains(swInt16){
            sqlType =  sqlInteger;
        }
        else if type.localizedCaseInsensitiveContains(swInt32){
            sqlType =  sqlInteger;
        }
        else if type.localizedCaseInsensitiveContains(swInt64){
            sqlType =  sqlInteger;
        }
        else if type.localizedCaseInsensitiveContains(swBool){
            sqlType =  sqlText;
        }
        else if type.localizedCaseInsensitiveContains(swDouble){
            sqlType =  sqlNumeric;
        }
        else
        {
            sqlType = type
        }
        return sqlType;
    }
    
    
    
    /* Swift TYPES */
public static let swInt : String = "Int";
public static let swInt32 : String = "Int32";
public static let swInt64 : String = "Int64";
public static let swInt8 : String = "Int8";
public static let swInt16 : String = "Int16";
public static let swNSString : String = "NSString";
public static let swString : String = "String";
public static let swBool: String = "Bool";
public static let swDate: String = "Date";
public static let swDouble: String = "Double";
    
    
    
    /* Sql TYPES */
   static let sqlText : String = "TEXT";
   static let sqlInteger: String = "INTEGER";
   static let sqlReal: String = "REAL";
   static let sqlBool : String = "BOOLEAN";
   static let sqlBlob : String = "BLOB";
   static let sqlNumeric : String = "NUMERIC";
    
   public static let sqlNull : String = "NULL";
    
    /*
     https://sqlite.org/datatype3.html
     
     CREATE TABLE t1(
     t  TEXT,     -- text affinity by rule 2
     nu NUMERIC,  -- numeric affinity by rule 5
     i  INTEGER,  -- integer affinity by rule 1
     r  REAL,     -- real affinity by rule 4
     no BLOB      -- no affinity by rule 3
     );
    */
    
    
}
//STRign extension
public extension String{
    
    func toJsonValue(type: Sqlable,fieldName: String)-> String {
        let reflection = Reflector.reflect(from:type)
        let typeString = reflection.type.description
        let properties = type.getReflectedModels()
        var propTypeString : String? = nil
        for field in properties {
            if field.propName.caseInsensitiveCompare(fieldName) == ComparisonResult.orderedSame {
                propTypeString = field.type
                break
            }
        }
        if self.caseInsensitiveCompare(SqlTypeConverter.sqlNull) == ComparisonResult.orderedSame{
            return self
        }
        if propTypeString!.caseInsensitiveCompare(SwiftTypeConverter.swString) == ComparisonResult.orderedSame {
           return "\"" + self + "\""
        }
        else
        {
            return self
        }
    }
    
    func toDictionaryValue(type: Sqlable,fieldName: String)-> String? {
        let reflection = Reflector.reflect(from:type)
        let typeString = reflection.type.description
        let properties = type.getReflectedModels()
        var propTypeString : String? = nil
        for field in properties {
            if field.propName.caseInsensitiveCompare(fieldName) == ComparisonResult.orderedSame {
                propTypeString = field.type
                break
            }
        }
        if self.caseInsensitiveCompare(SqlTypeConverter.sqlNull) == ComparisonResult.orderedSame{
            return nil
        }
        if propTypeString!.caseInsensitiveCompare(SwiftTypeConverter.swString) == ComparisonResult.orderedSame {
            return self
        }
        else
        {
            return self
        }
    }
}
