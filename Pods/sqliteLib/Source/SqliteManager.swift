//
//  KSDBManager.swift
//  SQLITE
//
//  Created by Umut on 28/08/2017.
//  Copyright © 2017 KOCSISTEM. All rights reserved.
//

import Foundation
import CoreData
import SQLite




open class SqliteManager {
    
    public static let instance = SqliteManager()

    public var db: Connection?
    var fullPath : String
    let dbDirectoryPath : String
    var databaseName : String
   
    private init() {
        let environments =  ProcessInfo.processInfo.environment
        let isRunningTestsValue = environments["APPS_IS_RUNNING_TEST"]
        if isRunningTestsValue != nil && isRunningTestsValue == "YES"{
            let testBundle = Bundle(for: type(of: self))
            self.dbDirectoryPath = testBundle.bundlePath
            self.fullPath = ""
            let bundleName = testBundle.bundleURL.lastPathComponent
            self.databaseName = bundleName
            self.db = nil
        }else
        {
            let bundleName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
            let dirs: [NSString] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                                       FileManager.SearchPathDomainMask.allDomainsMask, true) as [NSString]
            let dir = dirs[0]
            self.dbDirectoryPath = dir.appendingPathComponent("")
            self.fullPath = ""
            self.databaseName = bundleName
            self.db = nil
            
        }
        
        #if DEBUG
        
        #else
           
  
        #endif
    }

    public func exportDbFile(database: BaseDatabase) -> String {
        return self.dbDirectoryPath + "/" + database.dbName
    }
    
    ///DB CREATE
 public func connectionOrCreateDb(database: BaseDatabase, append : Bool = false) -> Void {
        // db varsa -  uzerine tekrar olustur
        self.databaseName = database.dbName
        var hasDbCreated = false
        if append {
            removeFile(dbFileName:self.databaseName )
            hasDbCreated = true
        }
        else{
            if !hasDb(db: self.databaseName){
                hasDbCreated = true
            }
        }
        print("dbName : " + self.databaseName);
        // db varsa -  uzerine tekrar olustur
        self.fullPath  = self.dbDirectoryPath + "/" + self.databaseName;
        print("db Path : " + self.fullPath);
        do {
            self.db = try Connection(self.fullPath)
            print(self.databaseName + " database oluşturuldu!");
            if hasDbCreated{
                database.createTables()
            }
            else{
                //db to mem for columnRelation
                BaseDatabase.initRelationsDbToMemory()
            }
        } catch _ {
            self.db = nil
            print(self.databaseName + " database oluşturulamadı!");
        }
    }
    
    ///DB REMOVE
    func removeDatabase(dbFileName: String) -> Bool {
        var dbName = dbFileName;
        var filePath = "";
        if !dbName.isEmpty
        {
            do {
                let fileManager = FileManager.default
                filePath =  self.dbDirectoryPath + "/" + dbName  + ".sqlite";
                 // print("remove db path : " + filePath);
                // Check if file exists
                if fileManager.fileExists(atPath: filePath) {
                    // Delete file
                    try fileManager.removeItem(atPath: filePath)
                } else {
                    print(dbFileName + " database bulunamadı!");
                    return false;
                }
                print(dbFileName + " database silindi");
                return true
            }
            catch let error as NSError {
                print("db silinirken hata: \(error)")
                return false;
            }
        }
        return false;
    }
    func hasFile(file : String) -> Bool {
        
         var filePath = "";
    
            let fileManager = FileManager.default
            
            filePath =  self.dbDirectoryPath + "/" + file;
            // print("remove db path : " + filePath);
            // Check if file exists
            if fileManager.fileExists(atPath: filePath) {
                // Delete file
                return true;
            } else {
                print(file + " file bulunamadı!");
                return false;
            }
    }
    func hasDb(db : String) -> Bool {
        
        var filePath = "";
        
        let fileManager = FileManager.default
        
        filePath =  self.dbDirectoryPath + "/" + db;
        // print("remove db path : " + filePath);
        // Check if file exists
        if fileManager.fileExists(atPath: filePath) {
            // Delete file
            return true;
        } else {
            print(db + " database bulunamadı!");
            return false;
        }
    }
    
    func removeFile(dbFileName: String) -> Bool {
        
        var dbName = dbFileName;
        var filePath = "";
        if !dbName.isEmpty
        {
            do {
                let fileManager = FileManager.default
                
                filePath =  self.dbDirectoryPath + "/" + dbName
                // print("remove db path : " + filePath);
                // Check if file exists
                if fileManager.fileExists(atPath: filePath) {
                    // Delete file
                    try fileManager.removeItem(atPath: filePath)
                } else {
                    print(dbFileName + " database bulunamadı!");
                    return false;
                }
                print(dbFileName + " database silindi");
                
                return true
            }
            catch let error as NSError {
                print("db silinirken hata: \(error)")
                return false;
            }
            
            
            
        }
        
        return false;
        
    }
    
   
   
}

