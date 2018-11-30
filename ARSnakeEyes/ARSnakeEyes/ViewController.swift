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
        
        // Create a cube object (width, height, length, radius are in Meters)
        let sphere = SCNSphere(radius: 0.2)
        
        // Initialize a SCNMaterial
        let material = SCNMaterial()
        
        // Change base color of material to red
        material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
        
        // Array of materials contain the red material contents
        sphere.materials = [material]
        
        // Create node (points in 3-D space)
        let node = SCNNode()
        
        // X, Y, Z vector position
        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
        
        // Assign the node an object to display which is the cube
        node.geometry = sphere
        
        // Set the node to be the child of the root to be displayed on the sceneView
        sceneView.scene.rootNode.addChildNode(node)
        
        // Makes the object displayed look not flat
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // World Tracking allows real augmented reality experience
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
