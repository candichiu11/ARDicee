//
//  ViewController.swift
//  ARDicee
//
//  Created by Candi Chiu on 25.02.22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
      //  self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Set the view's delegate
        sceneView.delegate = self
        
    //    let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
   //     let sphere = SCNSphere(radius: 0.1)
//
  //      let material = SCNMaterial()
      //  material.diffuse.contents = UIColor.red
  //      material.diffuse.contents = UIImage(named: "art.scnassets/8k_moon.jpeg")
      //  cube.materials = [material]
  //      sphere.materials = [material]
//
//        let node = SCNNode()
//        node.position = SCNVector3(0, 0, -0.5)
//       // node.geometry = cube
//        node.geometry = sphere
//
  //      sceneView.scene.rootNode.addChildNode(node)
//        sceneView.autoenablesDefaultLighting = true

//        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        print("AR WorldTracking Configuration: \(ARWorldTrackingConfiguration.isSupported)")
        print("AR Configuration: \(ARConfiguration.isSupported)")
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
//        if ARWorldTrackingConfiguration.isSupported {
//            configuration = ARWorldTrackingConfiguration()
//
//        } else {
//            configuration = AROrientationTrackingConfiguration()
//        }

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - Dice rendering Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
               addDice(atLocation: hitResult)
            }
        }
    }
    
    func addDice(atLocation location: ARHitTestResult) {
        
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(
                location.worldTransform.columns.3.x,
                location.worldTransform.columns.3.y + diceNode.boundingSphere.radius + 0.02,
                location.worldTransform.columns.3.z)
            
            diceArray.append(diceNode)
            sceneView.scene.rootNode.addChildNode(diceNode)
        }
    }
    
    func roll(dice: SCNNode) {
        let randomX = (Float(arc4random_uniform(4)) + 1) * (Float.pi/2)
        let randomZ = (Float(arc4random_uniform(4)) + 1) * (Float.pi/2)
        dice.runAction(SCNAction.rotateBy(
            x: CGFloat(randomX * 5),
            y: 0,
            z: CGFloat(randomZ * 5),
            duration: 0.5))
    }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func removeAll(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    //MARK: - ARSCNViewDelegateMethod
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        node.addChildNode(planeNode)
    }
    
   //MARK: - Plane Rendering Method

    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
    
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
    
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
    
        planeNode.geometry = plane
        return planeNode
    }
}
