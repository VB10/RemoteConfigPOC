//
//  BaseManager.swift
//  RemoteConfigPOC
//
//  Created by Veli Bacik on 6.02.2019.
//  Copyright © 2019 Veli Bacik. All rights reserved.
//

import Foundation
import sqliteLib
import Networking
class BaseManager {
    static let instance = BaseManager()
    
    var service : BaseService?
    var db : BaseDB?
    init() {
        db = BaseDB.shared
        service = BaseService.instance
        db?.connectionOrCreateDb(append: false)
        
        
    }
    
    func getServiceControl(success: @escaping (Bool) -> Void) {
        
        let localVersion = self.db?.getList(with: App.self)
        if localVersion?.count == 0 {
            serviceCall { (result) in
                //POC dummy result
                success(result)
            }
        }else {
            serviceCallWithHeader(version: localVersion![0].version) { (result) in
                success(result)
            }
        }
        
    }
    
    func serviceCall( success: @escaping (Bool) -> Void) {
        service?.getDatas(success: { (result : ResultModel<Config>) in
            let configVersion : Config = result.getModel(type: Config.self)!
            let app = App()
            app.version = configVersion.version.versionNumber
            app.website = configVersion.parameters.website?.defaultValue?.value
            let addOk = self.db?.addItem(with: app)
            if addOk! {
                print("Okey")
            }
            else {
                print("false")
            }
            
            success(true)
            
        }, fail: { (error) in
            success(false)
        })
        
        
    }
    func serviceCallWithHeader(version : String, success: @escaping (Bool) -> Void) {
        service?.getDatasWithHeader(child: "students", headerValue: version, success: { (result : ResultModel<String>) in
            print(result)
            success(true)
        }, fail: { (error) in
            
            if error.getHttpErrorCode() == 426 {
                let config = error.getData()?.toObject(type: Config.self)
                if (config?.version == nil) {
                    return
                }
                let app = App()
                app.version = config!.version.versionNumber
                app.website = config!.parameters.website?.defaultValue?.value
                if (self.db?.addItem(with: app))! {
                    print("oke \(config?.version.versionNumber)")
                }
                else {
                    print("false")
                }
                
                success(true)
            }
        
            
            success(false)
        })
    }
    
    
}
