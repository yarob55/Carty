//
//  CustomNode.swift
//  ARCart
//
//  Created by يعرب المصطفى on 9/28/18.
//  Copyright © 2018 yarob. All rights reserved.
//

import UIKit
import SceneKit

class CustomNode: SCNNode {
    
    var isChecked = false
    var itemName : String = ""
    
    func isNearCamera()
    {
        
    }
    
    override init()
    {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
