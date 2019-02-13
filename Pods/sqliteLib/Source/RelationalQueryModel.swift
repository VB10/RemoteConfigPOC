//
//  RelationalQueryModel.swift
//  SqliteLib
//
//  Created by Umut BOZ on 4.07.2018.
//  Copyright © 2018 Kocsistem. All rights reserved.
//

import Foundation
public class RelationalQueryModel{
    
    var parent : Sqlable?
    var child : Sqlable?
    var relation : ColumnRelation?
    var hasRelation : Bool = false
    
    var left : Sqlable?
    var right : Sqlable?
}

public class RelationObject{
    var parentValue : String = ""
    var dictionary : [String:String] = [:]
}
extension Array where Element:RelationObject {
    var jsonStringArray : String {
        var rowJson = """
        [
        """
        if self.count > 0{
            var index = 0
            self.forEach{ child in
                let brackets : String = (index > 0 ) ? "," : ""
                rowJson += brackets + child.dictionary.jsonString
                index += 1
            }
        }
        rowJson += """
        ]
        """
        return  rowJson
    }
    
}





