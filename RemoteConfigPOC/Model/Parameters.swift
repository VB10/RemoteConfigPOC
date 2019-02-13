//
//  Paramaters.swift
//  RemoteConfigPOC
//
//  Created by Veli Bacik on 11.02.2019.
//  Copyright © 2019 Veli Bacik. All rights reserved.
//

import Foundation
import Networking
struct Parameters : Serializable  {
    let title : Description?
    let description : Description?
    let website : Description?
}
struct Description: Serializable {
    let defaultValue: DefaultValue?
}
struct DefaultValue: Serializable {
    let value: String?
}
