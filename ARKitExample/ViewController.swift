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


class ViewController: UIViewController, ARSCNViewDelegate, SCNSceneRendererDelegate {
	
    
    
    // MARK: - Main Setup & View Controller methods
    override func viewDidLoad() {
        super.viewDidLoad()

        
        setupScene()
        
        if let worldSessionConfig = sessionConfig as? ARWorldTrackingConfiguration{
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
    
    
	var use3DOFTrackingFallback = false
    @IBOutlet var sceneView: ARSCNView!
    
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
	
    /*
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
    }*/
	

	
	/*
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
	}*/
	/*
		
	func sessionInterruptionEnded(_ session: ARSession) {
		session.run(sessionConfig, options: [.resetTracking, .removeExistingAnchors])
		restartExperience(self)
	}*/
	
    // MARK: - Ambient Light Estimation
	/*
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
    }*/

    
	
	
	
	/*
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
	*/


   
	
	
	@IBOutlet weak var restartExperienceButton: UIButton!
	var restartExperienceButtonIsEnabled = true
	
	@IBAction func restartExperience(_ sender: Any) {
		
		
		DispatchQueue.main.async {
			self.restartExperienceButtonIsEnabled = false
			
			
			self.restartExperienceButton.setImage(#imageLiteral(resourceName: "restart"), for: [])
            
            
            self.removeAllNodes()
			
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
    
    func removeAllNodes(){
        for node in nodes {
            node.removeFromParentNode()
        }
        nodes.removeAll()
    }
    
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
    
   
    
    
    
    func place2DGif(width: CGFloat, distanceToUser: Float, offsetVert: Float, offsetAngle: Float, url: URL) {
        
        guard let currentFrame = self.sceneView.session.currentFrame else {
            return
        }
        
        guard let image = UIImage.gifImageWithURL("https://preview.ibb.co/iOa7nc/Heart.gif") else {
            return
            
        }
        
        let height = width*image.size.height/image.size.width
        
        
        
        //let bundleURL = Bundle.main.url(forResource: "Heart", withExtension: "gif") ------ for hardcoded files
        let animation : CAKeyframeAnimation = createGIFAnimation(url: url)!
        let layer = CALayer()
        layer.bounds = CGRect(x: 0, y: 0, width: 900, height: 900)
        
        layer.add(animation, forKey: "contents")
        let tempView = UIView.init(frame: CGRect(x: 0, y: 0, width: 900, height: 900))
        tempView.backgroundColor = UIColor.clear
        tempView.layer.bounds = CGRect(x: -450, y: -450, width: tempView.frame.size.width, height: tempView.frame.size.height)
        tempView.layer.addSublayer(layer)
        
        let newMaterial = SCNMaterial()
        newMaterial.isDoubleSided = true
        newMaterial.diffuse.contents = tempView.layer
        
        
        
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial = newMaterial
        
        let node = NodeObject2D(width: width, distanceToUser: distanceToUser, offsetVertical: offsetVert, offsetAngle: offsetAngle)
        
        
        node.geometry = plane
        
        self.nodes.append(node)
        self.sceneView.scene.rootNode.addChildNode(node)
        
        node.placeObject(currentFrame: currentFrame)
        node.animate()
        
        
    }
    
    //-------------- THIS FUNCTION CREATES THE GIF ANIMATION
    func createGIFAnimation(url:URL) -> CAKeyframeAnimation?{
        
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let frameCount = CGImageSourceGetCount(src)
        
        // Total loop time
        var time : Float = 0
        
        // Arrays
        var framesArray = [AnyObject]()
        var tempTimesArray = [NSNumber]()
        
        // Loop
        for i in 0..<frameCount {
            
            // Frame default duration
            var frameDuration : Float = 0.1;
            
            let cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(src, i, nil)
            guard let framePrpoerties = cfFrameProperties as? [String:AnyObject] else {return nil}
            guard let gifProperties = framePrpoerties[kCGImagePropertyGIFDictionary as String] as? [String:AnyObject]
                else { return nil }
            
            // Use kCGImagePropertyGIFUnclampedDelayTime or kCGImagePropertyGIFDelayTime
            if let delayTimeUnclampedProp = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber {
                frameDuration = delayTimeUnclampedProp.floatValue
            }
            else{
                if let delayTimeProp = gifProperties[kCGImagePropertyGIFDelayTime as String] as? NSNumber {
                    frameDuration = delayTimeProp.floatValue
                }
            }
            
            // Make sure its not too small
            if frameDuration < 0.011 {
                frameDuration = 0.100;
            }
            
            // Add frame to array of frames
            if let frame = CGImageSourceCreateImageAtIndex(src, i, nil) {
                tempTimesArray.append(NSNumber(value: frameDuration))
                framesArray.append(frame)
            }
            
            // Compile total loop time
            time = time + frameDuration
        }
        
        var timesArray = [NSNumber]()
        var base : Float = 0
        for duration in tempTimesArray {
            timesArray.append(NSNumber(value: base))
            base = base + ( duration.floatValue / time )
        }
        
        // From documentation of 'CAKeyframeAnimation':
        // the first value in the array must be 0.0 and the last value must be 1.0.
        // The array should have one more entry than appears in the values array.
        // For example, if there are two values, there should be three key times.
        timesArray.append(NSNumber(value: 1.0))
        
        // Create animation
        let animation = CAKeyframeAnimation(keyPath: "contents")
        
        animation.beginTime = AVCoreAnimationBeginTimeAtZero
        animation.duration = CFTimeInterval(time)
        animation.repeatCount = Float.greatestFiniteMagnitude;
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.values = framesArray
        animation.keyTimes = timesArray
        //animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.calculationMode = kCAAnimationDiscrete
        
        return animation;
    }
    
    
  

    //---------------------------------- MY BUTTONS ----------------------------

    
    @IBAction func onButtonTouch(_ button: UIButton) {
        
        
        run_on_background_thread {

            for _ in 1...10 {
                self.place2DImage(width: CGFloat.random(min: 0.05, max: 0.2), distanceToUser: Float.random(min: 0.2, max: 1.0), offsetVert: Float.random(min: 0.0, max: 0.5), offsetAngle: Float.random(min: 0.0, max: 2*Float.pi), image: #imageLiteral(resourceName: "heart"))
                self.place2DImage(width: CGFloat.random(min: 0.05, max: 0.2), distanceToUser: Float.random(min: 0.5, max: 2.0), offsetVert: Float.random(min: 0.0, max: 0.5), offsetAngle: Float.random(min: 0.0, max: 2*Float.pi), image: #imageLiteral(resourceName: "heart"), animationStartingOpacity: CGFloat.random(min: 0.7, max: 0.9), animationEndingOpacity: CGFloat.random(min: 0.4, max: 0.6), animationTranslationVector: SCNVector3Make(Float.random(min: 0.0, max: 0.1), Float.random(min: 0.0, max: 0.1), Float.random(min: 0.0, max: 0.1)), animationTime: Double.random(min: 2.0, max: 5.0), animateBack: true, animationRepeat: true)
                
                
                if let url = URL(string: "https://media.giphy.com/media/3CSElA3OxWFcuk44mI/giphy.gif"){
                    self.place2DGif(width: CGFloat.random(min: 0.05, max: 0.2), distanceToUser: Float.random(min: 0.2, max: 1.0), offsetVert: Float.random(min: 0.0, max: 0.5), offsetAngle: Float.random(min: 0.0, max: 2*Float.pi), url: url)
                    
                }
                
            }
        
        }
            
        
    }
    
    func run_on_background_thread(code: @escaping () -> Void){
        DispatchQueue.global(qos: .default).async(execute: code)
    }

    
}
