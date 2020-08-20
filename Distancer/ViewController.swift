//
//  ViewController.swift
//  Distancer
//
//  Created by Jeremy Jacob on 4/15/20.
//  Copyright © 2020 Jeremy Jacob. All rights reserved.
//

import UIKit
import RealityKit
import ARKit
import Combine

extension ViewController: ARCoachingOverlayViewDelegate{
  
  // Called when the ARCoachingOverlayView is active and displayed
  func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) { }
  
  // Called when the ARCoachingOverlayView is not active and no longer displayer
  func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) { }
  
  // Called when tracking conditions are poor or session needs restarting
  func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) { }

}

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    var sceneObserver: Cancellable!
    private let guidanceOverlay = ARCoachingOverlayView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupARSession()
    }
    
    func setupARSession() {
        UIApplication.shared.isIdleTimerDisabled = true
        
        self.setOverlay(automatically: false, forDetectionType: .horizontalPlane)
        
        do {
            let ring = try ModelEntity.load(named: "ring")
            let anchor = AnchorEntity(plane: .horizontal)

            arView.scene.anchors.append(anchor)
            ring.scale = [1, 1, 1] * 0.006
            anchor.children.append(ring)

            sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self) { [unowned self] in self.updateScene(on: $0, object: ring) }
            
            enablePeopleOcclusion()
        } catch {
            fatalError("Failed to load asset")
        }
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            fatalError("People occlusion is not supported on this device.")
        }
        config.frameSemantics.insert(.personSegmentationWithDepth)
        print("People occlusion enabled")
        
        arView.session.run(config)
    }
    
    func setOverlay(automatically: Bool, forDetectionType goal: ARCoachingOverlayView.Goal){
      
        // Link the GuidanceOverlay to current session
        self.guidanceOverlay.session = self.arView.session
        self.guidanceOverlay.delegate = self
        self.arView.addSubview(self.guidanceOverlay)

        // Set to fill view
        NSLayoutConstraint.activate([
        NSLayoutConstraint(item:  guidanceOverlay, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
        NSLayoutConstraint(item:  guidanceOverlay, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0),
        NSLayoutConstraint(item:  guidanceOverlay, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
        NSLayoutConstraint(item:  guidanceOverlay, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        ])

        guidanceOverlay.translatesAutoresizingMaskIntoConstraints = false
        
        self.guidanceOverlay.activatesAutomatically = automatically
        self.guidanceOverlay.goal = goal
      
    }
    
    func updateScene(on event: SceneEvents.Update, object: Entity) {
        let cameraTransform = arView.cameraTransform.translation
        object.transform.translation = cameraTransform
    }
    
    func enablePeopleOcclusion() {
        
    }
}
