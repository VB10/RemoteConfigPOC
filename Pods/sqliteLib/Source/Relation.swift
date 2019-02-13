//
//  Relation.swift
//  SqliteLib
//
//  Created by Umut BOZ on 3.07.2018.
//  Copyright © 2018 Kocsistem. All rights reserved.
//

import Foundation
public class Relation{
    
    var parentId : String = ""
    var childTableId : String = ""
    var relationalTable : String = ""
    var childId : String = ""
    var parentProp : String = ""
    var childProp : String = ""
    var columnRelationType : ColumnRelationType = ColumnRelationType.None
    
    
    public required  init(parentId : String , relationalTableName: String, childId : String, relationType : ColumnRelationType, parentProperty : String, childProperty : String ) {
        self.parentId = parentId
        self.relationalTable = relationalTableName
        self.childId = childId
        self.columnRelationType = relationType
        self.parentProp = parentProperty
        self.childProp = childProperty
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColumnRelationCodingKeys.self)
        parentId = (try container.decodeIfPresent(String.self, forKey: .parentId))!
        childId = (try container.decodeIfPresent(String.self, forKey: .childId))!
        parentProp = (try container.decodeIfPresent(String.self, forKey: .parentProp))!
        childProp = (try container.decodeIfPresent(String.self, forKey: .childProp))!
        relationalTable = (try container.decodeIfPresent(String.self, forKey: .relationalTable))!
        columnRelationType = (try container.decodeIfPresent(ColumnRelationType.self, forKey: .columnRelationType))!
    }
    
    enum ColumnRelationCodingKeys: String, CodingKey {
        case parentId = "parentId"
        case childId = "childId"
        case parentProp = "parentProp"
        case childProp = "childProp"
        case relationalTable = "relationalTable"
        case columnRelationType = "columnRelationType"
    }
    
}
