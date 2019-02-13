//
//  SwiftTypeConverter.swift
//  SqliteLib
//
//  Created by Umut BOZ on 12.06.2018.
//  Copyright © 2018 Kocsistem. All rights reserved.
//

import Foundation
open class SwiftTypeConverter
{
    
    public  class func getStringByAnyTypeForSql(data : Any?) -> String? {
        var nonOptinalStringValue : String = SqlTypeConverter.sqlNull
        let reflection = Reflector.reflect(from:data)
        let typeString = reflection.type
//data Optional bir type mı !
        if(Mirror.init(reflecting: data).displayStyle == Mirror.DisplayStyle.optional){
            if data == nil {
                nonOptinalStringValue = SqlTypeConverter.sqlNull
            }else{
                if typeString.description.localizedCaseInsensitiveContains(SwiftTypeConverter.swString){
                    nonOptinalStringValue =  String(describing: data as? String)
                }
                else if typeString.description.localizedCaseInsensitiveContains(SwiftTypeConverter.swBool){
                    nonOptinalStringValue =  String(describing: data as? Bool)
                }
                else if typeString.description.localizedCaseInsensitiveContains(SwiftTypeConverter.swDate){
                    nonOptinalStringValue =  String(describing: data as? Date)
                }
                else if typeString.description.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt8){
                    nonOptinalStringValue =  String(describing: data as? Int8)
                }
                else if typeString.description.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt16){
                    nonOptinalStringValue =  String(describing: data as? Int16)
                }
                else if typeString.description.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt32){
                        nonOptinalStringValue  = String(describing: data as? Int32)
                }
                else if typeString.description.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt64){
                    nonOptinalStringValue =  String(describing: data as? Int64)
                }
                else if typeString.description.localizedCaseInsensitiveContains(SwiftTypeConverter.swDouble){
                    nonOptinalStringValue =  String(describing: data as? Double)
                }
                else if typeString.description.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt){
                    nonOptinalStringValue =  String(describing: data as? Int)
                }
                else
                {
                    nonOptinalStringValue = SqlTypeConverter.sqlNull
                }
                nonOptinalStringValue = controlOptionalValue(dataString: nonOptinalStringValue, data: data)
                
            }
        }else{
            if typeString.description.localizedCaseInsensitiveContains(SwiftTypeConverter.swString){
                nonOptinalStringValue =  String(describing: data as! String)
            }
            else if typeString.description.localizedCaseInsensitiveContains(SwiftTypeConverter.swBool){
                nonOptinalStringValue =  String(describing: data as! Bool)
            }
            else if typeString.description.localizedCaseInsensitiveContains(SwiftTypeConverter.swDate){
                nonOptinalStringValue =  String(describing: data as! Date)
            }
            else if typeString.description.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt8){
                nonOptinalStringValue =  String(describing: data as! Int8)
            }
            else if typeString.description.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt16){
                nonOptinalStringValue =  String(describing: data as! Int16)
            }
            else if typeString.description.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt32){
                nonOptinalStringValue =  String(describing: data as! Int32)
            }
            else if typeString.description.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt64){
                nonOptinalStringValue =  String(describing: data as! Int64)
            }
            else if typeString.description.localizedCaseInsensitiveContains(SwiftTypeConverter.swDouble){
                nonOptinalStringValue =  String(describing: data as! Double)
            }
            else if typeString.description.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt){
                nonOptinalStringValue =  String(describing: data as! Int)
            }
            else
            {
                nonOptinalStringValue = SqlTypeConverter.sqlNull
            }
        }
        return nonOptinalStringValue
    }
    
   internal class func controlOptionalValue(dataString : String, data : Any?) -> String{
        let reflection = Reflector.reflect(from:data)
        let typeString = reflection.type.description
        let nonOptinalStringValue : String
        if dataString.caseInsensitiveCompare("nil") == ComparisonResult.orderedSame{
            return SqlTypeConverter.sqlNull
        }
        else
        {
            if typeString.localizedCaseInsensitiveContains(SwiftTypeConverter.swString) {
                nonOptinalStringValue =  String(describing: data as! String)
            }
            else if typeString.localizedCaseInsensitiveContains(SwiftTypeConverter.swBool) {
                nonOptinalStringValue =  String(describing: data as! Bool)
            }
            else if typeString.localizedCaseInsensitiveContains(SwiftTypeConverter.swDate) {
                nonOptinalStringValue =  String(describing: data as! Date)
            }
            else if typeString.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt8) {
                nonOptinalStringValue =  String(describing: data as! Int8)
            }
            else if typeString.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt16) {
                nonOptinalStringValue =  String(describing: data as! Int16)
            }
            else if typeString.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt32) {
                nonOptinalStringValue =  String(describing: data as! Int32)
            }
            else if typeString.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt64) {
                nonOptinalStringValue =  String(describing: data as! Int64)
            }
            else if typeString.localizedCaseInsensitiveContains(SwiftTypeConverter.swDouble) {
                nonOptinalStringValue =  String(describing: data as! Double)
            }
            else if typeString.localizedCaseInsensitiveContains(SwiftTypeConverter.swInt) {
                nonOptinalStringValue =  String(describing: data as! Int)
            }
            else
            {
                nonOptinalStringValue = SqlTypeConverter.sqlNull
            }
        }
        return nonOptinalStringValue
    }
    
    /* Swift TYPES */
    public static let swInt : String = "Int";
    public static let swInt32 : String = "Int32";
    public static let swInt64 : String = "Int64";
    public static let swInt8 : String = "Int8";
    public static let swInt16 : String = "Int16";
    public static let swString : String = "String";
    public static let swBool: String = "Bool";
    public static let swDate: String = "Date";
    public static let swDouble: String = "Double";
}
