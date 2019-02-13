//
//  ReflectedModel.swift
//  SqliteLib
//
//  Created by Umut BOZ on 29.06.2018.
//  Copyright © 2018 Kocsistem. All rights reserved.
//

import Foundation
internal class ReflecedModel{
    var className : String = ""
    var propName : String = ""
    var value : Any
    var type : String = ""
    var constraints : [ColumnConstraint] = []
    //var relations : [ColumnRelation]?
    
    required init(propName : String, value : Any, type : String) {
        self.propName = propName
        self.value = value
        self.type = type
    }
    
    required init(propName : String, value : Any, type : String, columnConstraint : [ColumnConstraint]) {
        self.propName = propName
        self.value = value
        self.type = type
        self.constraints = columnConstraint
    }
    
    internal func isContraintType() -> Bool{
        if self.type.localizedCaseInsensitiveContains("class<ColumnConstraint>") || self.type.localizedCaseInsensitiveContains("custom<ColumnConstraint>") {
            return true
        }
        return false
    }
    internal func isRelationType() -> Bool{
        if self.type.localizedCaseInsensitiveContains("class<ColumnRelation>") || self.type.localizedCaseInsensitiveContains("custom<ColumnRelation>") {
            return true
        }
        return false
    }
    internal func isRelationalProperty() -> Bool{
        let relationalFilter = BaseDatabase.relations.filter{ $0.parentProp == self.propName ||
            $0.childProp == self.propName }
        return relationalFilter.count > 0 ? true : false
    }
    internal func noneUseTableCreationProperty() ->  Bool {
        if isContraintType() || isRelationType() || isRelationalProperty(){
            return true
        }
        return false
    }
    
}
 internal extension Array where Element : ReflecedModel{
    func filterByName(propName : String) -> [ReflecedModel]{
        return  self.filter{ $0.propName == propName }
    }
    
    func isContraint(propName : String) -> Bool{
        let filterArray =   self.filter{ $0.propName == propName }
        if filterArray.count > 0{
            if filterArray.first!.isContraintType(){
                return true
            }
        }
        return false
    }
    func isRelation(propName : String) -> Bool{
        let filterArray =   self.filter{ $0.propName == propName }
        if filterArray.count > 0{
            if filterArray.first!.isRelationType(){
                return true
            }
        }
        return false
    }
    

    
   
}
