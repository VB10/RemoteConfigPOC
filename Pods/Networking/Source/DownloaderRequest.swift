//
//  GenericObjectRequest.swift
//  Networking
//
//  Created by Umut BOZ on 02/03/2018.
//  Copyright © 2019 KocSistem. All rights reserved.
//  Edit @umut 1.02.2018

import Foundation
import Alamofire

public typealias DownloadResult = (DefaultDownloadResponse) -> Void

public class DownloaderRequest: Alamofire.SessionManager {
    
    private var headers: [String: String] = [:]
    private var jsonKeys: [String]?
    private var jsonKey: String?
    private var timeOut: Int?
    private var parameters: Parameters? = [:]
    
    internal var successCallback: DownloadResult?
    internal var errorCallback: Fail?
    private var httpMethod : HTTPMethod?
    private var url : String?
    var fileDestinationUrl : URL?
    
    internal var request: DownloadRequest!
    //private var tag : String?
    //private var learning : NetworkLearning?
    //var customErrorStatusCodes: Array<Int>? = Array<Int>()
    //var successStatusCodes: Array<Int>? = Array<Int>()

    public init() {
        super.init()
    }

    // MARK: -
    // MARK: INIT DOWNLOAD REQUEST
    init(url: String, fileURL: URL? = nil, method: HTTPMethod, timeout: Double?, jsonKeys: [String]? = nil, headers : [String:String],parameters : Parameters? = nil) {
        
        self.jsonKeys = jsonKeys
        self.httpMethod = method
        self.url = url
        self.headers = headers
        self.fileDestinationUrl = fileURL
        self.parameters = parameters
        
        /*  INIT SESSION CONFIG    */
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout ?? 300.0
        configuration.timeoutIntervalForResource = timeout ?? 300.0
        configuration.httpAdditionalHeaders = NetworkConfig.shared.getDefaultHeaders()
        super.init(configuration:configuration)
    }


    internal func getBody() -> [String: Any]? {
        return parameters
    }
    
    public func addHeader(_ key: String, value: String) -> Self {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = NetworkConfig.shared.getDefaultHeaders()
        configuration.httpAdditionalHeaders![key] = value
        headers = configuration.httpAdditionalHeaders as! [String : String]
        return self
    }
    
    public func setJsonKey(_ key: String?) -> Self {
        if key == nil {
            jsonKeys = nil
        } else {
            jsonKey = key
            jsonKeys = [jsonKey!]
        }
        return self
    }
    
    // MARK: CREATE REQUEST
    public func fetch() {
        /*if self.httpMethod == .post {
            request = super.request(self.url!, method: httpMethod!, parameters: parameters!, encoding: JSONEncoding.default, headers: headers)
        } else {
            request = super.request(self.url!, method: httpMethod!, encoding: URLEncoding.default, headers: headers)
        }
        //NETWORK CANCELLATION
        if let tagString = getTag(), !tagString.isEmpty {
            NetworkCancellation.addRequest(getTag()!, request: self.request)
        }
        setSuccessStatusCodes(statusCode: 200..<201)
        print("REQUEST      ++++ \(request.description)")
    
        parseNetworkResponse(success: successCallback!, fail: errorCallback!)*/
        
        var to: DownloadRequest.DownloadFileDestination? = nil
        if(fileDestinationUrl != nil)
        {
            to = { (url, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
                return (self.fileDestinationUrl!, [.removePreviousFile, .createIntermediateDirectories])
            }
        }
        
        self.request = super.download(
            self.url!,
            method: .get,
            parameters: self.parameters,
            encoding: JSONEncoding.default,
            headers: self.headers,
            to: to).downloadProgress(closure: { (progress) in
                
            }).response(completionHandler: { (response) in
                print("Networking DownloaderRequest Temp URL: \(String(describing: response.temporaryURL))")
                print("Networking DownloaderRequest Destination URL: \(String(describing: response.destinationURL))")
                print("Networking DownloaderRequest Status Code:\(String(describing: response.response?.statusCode)) Error: \(String(describing: response.error))")
                if(response.error == nil && (response.temporaryURL != nil || response.destinationURL != nil) && response.response != nil &&
                    response.response?.statusCode != nil && (response.response?.statusCode)! >= 200 && (response.response?.statusCode)! <= 201)
                {
                    print("Download Request fetch success")
                    if(self.errorCallback != nil)
                    {
                        self.successCallback!(response)
                    }
                    else
                    {
                        print("SuccessCallBack is nil so cannot returns success object!")
                    }
                }
                else
                {
                    print("Download Request fetch fail error: \(response.error?.localizedDescription ?? "")")
                    let errorModel = ErrorModel()
                    errorModel.setDescription(description: response.error?.localizedDescription ?? "")
                    errorModel.setHttpErrorCode(errorCode: response.response?.statusCode)
                    if(self.errorCallback != nil)
                    {
                        self.errorCallback!(errorModel)
                    }
                    else
                    {
                        print("ErrorCallBack is nil so cannot returns success object!")
                    }
                    
                }
            })
        
    }
    public func cancel() ->Void{
        print("Downloader request \(self.url!) canceled!")
        self.request.cancel()
    }
    
  /*
    // MARK: - ARTIK ALTTAKILERIN BIR GOREVI YOK!!!
    // MARK: NETWORK RESPONSE PARSE
    private func parseNetworkResponse(success: @escaping DownloadSuccess<T>,
                                      fail: @escaping Fail) {
        let utilityQueue = DispatchQueue.global(qos: .utility)
        request.responseString(queue: utilityQueue) { response in
            print("RESPONSE     ++++ \(response.debugDescription)")
            let responseHeaders = response.response?.allHeaderFields
            let hasLearning: Bool = self.learning != nil ? true : false
            switch response.result {
            case .success(let value):
                do {
                    let json = value
                    let result = try self.getResultModel(json)
                    result.setData(data: response.data)
                    result.setResponseHeaders(responseHeaders)
                    success(result)
                } catch let error {
                    let errorModel = ErrorModel()
                    errorModel.setDescription(description: error.localizedDescription)
                    errorModel.setHttpErrorCode(errorCode: response.response?.statusCode)
                    errorModel.setDescription(description: value)
                    errorModel.setData(data: response.data?.toString())
                    if let errorType = error as? NetworkErrorTypes {
                        errorModel.setNetworkErrorTypes(types: errorType)
                    } else {
                        errorModel.setNetworkErrorTypes(types: NetworkErrorTypes.networkError)
                    }
                    fail(errorModel)
                }
            case .failure(let error):
                let errorModel = ErrorModel()
                errorModel.setDescription(description: error.localizedDescription)
                errorModel.setHttpErrorCode(errorCode: response.response?.statusCode)
                errorModel.setData(data: response.data?.toString())
                errorModel.setNetworkErrorTypes(types: NetworkErrorTypes.networkError)
                //NETWORK CANCELLATION
                if !errorModel.getDescription().isEmpty  && DownloadRequest.cancelledTag == errorModel.getDescription().lowercased(){
                    print("request cancelled with tag %@",self.getTag())
                    return
                }
                fail(errorModel)
            }
        }
    }
    
    // MARK: GET RESULT MODEL
    private func getResultModel(_ json: String?) throws -> DownloadResultModel<T> {
        if jsonKeys == nil || jsonKeys?.isEmpty == true {
            if isJSONArray(json) {
                let array = json?.toArray(type: [T].self)
                let resultModel = DownloadResultModel<T>()
                resultModel.setArrayModel(model: array, type: [T].self)
                resultModel.setJson(json: json)
                return resultModel
            } else {
                let resultModel = DownloadResultModel<T>()
                let object = json?.toObject(type: T.self)
                resultModel.setModel(model: object,type: T.self)
                resultModel.setJson(json: json)
                return resultModel
            }
        } else {
            guard let jsonDict = json?.toData() as? [String: Any] else {
                let resultModel = DownloadResultModel<T>()
                resultModel.setJson(json: json)
                return resultModel
            }
            
            var jsonData: Any?
            for jsonKey in jsonKeys! {
//                let jsonKeySplit = jsonKey.components(separatedBy: "/")
                let jsonKeySplit = jsonKey.split(separator: "/")
                if jsonKeySplit.count > 1 {
                    var dictionary: [String : Any]? = jsonDict
                    for splittedKey in jsonKeySplit {
                        dictionary = dictionary![splittedKey.description] as? [String: Any]
                    }
                    jsonData = dictionary
                } else {
                    if let jsonArray = jsonDict[jsonKey]  as? [Any] {
                        jsonData = jsonArray
                    } else {
                        jsonData = jsonDict[jsonKey] as? [String: Any]
                    }
                }
                
                if jsonData == nil {
                    if let str = jsonData as? String, str == "null" {
                        continue
                    }
                    continue
                } else {
                    break
                }
            }
            
            let resultModel = DownloadResultModel<T>()
            resultModel.setJson(json: json)
            
            if jsonData != nil && JSONSerialization.isValidJSONObject(jsonData!) {
                do {
                    let data = try JSONSerialization.data(withJSONObject: jsonData!, options: [])
                    if jsonData as? [Any] != nil {
                        let decoder = try JSONDecoder().decode([T].self, from: data)
                        resultModel.setArrayModel(model: decoder, type: [T].self)
                    } else {
                        let decoder = try JSONDecoder().decode(T.self, from: data)
                        resultModel.setModel(model: decoder, type: T.self)
                    }
                } catch let error {
                    print(error.localizedDescription)
                    throw NetworkErrorTypes.parseError
                }
            } else {
                throw NetworkErrorTypes.invalidJSON
            }
            
            return resultModel
        }
    }
    
    private func isJSONArray(_ jsonString: String?) -> Bool {
        let json = jsonString?.toData()
        var result = false
        var jsonData: Any?
        
        if jsonKeys == nil || jsonKeys?.isEmpty == true {
            jsonData = json
            if let _ = jsonData as? [Any] {
                result = true
            } else {
                result = false
            }
        } else {
            for jsonKey in jsonKeys! {
                let object = json as? [String: Any]
                jsonData = object?[jsonKey] as? [Any]
                if object != nil {
                    break
                } else {
                    continue
                }
            }
            if jsonData != nil && isJSONArray(jsonData as? String) {
                result = true
            }
        }
        return result
    }
    
    private func setSuccessStatusCodes<S: Sequence>(statusCode statusCodes: S) where S.Iterator.Element == Int {
        request.validate(statusCode: statusCodes)
    }
    
//    internal func setLearning(learning: NetworkLearning?) {
//        self.learning = learning
//    }
    
    
    public func setTimeout(_ timeout: Int) -> Self {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = TimeInterval(timeout)
        configuration.timeoutIntervalForRequest = TimeInterval(timeout)
        return self
    }
    static var cancelledTag: String { return "cancelled" }
   */
    

}
