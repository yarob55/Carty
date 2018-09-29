//
//  Location.swift
//  Portal World
//
//  Created by يعرب المصطفى on 8/1/18.
//  Copyright © 2018 yarob. All rights reserved.
//

import Foundation
import ARKit

class Location{
    
    var type : LocationType!
    var dimensions : SCNVector3!
    var index : Int!
    var itemName : String!
    
    init(dimensions : SCNVector3, type : LocationType, index : Int, itemName : String)
    {
        self.dimensions = dimensions
        self.type = type
        self.index = index
        self.itemName = itemName
    }
    
    init(dimensions : SCNVector3, type : LocationType)
    {
        self.dimensions = dimensions
        self.type = type
    }
    
}

enum LocationType : String{
    case Red = "groceryLocation"
    case Yellow = "yellowLocation"
}
