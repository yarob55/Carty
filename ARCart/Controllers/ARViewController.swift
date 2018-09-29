//
//  ViewController.swift
//  Portal World
//
//  Created by يعرب المصطفى on 7/26/18.
//  Copyright © 2018 yarob. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Foundation


extension ARViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewStrings.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        
        cell.name.text = tableViewStrings[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
}


class ARViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tableViewStrings = [String]()
    lazy var headerView = tableView.tableHeaderView as! CurrentNextItemsView

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var detectionLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var nextItemLabel: UILabel!
    
    @IBOutlet weak var firstCheckImageView: UIImageView!
     @IBOutlet weak var secondCheckImageView: UIImageView!
     @IBOutlet weak var thirdCheckImageView: UIImageView!
     @IBOutlet weak var fourthCheckImageView: UIImageView!
    
    
    var counter = 0
    var success = false
    let regionRedius:Float = 0.3
    
    // MARK: ALL LOCATIONS
    var locations = [Location]()
    var currentLocationNode:SCNNode!
    var arrowNode:SCNNode!
    var firstNode : CustomNode!
    var secondNode : CustomNode!
    var thirdNode : CustomNode!
    var fourthNode : CustomNode!
    var currentNode : CustomNode!{
        willSet{
            if currentNode != nil{
                self.tableViewStrings.append(currentNode.itemName)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        }
        didSet{
            updateItemLabel()
            if currentNode != nil{
                currentNode.isHidden = false
                DispatchQueue.main.async {
                    self.headerView.firstLabel.text = self.currentNode.itemName
                }
            }else {
                DispatchQueue.main.async {
                    self.headerView.firstLabel.text = ""
                    let indexPath = NSIndexPath(item: self.tableViewStrings.count-1, section: 0)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    //d
                    self.lastAnimationForItemLabel()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        let indexPath = NSIndexPath(item: self.tableViewStrings.count-1, section: 0)
                        self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.top, animated: true)
                    }
                    
                }
            }
            
            
        }
    }
    var allNodes = [CustomNode]()
    var currentNodeIndex = 0
    
    var nodeIndex = 0
    
    var framesCounter = 0
    
    
    // MARK: LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locations = LocationsFiller.filledLocations
        tableView.delegate = self
        tableView.dataSource = self
        
        //set up the debugging options
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        //horizontal detection
        // Set the view's delegate
        sceneView.delegate = self
        
        //enabling the lights..
        sceneView.autoenablesDefaultLighting = true // TODO: THIS MIGHT BE REMOVED
        sceneView.automaticallyUpdatesLighting = true
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        //adding the arrow
        addArrowToTheScene()
        
        tableView.contentInset = UIEdgeInsets(top: 340, left: 0, bottom: 0, right: 0)
        setupHeader()
    }
    
    func setupHeader() {
        //headerView.firstLabel.text = tableViewStrings.first
        //headerView.secondLabel.text = tableViewStrings[1]
    }
    
    
    private func addArrowToTheScene()
    {
//        let boxGeometry = SCNBox(width: 0.01, height: 0.02, length: 0.03, chamferRadius: 0.01)
//        arrowNode = SCNNode(geometry: boxGeometry)
//        arrowNode.position = SCNVector3(0,0,0)
//        self.sceneView.scene.rootNode.addChildNode(arrowNode)
//
//        let position = SCNVector3(x: 0, y: 0, z: -2)
    }
    
    private func getCameraInfo(){ // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
//            let dir = SCNVector3(GLKMathRadiansToDegrees(-1 * mat.m31) , GLKMathRadiansToDegrees(-1 * mat.m32), GLKMathRadiansToDegrees(-1 * mat.m33)) // orientation of camera in world space
            
            let dir = SCNVector3(GLKMathRadiansToDegrees(frame.camera.eulerAngles.x), GLKMathRadiansToDegrees(frame.camera.eulerAngles.y), GLKMathRadiansToDegrees(frame.camera.eulerAngles.z))
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            print("\n Direction: \(dir)")
            DispatchQueue.main.async {
                self.detectionLabel.text = "position: \(pos), \n Direction: \(dir)"
                
            }
            
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    // MARK: HANDLING THE TAP
    @objc func handleTap(sender:UITapGestureRecognizer)
    {
        
        if counter == 0{
            counter = counter+1
            addLocationsToTheScene()
            
            let scene = sender.view as! ARSCNView
            let location = sender.location(in: scene)
            let hitTest = scene.hitTest(location, types: .existingPlaneUsingExtent)
            if !hitTest.isEmpty
            {
                //addPortal(hitTest: hitTest.first!)
           }
        }else
        {
            guard let currentFrame = sceneView.session.currentFrame else {return}
            let camera = currentFrame.camera
            let transform = camera.transform
            
            //1: make a new matrix (by default all of the values are 1s)
            var translationMatrix = matrix_identity_float4x4
            //set only the z value to be -0.1
            translationMatrix.columns.3.z = -0.1
            
            //multiply it with the current matrix that you have so only one value will be modified
            let modifiedMatrix = simd_mul(transform, translationMatrix)
            
            showOfferNode(matrix: modifiedMatrix)
            
        }
        
    }
    
    
    // MARK: OTHER METHODS
    //fill the locations in the scene
    private func makeRegionSphere(forNode node: SCNNode)
    {
        let sphere = SCNSphere(radius: CGFloat(regionRedius))
        sphere.firstMaterial?.diffuse.contents = UIColor.yellow
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.opacity = 0.16
        node.addChildNode(sphereNode)
        sphereNode.name = "sphere"
        sphereNode.position = SCNVector3(0,0,0)
    }
    
    
    
    private func addLocationsToTheScene()
    {
        for location in locations
        {
            let image = UIImage(named: (location.type?.rawValue)!)
            let plane = SCNPlane(width: 0.1, height: 0.1)
            plane.firstMaterial?.diffuse.contents = image
            let node = CustomNode()
            node.itemName = location.itemName
            node.geometry = plane
            node.position = location.dimensions
            self.sceneView.scene.rootNode.addChildNode(node)
            node.constraints = [SCNBillboardConstraint()]
            addAnimation(node: node)
            self.sceneView.scene.rootNode.addChildNode(node)
            makeRegionSphere(forNode: node)
            node.isHidden = true
            
            //setting the nodes references to race them
            if location.index == 1{
                firstNode = node
            }
            else if location.index == 2{
                secondNode = node
            }
            else if location.index == 3{
                thirdNode = node
            }else if location.index == 4{
                fourthNode = node
            }
            
        }
        
        allNodes = [firstNode, secondNode, thirdNode, fourthNode]
        currentNodeIndex = 0
        currentNode = allNodes[currentNodeIndex]
    }
    

    
    //fill the labels in the scene
//    private func makeDistanceLabelOfLocatons()
//    {
//
//        let rect = CGRect(x: 0, y: 0, width: 500, height: 100)
//
//        for location in locations
//        {
//            let view = PopupMessageView(frame: rect)
//            let plane = SCNPlane(width: 0.07, height: 0.033)
//            plane.firstMaterial?.diffuse.contents = view
//            let node = SCNNode(geometry: plane)
//            node.position = location.dimensions
//            node.position.y = location.dimensions.y - 0.05
//            node.constraints = [SCNBillboardConstraint()]
//            self.sceneView.scene.rootNode.addChildNode(node)
//        }
//
//    }
    
    
    private func replaceNodeWithSuccess()
    {
        guard let _ = currentLocationNode else {return}
        let dimensions = currentLocationNode.position
        currentLocationNode.removeFromParentNode()
        currentLocationNode = nil
        makeSuccessNode(position: dimensions)
    }
    
    private func makeSuccessNode(position : SCNVector3)
    {
        let plane = SCNPlane(width: 0.07, height: 0.07)
        plane.firstMaterial?.diffuse.contents = UIImage(named: "checked")
        let node = SCNNode(geometry: plane)
        node.position = position
        node.geometry?.firstMaterial?.isDoubleSided = true
//        node.constraints = [SCNBillboardConstraint()]
        node.opacity = 0
        
        //enter
        let fadeInAction = SCNAction.fadeIn(duration: 0.5)
        let hoverUp = SCNAction.moveBy(x: 0, y: 0.03, z: 0, duration: 0.6)
        let hoverAndFadeIn = SCNAction.group([fadeInAction,hoverUp])
        
        //exit
        let fadeOutAction = SCNAction.fadeOut(duration: 0.5)
        let hoverDown = SCNAction.moveBy(x: 0, y: -0.03, z: 0, duration: 0.6)
        let scale = SCNAction.scale(by: 1.5, duration: 0.6)
        let hoverAndFadeOut = SCNAction.group([fadeOutAction, hoverDown])
        let scaleAndFadeOut = SCNAction.group([fadeOutAction, scale])
        
        
        let rotationAction = SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi), z: 0, duration: 1)
        let repeatRotation = SCNAction.repeat(rotationAction, count: 2)
        let actionSequence = SCNAction.sequence([hoverAndFadeIn, repeatRotation, scaleAndFadeOut])
        node.runAction(actionSequence) {
            
        }
        self.sceneView.scene.rootNode.addChildNode(node)
        
    }
    
    /////////////
    func addAnimation(node: SCNNode) {
        let hoverUp = SCNAction.moveBy(x: 0, y: 0.03, z: 0, duration: 0.6)
        let hoverDown = SCNAction.moveBy(x: 0, y: -0.03, z: 0, duration: 0.6)
        let hoverSequence = SCNAction.sequence([hoverUp, hoverDown])
        let repeatForever = SCNAction.repeatForever(hoverSequence)
        node.runAction(repeatForever)
    }
    
    
    
    //this is used to send networking request
    private func sendArrivalRequest()
    {
//        Service.arrival { (error) in
//            print("done")
//        }
    }
    
    // MARK: DELEGATED METHODS....
    func updateArrowDirection()
    {
        //guard currentNode != nil else {return}
        let currentNodePosition = SCNVector3(-1,0,-0.5)
        let angle = atan(currentNodePosition.z/currentNodePosition.x)
        
        DispatchQueue.main.async
        {
            UIView.animate(withDuration: 1, animations: {
                CGAffineTransform(rotationAngle: CGFloat(angle))
            })
            
        }
        
    }
    
    
    private func rotateArrowBy(angleDegrees : Float)
    {
        DispatchQueue.main.async {
            let angle = GLKMathDegreesToRadians(angleDegrees)
            
            self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(angleDegrees*1.8))
        }
    }
    
    var deltaTime = TimeInterval()
    var lastUpdateTime = TimeInterval()
    
    // MARK: RENDERrrr METHOD
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        deltaTime = time - lastUpdateTime
        if deltaTime>0.25
        {
//            DispatchQueue.main.async {
//                self.detectionLabel.text = "\(self.sceneView.pointOfView?.position)"
//            }
            
            guard let pointOfView = renderer.pointOfView else {return}
            guard currentNode != nil else {return}
        
            let trackedNode = currentNode!
            let isVisible = renderer.isNode(trackedNode, insideFrustumOf: pointOfView)
            
            // Translate node to camera space
            let nodeInCameraSpace = sceneView.scene.rootNode.convertPosition(trackedNode.position, to: pointOfView)
            let isCentered = isVisible && (nodeInCameraSpace.x < 0.1) && (nodeInCameraSpace.y < 0.1)
            let isOnTheRight = isVisible && (nodeInCameraSpace.x > 0.1)
            
            rotateArrowBy(angleDegrees: nodeInCameraSpace.x)
            print("\n\n\n\n///////////")
            if isCentered{
                print("centered")
            }else if isOnTheRight{
                print("on the right")
            }else{
                print("on the left")
            }
            lastUpdateTime = time
            
            
            framesCounter = framesCounter + 1
            if framesCounter % 100 == 0
            {
                getCameraInfo()
                updateArrowDirection()
            }
        
        
        guard let camera = sceneView.session.currentFrame?.camera else {return}
        
        guard firstNode != nil, secondNode != nil, thirdNode != nil, fourthNode != nil else {return}
        
        //camera's position
        let cameraXPosition = camera.transform.columns.3.x
        let cameraZPosition = camera.transform.columns.3.z
        
        //first node positions
        let firstNodeXPosition = firstNode.transform.m41
        let firstNodeZPosition = firstNode.transform.m43
        
        //second node positions
        let secondNodeXPosition = secondNode.transform.m41
        let secondNodeZPosition = secondNode.transform.m43
        
        //third node positions
        let thirdNodeXPosition = thirdNode.transform.m41
        let thirdNodeZPosition = thirdNode.transform.m43
        
        //third node positions
        let fourthNodeXPosition = fourthNode.transform.m41
        let fourthNodeZPosition = fourthNode.transform.m43
        
        
        
        //first node position found
        if abs(cameraXPosition - firstNodeXPosition) <= regionRedius && abs(cameraZPosition - firstNodeZPosition) <= regionRedius && firstNode.isChecked == false && !firstNode.isHidden
        {
            firstNode.isChecked = true
            let dimensions = firstNode.position
            firstNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
            let sphere = firstNode.childNode(withName: "sphere", recursively: false)
            sphere?.removeFromParentNode()
            makeSuccessNode(position: dimensions)
            updateItemName()
        }
        
        
        //second node position found
        if abs(cameraXPosition - secondNodeXPosition) <= regionRedius && abs(cameraZPosition - secondNodeZPosition) <= regionRedius && secondNode.isChecked == false && !secondNode.isHidden
        {
            secondNode.isChecked = true
            let dimensions = secondNode.position
            secondNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
            let sphere = secondNode.childNode(withName: "sphere", recursively: false)
            sphere?.removeFromParentNode()
            makeSuccessNode(position: dimensions)
            updateItemName()
        }
        
        
        //third node position found
        if abs(cameraXPosition - thirdNodeXPosition) <= regionRedius && abs(cameraZPosition - thirdNodeZPosition) <= regionRedius && thirdNode.isChecked == false && !thirdNode.isHidden
        {
            thirdNode.isChecked = true
            let dimensions = thirdNode.position
            thirdNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
            let sphere = thirdNode.childNode(withName: "sphere", recursively: false)
            sphere?.removeFromParentNode()
            makeSuccessNode(position: dimensions)
            updateItemName()
        }
        
        
        //fourth
        if abs(cameraXPosition - fourthNodeXPosition) <= regionRedius && abs(cameraZPosition - fourthNodeZPosition) <= regionRedius && fourthNode.isChecked == false && !fourthNode.isHidden
        {
            fourthNode.isChecked = true
            let dimensions = fourthNode.position
            fourthNode.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
            let sphere = fourthNode.childNode(withName: "sphere", recursively: false)
            sphere?.removeFromParentNode()
            makeSuccessNode(position: dimensions)
            updateItemName()
        }
        
        
        
    }
        
    }
    
    
    private func showOfferNode(matrix : simd_float4x4)
    {
        let image = #imageLiteral(resourceName: "navigator")
        let node = SCNNode()
        node.geometry?.firstMaterial?.diffuse.contents = image
//        node.position = position
        node.simdTransform = matrix
        self.sceneView.pointOfView?.addChildNode(node)
    }
    
    private func updateItemName()
    {
        //updating the current Node
        currentNodeIndex = currentNodeIndex + 1
        animateImageView()
        if currentNodeIndex < allNodes.count{
            currentNode = allNodes[currentNodeIndex]
            
        }else{
            currentNode = nil
        }
    }
    
    private func updateItemLabel()
    {
        DispatchQueue.main.async {
            let screenWidth = self.view.frame.width
            let screenHeight = self.view.frame.height
            
            //animating the label
            UIView.animate(withDuration: 0.7, animations: {
                self.nextItemLabel.transform = CGAffineTransform(translationX: -screenWidth, y: 0)
            }, completion: { (comp) in
//                self.nextItemLabel.text = self.currentNode.itemName
                self.nextItemLabel.text = "\(self.currentNodeIndex)/\(self.allNodes.count)"
                self.nextItemLabel.transform = CGAffineTransform.identity.concatenating(CGAffineTransform(translationX: screenWidth, y: 0))
                UIView.animate(withDuration: 0.7, animations: {
                    self.nextItemLabel.transform = CGAffineTransform.identity
                })
            })
            
           
        }
        
        
    }
    
    private func lastAnimationForItemLabel()
    {
        let screenWidth = self.view.frame.width
        let screenHeight = self.view.frame.height
        
        //animating the label
        UIView.animate(withDuration: 0.7, animations: {
            self.nextItemLabel.transform = CGAffineTransform(translationX: -screenWidth, y: 0)
        }, completion: { (comp) in
            //                self.nextItemLabel.text = self.currentNode.itemName
            self.nextItemLabel.text = "Done"
            self.nextItemLabel.transform = CGAffineTransform.identity.concatenating(CGAffineTransform(translationX: screenWidth, y: 0))
            UIView.animate(withDuration: 0.7, animations: {
                self.nextItemLabel.transform = CGAffineTransform.identity
            })
        })
    }
    
    
    private func animateImageView()
    {
        DispatchQueue.main.async {
            var imageView = UIImageView()
            if self.currentNodeIndex == 1
            {
                imageView = self.firstCheckImageView
            }
            else if self.currentNodeIndex == 2
            {
                imageView = self.secondCheckImageView
            }
            else if self.currentNodeIndex == 3
            {
                imageView = self.thirdCheckImageView
            }
            else if self.currentNodeIndex == 4
            {
                imageView = self.fourthCheckImageView
            }
        
            imageView.alpha = 0
            imageView.isHidden = false
        
            UIView.animate(withDuration: 0.5, animations: {
                imageView.alpha = 1
            })
        }
        
    }
    
    
    
    private func getTheDistanceToNode(node : SCNNode, xpos : Double, zpos : Double) -> Int
    {
        let nodeXPosition = Double(node.transform.m41)
        let nodeZPosition = Double(node.transform.m43)
//        let nodeSquaredSummDistance = (pow(nodeXPosition - xpos), pow(nodeZPosition - zpos))
        let nodeSquaredSummDistance = 0
        return nodeSquaredSummDistance
    }
    
    private func min(first : Double, second : Double) -> Double
    {
        if first >= second{
            return first
        }
        return second
    }
    
    
    
    

}
