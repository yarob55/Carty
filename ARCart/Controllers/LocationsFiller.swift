//
//  LocationFillers.swift
//  Portal World
//
//  Created by يعرب المصطفى on 8/1/18.
//  Copyright © 2018 yarob. All rights reserved.
//

import Foundation
import UIKit
import ARKit
class LocationsFiller
{
    static var filledLocations = [Location]()
    
    static func addLocations() -> [Location]
    {
        var locations = [Location]()
        let x:Double = 0
        let y:Double = 0
        
        
        //creating new location
//        let location = Location(dimensions: SCNVector3(-0.28737256, y, -6.6377), type: .Red, index : 1, itemName : "Tissues")
//        let location2 = Location(dimensions: SCNVector3(-1.89435, y, -7.13421), type: .Red, index : 2, itemName : "Chips")
//        let location3 = Location(dimensions: SCNVector3(9.23159, y, -9.813198), type: .Red, index : 3, itemName : "Tea")
//        let location4 = Location(dimensions: SCNVector3(7.66356, y, -1.514332), type: .Red, index : 4, itemName : "Honey")

        
//        let location = Location(dimensions: SCNVector3(-0.5, y, -0.6), type: .Red, index : 1, itemName : "Tissues")
//        let location2 = Location(dimensions: SCNVector3(0, y, -1.5), type: .Red, index : 2, itemName : "Chips")
//        let location3 = Location(dimensions: SCNVector3(0.5, y, -1), type: .Red, index : 3, itemName : "Tea")
//        let location4 = Location(dimensions: SCNVector3(1.2, y, 0), type: .Red, index : 4, itemName : "Honey")

        let location = Location(dimensions: SCNVector3(-0.5, y, -0.2), type: .Red, index : 1, itemName : "Tissues")
        let location2 = Location(dimensions: SCNVector3(0, y, -0.2), type: .Red, index : 2, itemName : "Chips")
        let location3 = Location(dimensions: SCNVector3(0.5, y, -0.2), type: .Red, index : 3, itemName : "Tea")
        let location4 = Location(dimensions: SCNVector3(0.7, y, -0.2), type: .Red, index : 4, itemName : "Honey")
        locations.append(location)
        locations.append(location2)
        locations.append(location3)
        locations.append(location4)
        return locations
    }
    
    
    static func fillLocations2()
    {
        let y:Double = 0
        let location = Location(dimensions: SCNVector3(-0.5, y, -0.6), type: .Red, index : 1, itemName : "Tissues")
        let location2 = Location(dimensions: SCNVector3(0, y, -1.5), type: .Red, index : 2, itemName : "Chips")
        let location3 = Location(dimensions: SCNVector3(0.5, y, -1), type: .Red, index : 3, itemName : "Tea")
        let location4 = Location(dimensions: SCNVector3(1.2, y, 0), type: .Red, index : 4, itemName : "Honey")
        
        LocationsFiller.filledLocations.append(location)
        LocationsFiller.filledLocations.append(location2)
        LocationsFiller.filledLocations.append(location3)
        LocationsFiller.filledLocations.append(location4)
    }
    
    
    
    
   

}
