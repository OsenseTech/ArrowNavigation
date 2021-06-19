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
        
        
        
        return targetNode
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - Helper
    
    private func getPosition(from transform: simd_float4x4) -> SCNVector3 {
        let position = transform.columns.3
        return SCNVector3(x: position.x, y: position.y, z: position.z)
    }
    
    func setTargetPosition(imageAnchorPosition: SCNVector3) {
        let theta = calculateTheta(imageAnchorPosition: imageAnchorPosition)
        
        let targetOriginPosition = simd_float2(-2.0, 1.0)
        let targetTranslatedVector = rotateVector(targetOriginPosition, angle: theta)
        let targetPosition = SCNVector3(x: targetTranslatedVector.x, y: 0, z: -targetTranslatedVector.y)
        targetNode.position = targetPosition
    }
    
    func calculateTheta(imageAnchorPosition: SCNVector3) -> Double {
        let imageVector = simd_float2(1, 1)
        let arVector = simd_float2(imageAnchorPosition.x, imageAnchorPosition.z)
        
        let originVectorLength = simd_length(imageVector)
        let arVectorLength = simd_length(arVector)
        let adotb = imageVector.x * arVector.x + imageVector.y * arVector.y
        let theta = Double(acos( adotb / (originVectorLength * arVectorLength)))
        
        return theta
    }
    
    func rotateVector(_ vector: simd_float2, angle: Double) -> simd_float2 {
        let angle = Measurement(value: angle, unit: UnitAngle.degrees)
        let radians = Float(angle.converted(to: .radians).value)
        
        let rotationMatrix = makeRotationMatrix(angle: radians)
        let rotatedVector = vector * rotationMatrix
        
        return rotatedVector
    }
    
    /// - Parameter angle: in radians
    func makeRotationMatrix(angle: Float) -> simd_float2x2 {
        let rows = [
            simd_float2(cos(angle), -sin(angle)),
            simd_float2(sin(angle), cos(angle)),
        ]
        
        return float2x2(rows: rows)
    }
    
}

extension ViewController: ARSCNViewDelegate {
    
}

extension ViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        if let imageAnchor = anchors.first as? ARImageAnchor {
            let imageAnchorPosition = getPosition(from: imageAnchor.transform)
            
//            let node = SCNNode()
//            let box = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0)
//            node.geometry = box
//            node.position = imageAnchorPosition
//            node.addChildNode(targetNode)
            sceneView.scene.rootNode.addChildNode(targetNode)
            setTargetPosition(imageAnchorPosition: imageAnchorPosition)
            
            sceneView.pointOfView?.addChildNode(arrowNode)
        }
    }
    
}
