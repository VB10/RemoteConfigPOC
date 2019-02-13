//
//  Dictionary+Extension.swift
//  SqliteLib
//
//  Created by Umut BOZ on 17.07.2018.
//  Copyright © 2018 Kocsistem. All rights reserved.
//

public extension Dictionary where Key: ExpressibleByStringLiteral, Value: ExpressibleByStringLiteral {
    var jsonString: String {
        var rowValueArrayIndex = 0
        var rowJson = """
        {
        """
        for (key,value) in self {
            if !(String(describing:value).localizedStandardCompare(SqlTypeConverter.sqlNull) == ComparisonResult.orderedSame) {
                if rowValueArrayIndex > 0{
                    rowJson += ","
                }
                rowJson +=  "" +  "\"" + String(describing:key) + "\""
                rowJson += ":" + String(describing:value)
                rowValueArrayIndex = rowValueArrayIndex + 1
            }
        }
        rowJson += """
        }
        """
        return rowJson
        
    }
    
    func jsonStringAddChild(name : String , value : String) -> String {
        var rowValueArrayIndex = 0
        var rowJson = """
        {
        """
        for (key,value) in self {
            if !(String(describing:value).localizedStandardCompare(SqlTypeConverter.sqlNull) == ComparisonResult.orderedSame){
                if rowValueArrayIndex > 0{
                    rowJson += ","
                }
                rowJson +=  "" +  "\"" + String(describing:key) + "\""
                rowJson += ":" + String(describing:value)
                rowValueArrayIndex = rowValueArrayIndex + 1
            }
        }
        if value != ""{
        rowJson += "," +  "\"" +  name + "\""
        rowJson += ":" +  value
        }
        rowJson += """
            
        }
        """
        return rowJson
        
    }
}
