//
//  ViewController.swift
//  IgniteHackathonGameTwo
//
//  Created by Varun Giridhar on 10/30/18.
//  Copyright © 2018 Varun Giridhar. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

enum BodyType:Int{
    
    case box = 1
    case ball = 2
    case donut = 4
    case pyramid = 8
}

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var box = SCNNode()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/Mainscene.scn")!
        setupscene()
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.scene.physicsWorld.contactDelegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        
    }
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        
        
        
    }
    func setupscene(){
        
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
        
            if( node.name == "box"){
                box = node
                let body = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node:box))
                box.physicsBody = body
                box.physicsBody?.restitution = 1
                box.position = SCNVector3(0, -2, -2)
                box.physicsBody?.categoryBitMask = BodyType.box.rawValue
                box.physicsBody?.collisionBitMask = BodyType.ball.rawValue
                box.physicsBody?.contactTestBitMask = BodyType.ball.rawValue


            }
        }
    }
    func addball(){
        guard let pointOfView = self.sceneView.pointOfView else{return}
        let transform:SCNMatrix4 = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let position = SCNVector3(location.x + orientation.x, location.y + orientation.y, location.z + orientation.z)
        let ball = SCNNode(geometry: SCNSphere(radius: 0.25))
        ball.position = position
        ball.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node:ball))
        ball.physicsBody = body
        ball.physicsBody?.categoryBitMask = BodyType.ball.rawValue
        ball.physicsBody?.collisionBitMask = BodyType.box.rawValue
        ball.physicsBody?.contactTestBitMask = BodyType.box.rawValue
        ball.name = "newball"
        body.restitution = 1
        ball.physicsBody?.applyForce(SCNVector3(orientation.x * 2, orientation.y * 2, orientation.z * 2), asImpulse: true)
        self.sceneView.scene.rootNode.addChildNode(ball)
    }

    @objc func handleTap(sender : UITapGestureRecognizer){
        addball()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }

    
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
