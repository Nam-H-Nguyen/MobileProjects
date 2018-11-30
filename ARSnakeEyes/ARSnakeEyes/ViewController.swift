//
//  ViewController.swift
//  ARSnakeEyes
//
//  Created by NomNomNam on 11/29/18.
//  Copyright © 2018 Nam Nguyen. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    // Empty dice array initialized to SCNNode
    // Purpose: To spin all of the dice nodes all at once by add all dice nodes created into dice array
    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // See indicators as sceneView is trying to find feature points in AR to find the horizontal plane
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Makes the object displayed look not flat
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    //MARK: - App Life Cycle Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // World Tracking allows real augmented reality experience
        if ARWorldTrackingConfiguration.isSupported {
            // Condition is true only for A9 chips or above
            let configuration = ARWorldTrackingConfiguration()
            
            // Detect a horizontal plane, so objects can be placed on the ground instead
            // of floating in the middle of space
            configuration.planeDetection = .horizontal
            
            // Run the view's session
            sceneView.session.run(configuration)
        } else {
            // Condition is true only for chips below A9
            let configuration = AROrientationTrackingConfiguration()
            
            // Run the view's session
            sceneView.session.run(configuration)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - Dice Rendering Methods
    
    // Detect touches on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Do not require multi touch, only the first touch the user has made on the screen
        if let touch = touches.first {
            
            // Save the touch location from the sceneView
            let touchLocation = touch.location(in: sceneView)
            
            // Convert 2D touch onto the 3D anchor plane
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            // Print if touch location is within the hit bounding box
            if let hitResult = results.first {
                addDice(atLocation: hitResult)
            }
        }
    }
    
    // Swift external parameter = atLocation, internal parameter = location to make code
    // English structure makes more sense and expressive
    func addDice(atLocation location : ARHitTestResult) {
        // Already converted dae file to scn file
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        // Recursively look down the tree and include all child nodes of the root node
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            // Input in real world tracking positions where the diceNode will be
            diceNode.position = SCNVector3(
                // worldTransform is 4x4 matrix scale, rotation, position - the 4th column = position
                x: location.worldTransform.columns.3.x,
                // Without adding half of the diceNode's height (radius), the dice would in the middle of the grid plane due to the height being the height of the plane.
                y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                z: location.worldTransform.columns.3.z
            )
            
            // Append all of the diceNodes into the diceArray
            diceArray.append(diceNode)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
        }
    }
    
    // Rolls a single dice node
    func roll(dice: SCNNode) {
        // Randomize dice rolls along the x and z plane about its axis
        // Float.pi/2 will give you 90 degree rotations
        // arc4random of 4 will show 4 faces equally likely, showing numbers 1-4
        // Rotating along the y-axis won't change the face of the dice, so not needed
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        // Run as an animation with scene kit
        dice.runAction(
            // Multiply randomX by 5 to get more rotation spins (more life-like animation experience)
            SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.5)
        )
    }
    
    // Rolls all of the dice on the plane
    func rollAllDiceNodes() {
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    // When user tap on the refresh bar button, all the dices are rolled again
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAllDiceNodes()
    }
    
    // Detects when user finish shaking the device. When motion ends, all the dices are rolled
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAllDiceNodes()
    }
    
    // Remove all of the dice nodes created
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    //MARK: - ARSCNViewDelegateMethods
    
    // Use an anchor to anchor the object onto the horizontal plane in an AR Scene
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // Downcast anchor to be of ARPlaneAnchor data type. Else cannot downcast, return and escape out of function
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
    
        // Plane node receives return node from function call
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        
        // Add the plane node as a child node to all the previous nodes
        node.addChildNode(planeNode)

    }
    
    //MARK: - Plane Rendering Methods
    
    // External param = withPlaneAnchor, internal param = planeAnchor
    // Func: anchors nodes to the plane
    // Return: return SCNNode to be passed in as a child node
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        // Anchor is like a tile with width and height, takes in x and z metrics
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let planeNode = SCNNode()
        
        // Do not place object above the plane thus y = 0
        // Place the object's node in the center of the plane
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        
        // SCNPlane is a vertical plane, thus need to transform the vertical plane to horizontal plane by rotating 90 degrees
        // Metrics is in radians. Float.pi/2 is equivalent to saying 180 degrees divided by 2 or 1 pi radian divided by 2 which is 90 degrees
        // (+) is counter-clockwise so negative is clockwise
        // 1 on the x-axis parameter indicate rotating about x axis
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        // Show the gride plane on the plane node to better visualize the plane
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
        
        return planeNode
    }
}
