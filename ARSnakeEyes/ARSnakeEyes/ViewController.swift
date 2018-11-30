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

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // See indicators as sceneView is trying to find feature points in AR to find the horizontal plane
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
//        // Create a cube object (width, height, length, radius are in Meters)
//        let sphere = SCNSphere(radius: 0.2)
//
//        // Initialize a SCNMaterial
//        let material = SCNMaterial()
//
//        // Change base color of material to red
//        material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
//
//        // Array of materials contain the red material contents
//        sphere.materials = [material]
//
//        // Create node (points in 3-D space)
//        let node = SCNNode()
//
//        // X, Y, Z vector position
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
//
//        // Assign the node an object to display which is the cube
//        node.geometry = sphere
//
//        // Set the node to be the child of the root to be displayed on the sceneView
//        sceneView.scene.rootNode.addChildNode(node)
        
        // Makes the object displayed look not flat
        sceneView.autoenablesDefaultLighting = true
        
//        // Already converted dae file to scn file
//        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
//
//        // Recursively look down the tree and include all child nodes of the root node
//        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
//            diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1)
//
//            sceneView.scene.rootNode.addChildNode(diceNode)
//        }
        
        
    }
    
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
    
    // Detect touches on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Do not require multi touch, only the first touch the user has made on the screen
        if let touch = touches.first {
            
            // Save the touch location from the sceneView
            let touchLocation = touch.location(in: sceneView)
            
            // Convert 2D touch onto the 3D anchor plane
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            // If hit did touch existing plane, print that result
            if !results.isEmpty {
                print("Touched the plane")
            } else {
                print("Did not touch the plane")
            }
        }
    }
    
    // Use an anchor to anchor the object onto the horizontal plane in an AR Scene
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Check if anchor is on the AR plane
        if anchor is ARPlaneAnchor {
            // Set anchor datatype to ARPlaneAnchor
            let planeAnchor = anchor as! ARPlaneAnchor
            
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
            node.addChildNode(planeNode)
            
            
            
        } else {
            return
        }
    }
}
