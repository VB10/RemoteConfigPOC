//
//  Config.swift
//  RemoteConfigPOC
//
//  Created by Veli Bacik on 6.02.2019.
//  Copyright © 2019 Veli Bacik. All rights reserved.
//

import Foundation
import Networking


struct Config : Serializable {
    
    let parameters : Parameters
    let version : Version
}
