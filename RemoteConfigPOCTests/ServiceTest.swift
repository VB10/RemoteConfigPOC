//
//  ServiceTest.swift
//  RemoteConfigPOCTests
//
//  Created by Veli Bacik on 12.02.2019.
//  Copyright © 2019 Veli Bacik. All rights reserved.
//

import Foundation
import XCTest
@testable import RemoteConfigPOC
class ServiceTest : XCTestCase {
    var service : BaseManager?
    let timeout: Double = 10
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        service = BaseManager.instance
    }
    /**
     Creates a configure data get  service call .
     
     - Parameter result function , fail function
     
     - Throws: `T model not Serializable`
     
     - Returns: 200 Succes return Configuration  .
     */
    
    func testCallService() {
        let expectation = XCTestExpectation(description: "request https://remoteconfigpoc.azurewebsites.net/api/config")
        service?.getServiceControl(success: { (result : Bool) in
            XCTAssertTrue(result)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: timeout)
    }
    
    
    
    /**
     Creates a test service call (have header params).
     
     - Parameter result function , fail function
     
     - Throws: `T model not Serializable
     Header value not equal server value`
     
     - Returns:async 200 Succes return string data  and 426 Fail return new client version model .
     */
    func testCallServiceWithHeader() {
        let expectation = XCTestExpectation(description: "request https://remoteconfigpoc.azurewebsites.net/api/config")
        service?.serviceCallWithHeader(version: "29", success: { (result) in
            XCTAssertTrue(result)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: timeout)
    }
    
}

