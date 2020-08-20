//
//  ViewController.swift
//  Social Distancing
//
//  Created by Jeremy Jacob on 4/6/20.
//  Copyright © 2020 Jeremy Jacob. All rights reserved.
//

import UIKit
import RealityKit
import ARKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    var sceneObserver: Cancellable!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let ring = try ModelEntity.load(named: "ring")

            let anchor = AnchorEntity(plane: .horizontal)

            arView.scene.anchors.append(anchor)

            ring.scale = [1, 1, 1] * 0.006
            anchor.children.append(ring)

            sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self) { [unowned self] in self.updateScene(on: $0) }
        } catch {
            fatalError("Failed to load asset")
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.togglePeopleOcclusion()
    }
    
    func updateScene(on event: SceneEvents.Update) {
        let cameraTransform = arView.cameraTransform.translation
        arView.scene.anchors[0].children[0].transform.translation = cameraTransform
    }
    
    fileprivate func togglePeopleOcclusion() {
        guard let config = arView.session.configuration as? ARWorldTrackingConfiguration else {
            fatalError("Unexpectedly failed to get the configuration.")
        }
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            fatalError("People occlusion is not supported on this device.")
        }
        switch config.frameSemantics {
        case [.personSegmentationWithDepth]:
            config.frameSemantics.remove(.personSegmentationWithDepth)
            print("People occlusion off")
        default:
            config.frameSemantics.insert(.personSegmentationWithDepth)
            print("People occlusion on")
        }
        arView.session.run(config)
    }
    
}
