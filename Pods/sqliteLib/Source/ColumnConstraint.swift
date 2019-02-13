//
//  Constraint.swift
//  SqliteLib
//
//  Created by Umut BOZ on 28.06.2018.
//  Copyright © 2018 Kocsistem. All rights reserved.
//

import Foundation
public class ColumnConstraint : Codable{
    
    var columnName : String = ""
    var isAutoIncrement : Bool = false
    var columnConstraintType : ColumnConstraintType = ColumnConstraintType.PrimaryKey
    
    public required  init(columnName : String , constraintType : ColumnConstraintType, autoIncrement : Bool ) {
        self.columnName = columnName
        self.columnConstraintType = constraintType
        self.isAutoIncrement = autoIncrement
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        columnName = (try container.decodeIfPresent(String.self, forKey: .columName))!
        isAutoIncrement = (try container.decodeIfPresent(Bool.self, forKey: .isAutoIncrement))!
        columnConstraintType = (try container.decodeIfPresent(ColumnConstraintType.self, forKey: .columnConstraintType))!
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode (columnName, forKey: .columName)
        try container.encode (isAutoIncrement, forKey: .isAutoIncrement)
        try container.encode (columnConstraintType, forKey: .columnConstraintType)
    }
    
    enum CodingKeys: String, CodingKey {
        case columName = "columnName"
        case isAutoIncrement = "isAutoIncrement"
        case columnConstraintType = "columnConstraintType"
    }
}

public enum ColumnConstraintType
{
    case PrimaryKey
    case Check(String)
    case Unique
    case NotNull
    case Default(String)
    case None
}

 extension ColumnConstraintType: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
        case .PrimaryKey:
            try container.encode(0, forKey: .rawValue)
        case .Check:
            try container.encode(1, forKey: .rawValue)
        case .Unique:
            try container.encode(2, forKey: .rawValue)
        case .NotNull:
            try container.encode(3, forKey: .rawValue)
        case .Default:
            try container.encode(4, forKey: .rawValue)
        case .None:
            try container.encode(5, forKey: .rawValue)
        }
    }
    enum Key: CodingKey {
        case rawValue
        case associatedValue
    }
    enum CodingError: Error {
        case unknownValue
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(Int.self, forKey: .rawValue)
            switch rawValue {
            case 0:
            self = .PrimaryKey
            case 1:
            let checkValue = try container.decode(String.self, forKey: .associatedValue)
                self = .Check(checkValue)
            case 2:
            self = .Unique
            case 3:
                self = .NotNull
            case 4:
                let defaultValue = try container.decode(String.self, forKey: .associatedValue)
                self = .Default(defaultValue)
            case 5:
                self = .None
            default:
                throw CodingError.unknownValue
        }
    }
}

