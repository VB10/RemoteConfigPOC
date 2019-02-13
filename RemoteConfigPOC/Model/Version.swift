//
//  Version.swift
//  RemoteConfigPOC
//
//  Created by Veli Bacik on 6.02.2019.
//  Copyright © 2019 Veli Bacik. All rights reserved.
//

import Foundation
import Networking

struct Version : Serializable {
    
    let versionNumber : String
    let updateTime: String
    let updateOrigin : String
    let updateType: String
}
