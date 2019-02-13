//
//  BaseService.swift
//  RemoteConfigPOC
//
//  Created by Veli Bacik on 6.02.2019.
//  Copyright © 2019 Veli Bacik. All rights reserved.
//

import Foundation
import Networking


class BaseService {
    
    static let instance = BaseService()
    
    //    private NetworkManager manager;
    let manager = NetworkManager()
    
    private let serviceUrl : String = "https://remoteconfigpoc.azurewebsites.net/api/config"
    
    
    /**
     Creates a dynamic http request.
     
     - Parameter result function , fail function
     
     - Throws: `T model not Serializable`
     
     - Returns:async Succes and fail void and return bool model or data model .
     */
    func getDatas<T>(success: @escaping (ResultModel<T>) -> Void, fail: @escaping Fail) {
        NetworkManager().get(serviceUrl, success: success, fail: fail).fetch()
    }
    
    
    func getDatas_USERNAME(success: @escaping (ResultModel<Config>) -> Void, fail: @escaping Fail) {
        NetworkManager().get(serviceUrl, success: success, fail: fail).fetch()
    }
   
    
    /**
     Creates a dynamic http request with header.
     
     - Parameter: child baseUri + data , headerValue  add request header ,  result function , fail function
     
     - Throws: `T model not Serializable`
     
     - Returns:async Succes and fail void and return bool model or data model .
     */
    func getDatasWithHeader<T>(child : String ,headerValue : String, success: @escaping (ResultModel<T>) -> Void, fail: @escaping Fail) {
        let _ = NetworkConfig.shared.addHeader(headerKey: "versionNumber", headerValue: headerValue)
        NetworkManager().get(("\(serviceUrl)/\(child)"), success: success, fail: fail).fetch()
    }
    
    
}
