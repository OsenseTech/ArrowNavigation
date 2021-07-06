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
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let targetNode = SCNNode()
        targetNode.geometry = box
        
        return targetNode
    }()
    
    private var imageAnchorNode: SCNNode!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        #if DEBUG
        sceneView.debugOptions = [.showFeaturePoints, .showCameras]
        sceneView.showsStatistics = true
        #endif
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
    
    private func getPosition(anchor: ARImageAnchor) -> SCNVector3 {
        let position = anchor.transform.columns.3
        return SCNVector3(x: position.x, y: position.y, z: position.z)
    }
    
    func setTargetPosition(imageAnchorPosition: SCNVector3) {
        let arVector = simd_float2(imageAnchorPosition.x, imageAnchorPosition.z)
        let imageVector = simd_float2(-1, -1)
        let theta = calculateTheta(aVector: imageVector, bVector: arVector)
        let (adjustedTheta, _) = adjustTheta(angle: theta, arVector: arVector, imageVector: imageVector)
        
        let targetOriginPosition: SIMD2<Float> = SIMD2(-2, -1)
        let targetTranslatedVector = rotateVector(targetOriginPosition, angle: adjustedTheta)
        let targetPosition = SCNVector3(x: targetTranslatedVector.x, y: imageAnchorPosition.y, z: targetTranslatedVector.y)
        
        targetNode.position = targetPosition
    }
    
    func calculateTheta(aVector: simd_float2, bVector: simd_float2) -> Float {
        let aVectorLength = simd_length(aVector)
        let bVectorLength = simd_length(bVector)
        let adotb = aVector.x * bVector.x + aVector.y * bVector.y
        let theta = acos(adotb / (aVectorLength * bVectorLength))
        
        return theta
    }
    
    func adjustTheta(angle: Float, arVector: simd_float2, imageVector: simd_float2) -> (Float, Bool) {
        let rotatedImageVector = rotateVector(imageVector, angle: angle)
        
        let sameDirection: Bool
        let accurate: Bool
        if arVector == rotatedImageVector {
            sameDirection = true
            accurate = true
        } else {
            let theta = calculateTheta(aVector: rotatedImageVector, bVector: arVector)
            
            if theta == 0 {
                sameDirection = true
                accurate = true
            } else if theta / angle == 2 {
                sameDirection = false
                accurate = true
            } else {
                sameDirection = false
                accurate = false
            }
        }
        
        let adjustedTheta: Float
        if sameDirection {
            adjustedTheta = angle
        } else {
            adjustedTheta = -angle
        }
        
        return (adjustedTheta, accurate)
    }
    
    func rotateVector(_ vector: SIMD2<Float>, angle: Float) -> SIMD2<Float> {
        let rotationMatrix = makeRotationMatrix(angle: angle)
        let rotatedVector = rotationMatrix * vector
        
        return rotatedVector
    }
    
    /// - Parameter angle: in radians
    func makeRotationMatrix(angle: Float) -> simd_float2x2 {
        let columns = (
            simd_float2(cos(angle), -sin(angle)),
            simd_float2(sin(angle), cos(angle))
        )
        
        return float2x2(columns: columns)
    }
    
    func makeBox(position: SCNVector3) -> SCNNode {
        let node = SCNNode()
        let sphere = SCNSphere(radius: 0.05)
        node.geometry = sphere
        node.position = position
        
        return node
    }
}

extension ViewController: ARSCNViewDelegate {
    
}

extension ViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        if let imageAnchor = anchors.first as? ARImageAnchor {
            let imageAnchorPosition = getPosition(anchor: imageAnchor)
            imageAnchorNode = makeBox(position: imageAnchorPosition)
            sceneView.scene.rootNode.addChildNode(imageAnchorNode)
            
            sceneView.scene.rootNode.addChildNode(makeBox(position: SCNVector3(0, 0, 0)))
            sceneView.scene.rootNode.addChildNode(makeBox(position: SCNVector3(0.5, 0, 0)))
            sceneView.scene.rootNode.addChildNode(makeBox(position: SCNVector3(0, 1, 0)))
            sceneView.scene.rootNode.addChildNode(makeBox(position: SCNVector3(0, 0, 1)))
            
            setTargetPosition(imageAnchorPosition: imageAnchorPosition)
            sceneView.scene.rootNode.addChildNode(targetNode)
            
            sceneView.pointOfView?.addChildNode(arrowNode)
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
                let position = getPosition(anchor: imageAnchor)
                imageAnchorNode.position = position
                
                setTargetPosition(imageAnchorPosition: position)
            }
        }
    }
    
}
