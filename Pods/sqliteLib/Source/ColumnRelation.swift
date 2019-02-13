//
//  ColumnReletion.swift
//  SqliteLib
//
//  Created by Umut BOZ on 3.07.2018.
//  Copyright © 2018 Kocsistem. All rights reserved.
//

import Foundation
public class ColumnRelation : Codable{
    
    var parentTable : String = ""
    var parentId : String = ""
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
        parentTable = (try container.decodeIfPresent(String.self, forKey: .parentTable))!
        childId = (try container.decodeIfPresent(String.self, forKey: .childId))!
        parentProp = (try container.decodeIfPresent(String.self, forKey: .parentProp))!
        childProp = (try container.decodeIfPresent(String.self, forKey: .childProp))!
        relationalTable = (try container.decodeIfPresent(String.self, forKey: .relationalTable))!
        columnRelationType = (try container.decodeIfPresent(ColumnRelationType.self, forKey: .columnRelationType))!
    }
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: ColumnRelationCodingKeys.self)
        try container.encode (parentId, forKey: .parentId)
        try container.encode (parentTable, forKey: .parentTable)
        try container.encode (childId, forKey: .childId)
        try container.encode (parentProp, forKey: .parentProp)
        try container.encode (childProp, forKey: .childProp)
        try container.encode (relationalTable, forKey: .relationalTable)
        try container.encode (columnRelationType, forKey: .columnRelationType)
    }
    
    internal func isParentTable(tableName : String) -> Bool{
        if self.parentTable == tableName{
        return true
        }
        else{
        return
        false
        }
    }
    internal func isChildTable(tableName : String) -> Bool{
        if self.relationalTable == tableName{
            return true
        }
        else{
            return
            false
        }
    }
    
    enum ColumnRelationCodingKeys: String, CodingKey {
        case parentTable  = "parentTable"
        case parentId = "parentId"
        case childId = "childId"
        case parentProp = "parentProp"
        case childProp = "childProp"
        case relationalTable = "relationalTable"
        case columnRelationType = "columnRelationType"
    }
}

public enum ColumnRelationType
{
    case OneToOne
    case OneToMany
    case ManyToMany
    case None
}
extension ColumnRelationType: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .OneToOne:
            try container.encode(0, forKey: .rawValue)
        case .OneToMany:
            try container.encode(1, forKey: .rawValue)
        case .ManyToMany:
            try container.encode(2, forKey: .rawValue)
        case .None:
            try container.encode(3, forKey: .rawValue)
        }
    }
    enum Key: CodingKey {
        case rawValue
    }
    enum CodingError: Error {
        case unknownValue
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
        switch rawValue {
        case 0:
            self = .OneToOne
        case 1:
            self = .OneToMany
        case 2:
            self = .ManyToMany
        case 3:
            self = .None
        default:
            throw CodingError.unknownValue
        }
    }
}



