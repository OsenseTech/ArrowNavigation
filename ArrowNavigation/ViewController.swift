//
//  ViewController.swift
//  ArrowNavigation
//
//  Created by 蘇健豪 on 2021/5/31.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    private lazy var arrowNode: SCNNode = {
        let scene = SCNScene(named: "art.scnassets/arrow.scn")!
        let node = scene.rootNode
        node.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
        node.position = SCNVector3(x: 0, y: -1.5, z: -5)
        
        let constraint = SCNLookAtConstraint(target: targetNode)
        node.constraints = [constraint]
        
        return node
    }()
    
    private lazy var targetNode: SCNNode = {
        let box = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0)
        let targetNode = SCNNode()
        targetNode.geometry = box
        targetNode.position = SCNVector3(x: -3, y: 0, z: -3)
        
        return targetNode
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Set the scene to the view
        sceneView.scene.rootNode.addChildNode(targetNode)
        sceneView.pointOfView?.addChildNode(arrowNode)
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
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
}

extension ViewController: ARSCNViewDelegate {
    
}

extension ViewController: ARSessionDelegate {
    
}
