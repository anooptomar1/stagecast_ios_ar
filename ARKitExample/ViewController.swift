/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import Foundation
import SceneKit
import UIKit
import Photos

import Vision

class ViewController: UIViewController, ARSCNViewDelegate, SCNSceneRendererDelegate {
	
    // MARK: - Main Setup & View Controller methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupScene()
        
        if let worldSessionConfig = sessionConfig as? ARWorldTrackingConfiguration{//ARWorldTrackingSessionConfiguration{
            worldSessionConfig.planeDetection = .horizontal
            session.run(worldSessionConfig, options: [.resetTracking, .removeExistingAnchors])
        }
        
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Prevent the screen from being dimmed after a while.
		UIApplication.shared.isIdleTimerDisabled = true
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		session.pause()
	}
	
    // MARK: - ARKit / ARSCNView
    let session = ARSession()
    let sessionConfig = ARWorldTrackingConfiguration()
	/*var sessionConfig: ARSessionConfiguration = ARWorldTrackingSessionConfiguration()
	var use3DOFTracking = false {
		didSet {
			if use3DOFTracking {
				sessionConfig = ARSessionConfiguration()
			}
			sessionConfig.isLightEstimationEnabled = UserDefaults.standard.bool(for: .ambientLightEstimation)
			session.run(sessionConfig)
		}
	}*/
    
    
    
	var use3DOFTrackingFallback = false
    @IBOutlet var sceneView: ARSCNView!
	var screenCenter: CGPoint?
    
    func setupScene() {
        // set up sceneView
        sceneView.delegate = self
        sceneView.session = session
		sceneView.antialiasingMode = .multisampling4X
		sceneView.automaticallyUpdatesLighting = false
		
		sceneView.preferredFramesPerSecond = 60
		sceneView.contentScaleFactor = 1.3
		//sceneView.showsStatistics = true
		
		enableEnvironmentMapWithIntensity(25.0)
		
		DispatchQueue.main.async {
			self.screenCenter = self.sceneView.bounds.mid
		}
		
		if let camera = sceneView.pointOfView?.camera {
			camera.wantsHDR = true
			camera.wantsExposureAdaptation = true
			camera.exposureOffset = -1
			camera.minimumExposure = -1
		}
    }
	
	func enableEnvironmentMapWithIntensity(_ intensity: CGFloat) {
		if sceneView.scene.lightingEnvironment.contents == nil {
			if let environmentMap = UIImage(named: "Models.scnassets/sharedImages/environment_blur.exr") {
				sceneView.scene.lightingEnvironment.contents = environmentMap
			}
		}
		sceneView.scene.lightingEnvironment.intensity = intensity
	}
	
    
    
    // MARK: - ARSCNViewDelegate
	
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
		
		DispatchQueue.main.async {
            guard let currentFrame = self.sceneView.session.currentFrame else {
                return
            }
            
            for node in self.nodes {
                node.placeObject(currentFrame: currentFrame)
            }
			
			// If light estimation is enabled, update the intensity of the model's lights and the environment map
			if let lightEstimate = self.session.currentFrame?.lightEstimate {
				self.enableEnvironmentMapWithIntensity(lightEstimate.ambientIntensity / 40)
			} else {
				self.enableEnvironmentMapWithIntensity(25)
			}
		}
	}
	
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                
            }
        }
    }
	
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                
            }
        }
    }
	
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                
            }
        }
    }
	
	var trackingFallbackTimer: Timer?

	
	
    func session(_ session: ARSession, didFailWithError error: Error) {

        guard let arError = error as? ARError else { return }

        let nsError = error as NSError
		var sessionErrorMsg = "\(nsError.localizedDescription) \(nsError.localizedFailureReason ?? "")"
		if let recoveryOptions = nsError.localizedRecoveryOptions {
			for option in recoveryOptions {
				sessionErrorMsg.append("\(option).")
			}
		}

        let isRecoverable = (arError.code == .worldTrackingFailed)
		if isRecoverable {
			sessionErrorMsg += "\nYou can try resetting the session or quit the application."
		} else {
			sessionErrorMsg += "\nThis is an unrecoverable error that requires to quit the application."
		}
		
        //TODO: Error message
	}
	
		
	func sessionInterruptionEnded(_ session: ARSession) {
		session.run(sessionConfig, options: [.resetTracking, .removeExistingAnchors])
		restartExperience(self)
	}
	
    // MARK: - Ambient Light Estimation
	
	func toggleAmbientLightEstimation(_ enabled: Bool) {
		
        if enabled {
			if !sessionConfig.isLightEstimationEnabled {
				// turn on light estimation
				sessionConfig.isLightEstimationEnabled = true
				session.run(sessionConfig)
			}
        } else {
			if sessionConfig.isLightEstimationEnabled {
				// turn off light estimation
				sessionConfig.isLightEstimationEnabled = false
				session.run(sessionConfig)
			}
        }
    }

    
	
	
	var dragOnInfinitePlanesEnabled = false
	
	func worldPositionFromScreenPosition(_ position: CGPoint,
	                                     objectPos: SCNVector3?,
	                                     infinitePlane: Bool = false) -> (position: SCNVector3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
		
		// -------------------------------------------------------------------------------
		// 1. Always do a hit test against exisiting plane anchors first.
		//    (If any such anchors exist & only within their extents.)
		
		let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
		if let result = planeHitTestResults.first {
			
			let planeHitTestPosition = SCNVector3.positionFromTransform(result.worldTransform)
			let planeAnchor = result.anchor
			
			// Return immediately - this is the best possible outcome.
			return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
		}
		
		// -------------------------------------------------------------------------------
		// 2. Collect more information about the environment by hit testing against
		//    the feature point cloud, but do not return the result yet.
		
		var featureHitTestPosition: SCNVector3?
		var highQualityFeatureHitTestResult = false
		
		let highQualityfeatureHitTestResults = sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)
		
		if !highQualityfeatureHitTestResults.isEmpty {
			let result = highQualityfeatureHitTestResults[0]
			featureHitTestPosition = result.position
			highQualityFeatureHitTestResult = true
		}
		
		// -------------------------------------------------------------------------------
		// 3. If desired or necessary (no good feature hit test result): Hit test
		//    against an infinite, horizontal plane (ignoring the real world).
		
		if (infinitePlane && dragOnInfinitePlanesEnabled) || !highQualityFeatureHitTestResult {
			
			let pointOnPlane = objectPos ?? SCNVector3Zero
			
			let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
			if pointOnInfinitePlane != nil {
				return (pointOnInfinitePlane, nil, true)
			}
		}
		
		// -------------------------------------------------------------------------------
		// 4. If available, return the result of the hit test against high quality
		//    features if the hit tests against infinite planes were skipped or no
		//    infinite plane was hit.
		
		if highQualityFeatureHitTestResult {
			return (featureHitTestPosition, nil, false)
		}
		
		// -------------------------------------------------------------------------------
		// 5. As a last resort, perform a second, unfiltered hit test against features.
		//    If there are no features in the scene, the result returned here will be nil.
		
		let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
		if !unfilteredFeatureHitTestResults.isEmpty {
			let result = unfilteredFeatureHitTestResults[0]
			return (result.position, nil, false)
		}
		
		return (nil, nil, false)
	}
	
	// Use average of recent virtual object distances to avoid rapid changes in object scale.
	var recentVirtualObjectDistances = [CGFloat]()
	


   
	
	
	@IBOutlet weak var restartExperienceButton: UIButton!
	var restartExperienceButtonIsEnabled = true
	
	@IBAction func restartExperience(_ sender: Any) {
		
		
		DispatchQueue.main.async {
			self.restartExperienceButtonIsEnabled = false
			
			
			self.restartExperienceButton.setImage(#imageLiteral(resourceName: "restart"), for: [])
			
			// Disable Restart button for five seconds in order to give the session enough time to restart.
			DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
				self.restartExperienceButtonIsEnabled = true
			})
		}
	}
	
	@IBOutlet weak var screenshotButton: UIButton!
	
	@IBAction func takeScreenshot() {
		guard screenshotButton.isEnabled else {
			return
		}
		
		let takeScreenshotBlock = {
			UIImageWriteToSavedPhotosAlbum(self.sceneView.snapshot(), nil, nil, nil)
			DispatchQueue.main.async {
				// Briefly flash the screen.
				let flashOverlay = UIView(frame: self.sceneView.frame)
				flashOverlay.backgroundColor = UIColor.white
				self.sceneView.addSubview(flashOverlay)
				UIView.animate(withDuration: 0.25, animations: {
					flashOverlay.alpha = 0.0
				}, completion: { _ in
					flashOverlay.removeFromSuperview()
				})
			}
		}
		
		switch PHPhotoLibrary.authorizationStatus() {
		case .authorized:
			takeScreenshotBlock()
		case .restricted, .denied:
			let title = "Photos access denied"
			let message = "Please enable Photos access for this application in Settings > Privacy to allow saving screenshots."
            
        //TODO: Notification photo access denied
		case .notDetermined:
			PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
				if authorizationStatus == .authorized {
					takeScreenshotBlock()
				}
			})
		}
	}
    
    
		

    
    
    
    
    // ---------------------------------------- XXXXXXXXXXXXXXXXXXXXXXXXX -----------------------------------------
    // ------------------------------- HERE IS THE MERGE WITH THE OTHER PROJECT -----------------------------------------
    // ---------------------------------------- XXXXXXXXXXXXXXXXXXXXXXXXX -----------------------------------------
    

    //---------------------------------------------- STUFF TO PLACE OBJECTS ----------------------------------------------

    
    
    var nodes: [NodeObject2D] = []
    
    func place2DImage(width: CGFloat, distanceToUser: Float, offsetVert: Float, offsetAngle: Float, image: UIImage) {
        
        guard let currentFrame = self.sceneView.session.currentFrame else {
            return
        }
        
        let height = width*image.size.height/image.size.width
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial?.diffuse.contents = image
        
        let node = NodeObject2D(width: width, distanceToUser: distanceToUser, offsetVertical: offsetVert, offsetAngle: offsetAngle)
        
        
        
        node.geometry = plane
        
        self.nodes.append(node)
        self.sceneView.scene.rootNode.addChildNode(node)
        
        node.placeObject(currentFrame: currentFrame)
        
        
    }
    
    func place2DImage(width: CGFloat, distanceToUser: Float, offsetVert: Float, offsetAngle: Float, image: UIImage, animationStartingOpacity: CGFloat, animationEndingOpacity: CGFloat, animationTranslationVector: SCNVector3, animationTime: Double, animateBack: Bool, animationRepeat: Bool) {
        
        guard let currentFrame = self.sceneView.session.currentFrame else {
            return
        }
        
        let height = width*image.size.height/image.size.width
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial?.diffuse.contents = image
        
        let node = NodeObject2D(width: width, distanceToUser: distanceToUser, offsetVertical: offsetVert, offsetAngle: offsetAngle, animationStartingOpacity: animationStartingOpacity, animationEndingOpacity: animationEndingOpacity, animationTranslationVector: animationTranslationVector, animationTime: animationTime)
        
        
        node.geometry = plane
        
        self.nodes.append(node)
        self.sceneView.scene.rootNode.addChildNode(node)
        
        node.placeObject(currentFrame: currentFrame)
        node.animateBack = animateBack
        node.animationRepeats = animationRepeat
        node.animate()
        
        
    }
    
    
    
    
  

    //---------------------------------- MY BUTTONS ----------------------------

    
    @IBAction func onButtonTouch(_ button: UIButton) {
        run_on_background_thread {

            for _ in 1...10 {
                self.place2DImage(width: CGFloat.random(min: 0.05, max: 0.2), distanceToUser: Float.random(min: 0.2, max: 1.0), offsetVert: Float.random(min: 0.0, max: 0.5), offsetAngle: Float.random(min: 0.0, max: 2*Float.pi), image: #imageLiteral(resourceName: "heart"))
                self.place2DImage(width: CGFloat.random(min: 0.05, max: 0.2), distanceToUser: Float.random(min: 0.5, max: 2.0), offsetVert: Float.random(min: 0.0, max: 0.5), offsetAngle: Float.random(min: 0.0, max: 2*Float.pi), image: #imageLiteral(resourceName: "heart"), animationStartingOpacity: CGFloat.random(min: 0.7, max: 0.9), animationEndingOpacity: CGFloat.random(min: 0.4, max: 0.6), animationTranslationVector: SCNVector3Make(Float.random(min: 0.0, max: 0.1), Float.random(min: 0.0, max: 0.1), Float.random(min: 0.0, max: 0.1)), animationTime: Double.random(min: 2.0, max: 5.0), animateBack: true, animationRepeat: true)
                
            }
        
        }
    }
    
    func run_on_background_thread(code: @escaping () -> Void){
        DispatchQueue.global(qos: .default).async(execute: code)
    }

    
}
