//
//  ARView.swift
//  walkMedfordiOS
//
//  Created by user150397 on 2/1/19.
//  Copyright © 2019 walkMedford. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

struct ImageInformation {
    let name: String
    let description: String
    let image: UIImage
}

class ARView: UIViewController, ARSKViewDelegate {
    @IBOutlet weak var sceneView: ARSKView!
    var selectedImage : ImageInformation?
    
    let images = ["Notebook" : ImageInformation(name: "Notebook", description: "A Normal Notebook", image: UIImage(named: "Notebook")!)]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    
    // MARK: - ARSKViewDelegate
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        
        if let imageAnchor = anchor as? ARImageAnchor,
            let referenceImageName = imageAnchor.referenceImage.name,
            let scannedImage =  self.images[referenceImageName] {
            
            self.selectedImage = scannedImage
            
            self.performSegue(withIdentifier: "showImageInformation", sender: self)
            
            return imageSeenMarker()
        }
        
        return nil
    }
    
    private func imageSeenMarker() -> SKLabelNode {
        let labelNode = SKLabelNode(text: "✅")
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        
        return labelNode
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageInformation"{
            if let imageInformationVC = segue.destination as? ImageInformationViewController,
                let actualSelectedImage = selectedImage {
                imageInformationVC.imageInformation = actualSelectedImage
            }
        }
    }
}
    /*
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARImageTrackingConfiguration()
        
        if let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) {
            configuration.trackingImages = trackingImages
            configuration.maximumNumberOfTrackedImages = 1
        }
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor {
            let size = imageAnchor.referenceImage.physicalSize
            let plane = SCNPlane(width: size.width, height: size.height)
            plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
            plane.cornerRadius = 0.005
            let planeNode = SCNNode(geometry: plane)
            node.addChildNode(planeNode)
        }
        
        return node
    }*/
