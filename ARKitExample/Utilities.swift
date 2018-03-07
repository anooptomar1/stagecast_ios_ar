/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Utility functions and type extensions used throughout the projects.
*/

import Foundation
import ARKit

/*
extension SKSpriteNode{
    
    func animateWithRemoteGIF(url: NSURL){
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = NSURLRequest.CachePolicy.returnCacheDataElseLoad
        config.urlCache = URLCache.shared
        
        let session = URLSession(configuration: config)
        
        let downloadTask = session.downloadTask(with: url as URL, completionHandler: {
            [weak self] url, response, error in
            if error == nil, let url = url, let data = NSData(contentsOf: url), let textures = SKSpriteNode.gifWithData(data: data) {
                DispatchQueue.main.async {
                    if let strongSelf = self {
                        let action = SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.1))
                        strongSelf.run(action)
                    }
                }
            } else {
                
            }
            session.finishTasksAndInvalidate()
        })
        
        downloadTask.resume()
        
    }
    
    
    func animateWithLocalGIF(fileNamed name:String){
        
        // Check gif
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return
        }
        
        // Validate data
        guard let imageData = NSData(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return
        }
        
        if let textures = SKSpriteNode.gifWithData(data: imageData){
            let action = SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.1))
            self.run(action)
        }
    }
    
    
    public class func gifWithData(data: NSData) -> [SKTexture]? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data, nil) else {
            print("SwiftGif: Source for the image does not exist")
            return nil
        }
        
        return SKSpriteNode.animatedImageWithSource(source: source)
    }
    
    
    class func animatedImageWithSource(source: CGImageSource) -> [SKTexture]? {
        let count = CGImageSourceGetCount(source)
        var delays = [Int]()
        var textures = [SKTexture]()
        
        // Fill arrays
        for i in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let texture = SKTexture(cgImage: image)
                textures.append(texture)
            }
            
            // At it's delay in cs
            let delaySeconds = SKSpriteNode.delayForImageAtIndex(index: Int(i),
                                                                 source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        // Calculate full duration
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            return sum
        }()
        
        // may use later
        let timePerTexture = Double(duration) / 1000.0 / Double(count)
        
        return textures
    }
    
    
    class func gcdForArray(array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = SKSpriteNode.gcdForPair(a: val, gcd)
        }
        
        return gcd
    }
    
    class func delayForImageAtIndex(index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1 // Make sure they're not too fast
        }
        
        return delay
    }
    
    class func gcdForPair(a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        // Check if one of them is nil
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        // Swap for modulo
        if a! < b! {
            let c = a
            a = b
            b = c
        }
        
        // Get greatest common divisor
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b! // Found it
            } else {
                a = b
                b = rest
            }
        }
    }
}*/

// - MARK: UIImage extensions

extension UIImage {
	func inverted() -> UIImage? {
        guard let ciImage = CIImage(image: self) else {
            return nil
        }
        return UIImage(ciImage: ciImage.applyingFilter("CIColorInvert", parameters: [:]))
    }
	
	static func composeButtonImage(from thumbImage: UIImage, alpha: CGFloat = 1.0) -> UIImage {
		let maskImage = #imageLiteral(resourceName: "buttonring")
		var thumbnailImage = thumbImage
		if let invertedImage = thumbImage.inverted() {
			thumbnailImage = invertedImage
		}
		
		// Compose a button image based on a white background and the inverted thumbnail image.
		UIGraphicsBeginImageContextWithOptions(maskImage.size, false, 0.0)
		let maskDrawRect = CGRect(origin: CGPoint.zero,
		                          size: maskImage.size)
		let thumbDrawRect = CGRect(origin: CGPoint((maskImage.size - thumbImage.size) / 2),
		                           size: thumbImage.size)
		maskImage.draw(in: maskDrawRect, blendMode: .normal, alpha: alpha)
		thumbnailImage.draw(in: thumbDrawRect, blendMode: .normal, alpha: alpha)
		let composedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return composedImage!
	}
    
    
    //-------------- NEEDED FOR LOADING A GIF ---------------
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        let a = UIImage.animatedImageWithSource(source)
        
        print(a!.duration)
        print(a!.images)
        
        return a
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL? = URL(string: gifUrl)
            else {
                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL!) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a! < b! {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        print("Gif has \(images.count) images")
        
        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 1000.0)
        
        print("Animation \(animation)")
        
        return animation
    }
    
    //-------------- NEEDED FOR LOADING A GIF ---------------
}

extension SCNGeometry {
    
    class func rectangleForm(topLeft: SCNVector3, topRight: SCNVector3, bottomLeft: SCNVector3, bottomRight: SCNVector3) -> SCNGeometry {
        
        let indices: [Int32] = [0, 1, 2]
        let indices2: [Int32] = [0, 1, 2]
        
        let source = SCNGeometrySource(vertices: [topLeft, topRight, bottomRight])
        let source2 = SCNGeometrySource(vertices: [topLeft, bottomLeft, bottomRight])
        
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let element2 = SCNGeometryElement(indices: indices2, primitiveType: .triangles)
        
        return SCNGeometry(sources: [source, source2], elements: [element, element2])
    }
    
    class func lineForm(vector1: SCNVector3, vector2: SCNVector3) -> SCNGeometry{
        let indices: [Int32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
    }
}


// MARK: - Collection extensions
extension Array where Iterator.Element == CGFloat {
	var average: CGFloat? {
		guard !isEmpty else {
			return nil
		}
		
		var ret = self.reduce(CGFloat(0)) { (cur, next) -> CGFloat in
			var cur = cur
			cur += next
			return cur
		}
		let fcount = CGFloat(count)
		ret /= fcount
		return ret
	}
}

extension Array where Iterator.Element == SCNVector3 {
	var average: SCNVector3? {
		guard !isEmpty else {
			return nil
		}
		
		var ret = self.reduce(SCNVector3Zero) { (cur, next) -> SCNVector3 in
			var cur = cur
			cur.x += next.x
			cur.y += next.y
			cur.z += next.z
			return cur
		}
		let fcount = Float(count)
		ret.x /= fcount
		ret.y /= fcount
		ret.z /= fcount
		
		return ret
	}
}

extension RangeReplaceableCollection where IndexDistance == Int {
	mutating func keepLast(_ elementsToKeep: Int) {
		if count > elementsToKeep {
			self.removeFirst(count - elementsToKeep)
		}
	}
}

// MARK: - SCNNode extension

extension SCNNode {
	
	func setUniformScale(_ scale: Float) {
		self.scale = SCNVector3Make(scale, scale, scale)
	}
	
	func renderOnTop() {
		self.renderingOrder = 2
		if let geom = self.geometry {
			for material in geom.materials {
				material.readsFromDepthBuffer = false
			}
		}
		for child in self.childNodes {
			child.renderOnTop()
		}
	}
}

// MARK: - SCNVector3 extensions

extension SCNVector3 {
	
	init(_ vec: vector_float3) {
		self.x = vec.x
		self.y = vec.y
		self.z = vec.z
	}
	
	func length() -> Float {
		return sqrtf(x * x + y * y + z * z)
	}
	
	mutating func setLength(_ length: Float) {
		self.normalize()
		self *= length
	}
	
	mutating func setMaximumLength(_ maxLength: Float) {
		if self.length() <= maxLength {
			return
		} else {
			self.normalize()
			self *= maxLength
		}
	}
	
	mutating func normalize() {
		self = self.normalized()
	}
	
	func normalized() -> SCNVector3 {
		if self.length() == 0 {
			return self
		}
		
		return self / self.length()
	}
	
	static func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
		return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
	}
	
	func friendlyString() -> String {
		return "(\(String(format: "%.2f", x)), \(String(format: "%.2f", y)), \(String(format: "%.2f", z)))"
	}
	
	func dot(_ vec: SCNVector3) -> Float {
		return (self.x * vec.x) + (self.y * vec.y) + (self.z * vec.z)
	}
	
	func cross(_ vec: SCNVector3) -> SCNVector3 {
		return SCNVector3(self.y * vec.z - self.z * vec.y, self.z * vec.x - self.x * vec.z, self.x * vec.y - self.y * vec.x)
	}
    
    func norm() -> SCNVector3 {
        return self/self.length()
    }
}

public let SCNVector3One: SCNVector3 = SCNVector3(1.0, 1.0, 1.0)

func SCNVector3Uniform(_ value: Float) -> SCNVector3 {
	return SCNVector3Make(value, value, value)
}

func SCNVector3Uniform(_ value: CGFloat) -> SCNVector3 {
	return SCNVector3Make(Float(value), Float(value), Float(value))
}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
	return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
	return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

func += (left: inout SCNVector3, right: SCNVector3) {
	left = left + right
}

func -= (left: inout SCNVector3, right: SCNVector3) {
	left = left - right
}

func / (left: SCNVector3, right: Float) -> SCNVector3 {
	return SCNVector3Make(left.x / right, left.y / right, left.z / right)
}

func * (left: SCNVector3, right: Float) -> SCNVector3 {
	return SCNVector3Make(left.x * right, left.y * right, left.z * right)
}

func /= (left: inout SCNVector3, right: Float) {
	left = left / right
}

func *= (left: inout SCNVector3, right: Float) {
	left = left * right
}

// MARK: - SCNMaterial extensions

extension SCNMaterial {
	
	static func material(withDiffuse diffuse: Any?, respondsToLighting: Bool = true) -> SCNMaterial {
		let material = SCNMaterial()
		material.diffuse.contents = diffuse
		material.isDoubleSided = true
		if respondsToLighting {
			material.locksAmbientWithDiffuse = true
		} else {
			material.ambient.contents = UIColor.black
			material.lightingModel = .constant
			material.emission.contents = diffuse
		}
		return material
	}
}

// MARK: - CGPoint extensions

extension CGPoint {
	
	init(_ size: CGSize) {
		self.x = size.width
		self.y = size.height
	}
	
	init(_ vector: SCNVector3) {
		self.x = CGFloat(vector.x)
		self.y = CGFloat(vector.y)
	}
	
	func distanceTo(_ point: CGPoint) -> CGFloat {
		return (self - point).length()
	}
	
	func length() -> CGFloat {
		return sqrt(self.x * self.x + self.y * self.y)
	}
	
	func midpoint(_ point: CGPoint) -> CGPoint {
		return (self + point) / 2
	}
	
	func friendlyString() -> String {
		return "(\(String(format: "%.2f", x)), \(String(format: "%.2f", y)))"
	}
    
    func invert() ->CGPoint {
        return CGPoint(x: (1.0-self.y), y: (1.0-self.x))
    }
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
	return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
	return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func += (left: inout CGPoint, right: CGPoint) {
	left = left + right
}

func -= (left: inout CGPoint, right: CGPoint) {
	left = left - right
}

func / (left: CGPoint, right: CGFloat) -> CGPoint {
	return CGPoint(x: left.x / right, y: left.y / right)
}

func * (left: CGPoint, right: CGFloat) -> CGPoint {
	return CGPoint(x: left.x * right, y: left.y * right)
}

func /= (left: inout CGPoint, right: CGFloat) {
	left = left / right
}

func *= (left: inout CGPoint, right: CGFloat) {
	left = left * right
}

// MARK: - CGSize extensions

extension CGSize {
	
	init(_ point: CGPoint) {
		self.width = point.x
		self.height = point.y
	}
	
	func friendlyString() -> String {
		return "(\(String(format: "%.2f", width)), \(String(format: "%.2f", height)))"
	}
}

func + (left: CGSize, right: CGSize) -> CGSize {
	return CGSize(width: left.width + right.width, height: left.height + right.height)
}

func - (left: CGSize, right: CGSize) -> CGSize {
	return CGSize(width: left.width - right.width, height: left.height - right.height)
}

func += (left: inout CGSize, right: CGSize) {
	left = left + right
}

func -= (left: inout CGSize, right: CGSize) {
	left = left - right
}

func / (left: CGSize, right: CGFloat) -> CGSize {
	return CGSize(width: left.width / right, height: left.height / right)
}

func * (left: CGSize, right: CGFloat) -> CGSize {
	return CGSize(width: left.width * right, height: left.height * right)
}

func /= (left: inout CGSize, right: CGFloat) {
	left = left / right
}

func *= (left: inout CGSize, right: CGFloat) {
	left = left * right
}

// MARK: - CGRect extensions

extension CGRect {
	
	var mid: CGPoint {
		return CGPoint(x: midX, y: midY)
	}
}

func rayIntersectionWithHorizontalPlane(rayOrigin: SCNVector3, direction: SCNVector3, planeY: Float) -> SCNVector3? {
	
	let direction = direction.normalized()
	
	// Special case handling: Check if the ray is horizontal as well.
	if direction.y == 0 {
		if rayOrigin.y == planeY {
			// The ray is horizontal and on the plane, thus all points on the ray intersect with the plane.
			// Therefore we simply return the ray origin.
			return rayOrigin
		} else {
			// The ray is parallel to the plane and never intersects.
			return nil
		}
	}
	
	// The distance from the ray's origin to the intersection point on the plane is:
	//   (pointOnPlane - rayOrigin) dot planeNormal
	//  --------------------------------------------
	//          direction dot planeNormal
	
	// Since we know that horizontal planes have normal (0, 1, 0), we can simplify this to:
	let dist = (planeY - rayOrigin.y) / direction.y

	// Do not return intersections behind the ray's origin.
	if dist < 0 {
		return nil
	}
	
	// Return the intersection point.
	return rayOrigin + (direction * dist)
}

extension ARSCNView {
	
	struct HitTestRay {
		let origin: SCNVector3
		let direction: SCNVector3
	}
	
	func hitTestRayFromScreenPos(_ point: CGPoint) -> HitTestRay? {
		
		guard let frame = self.session.currentFrame else {
			return nil
		}

		let cameraPos = SCNVector3.positionFromTransform(frame.camera.transform)

		// Note: z: 1.0 will unproject() the screen position to the far clipping plane.
		let positionVec = SCNVector3(x: Float(point.x), y: Float(point.y), z: 1.0)
		let screenPosOnFarClippingPlane = self.unprojectPoint(positionVec)
		
		var rayDirection = screenPosOnFarClippingPlane - cameraPos
		rayDirection.normalize()
		
		return HitTestRay(origin: cameraPos, direction: rayDirection)
	}
	
	func hitTestWithInfiniteHorizontalPlane(_ point: CGPoint, _ pointOnPlane: SCNVector3) -> SCNVector3? {
		
		guard let ray = hitTestRayFromScreenPos(point) else {
			return nil
		}
		
		// Do not intersect with planes above the camera or if the ray is almost parallel to the plane.
		if ray.direction.y > -0.03 {
			return nil
		}
		
		// Return the intersection of a ray from the camera through the screen position with a horizontal plane
		// at height (Y axis).
		return rayIntersectionWithHorizontalPlane(rayOrigin: ray.origin, direction: ray.direction, planeY: pointOnPlane.y)
	}
	
	struct FeatureHitTestResult {
		let position: SCNVector3
		let distanceToRayOrigin: Float
		let featureHit: SCNVector3
		let featureDistanceToHitResult: Float
	}
	
	func hitTestWithFeatures(_ point: CGPoint, coneOpeningAngleInDegrees: Float,
	                         minDistance: Float = 0,
	                         maxDistance: Float = Float.greatestFiniteMagnitude,
	                         maxResults: Int = 1) -> [FeatureHitTestResult] {
		
		var results = [FeatureHitTestResult]()
		
		guard let features = self.session.currentFrame?.rawFeaturePoints else {
			return results
		}
		
		guard let ray = hitTestRayFromScreenPos(point) else {
			return results
		}
		
		let maxAngleInDeg = min(coneOpeningAngleInDegrees, 360) / 2
		let maxAngle = ((maxAngleInDeg / 180) * Float.pi)
		
		let points = features.points
		
		for i in 0...points.count-1 {
			
			//let feature = points.advanced(by: Int(i))
            let feature = points[i]
			let featurePos = SCNVector3(feature)//SCNVector3(feature.pointee)
			
			let originToFeature = featurePos - ray.origin
			
			let crossProduct = originToFeature.cross(ray.direction)
			let featureDistanceFromResult = crossProduct.length()
			
			let hitTestResult = ray.origin + (ray.direction * ray.direction.dot(originToFeature))
			let hitTestResultDistance = (hitTestResult - ray.origin).length()
			
			if hitTestResultDistance < minDistance || hitTestResultDistance > maxDistance {
				// Skip this feature - it is too close or too far away.
				continue
			}
			
			let originToFeatureNormalized = originToFeature.normalized()
			let angleBetweenRayAndFeature = acos(ray.direction.dot(originToFeatureNormalized))
			
			if angleBetweenRayAndFeature > maxAngle {
				// Skip this feature - is is outside of the hit test cone.
				continue
			}

			// All tests passed: Add the hit against this feature to the results.
			results.append(FeatureHitTestResult(position: hitTestResult,
			                                    distanceToRayOrigin: hitTestResultDistance,
			                                    featureHit: featurePos,
			                                    featureDistanceToHitResult: featureDistanceFromResult))
		}
		
		// Sort the results by feature distance to the ray.
		results = results.sorted(by: { (first, second) -> Bool in
			return first.distanceToRayOrigin < second.distanceToRayOrigin
		})
		
		// Cap the list to maxResults.
		var cappedResults = [FeatureHitTestResult]()
		var i = 0
		while i < maxResults && i < results.count {
			cappedResults.append(results[i])
			i += 1
		}
		
		return cappedResults
	}
	
	func hitTestWithFeatures(_ point: CGPoint) -> [FeatureHitTestResult] {
		
		var results = [FeatureHitTestResult]()
		
		guard let ray = hitTestRayFromScreenPos(point) else {
			return results
		}
		
		if let result = self.hitTestFromOrigin(origin: ray.origin, direction: ray.direction) {
			results.append(result)
		}
		
		return results
	}
	
	func hitTestFromOrigin(origin: SCNVector3, direction: SCNVector3) -> FeatureHitTestResult? {
		
		guard let features = self.session.currentFrame?.rawFeaturePoints else {
			return nil
		}
		
		let points = features.points
		
		// Determine the point from the whole point cloud which is closest to the hit test ray.
		var closestFeaturePoint = origin
		var minDistance = Float.greatestFiniteMagnitude
		
		for i in 0...points.count-1 {
			let feature = points[i]//points.advanced(by: Int(i))
			let featurePos = SCNVector3(feature)//SCNVector3(feature.pointee)
			
			let originVector = origin - featurePos
			let crossProduct = originVector.cross(direction)
			let featureDistanceFromResult = crossProduct.length()

			if featureDistanceFromResult < minDistance {
				closestFeaturePoint = featurePos
				minDistance = featureDistanceFromResult
			}
		}
		
		// Compute the point along the ray that is closest to the selected feature.
		let originToFeature = closestFeaturePoint - origin
		let hitTestResult = origin + (direction * direction.dot(originToFeature))
		let hitTestResultDistance = (hitTestResult - origin).length()
		
		return FeatureHitTestResult(position: hitTestResult,
		                            distanceToRayOrigin: hitTestResultDistance,
		                            featureHit: closestFeaturePoint,
		                            featureDistanceToHitResult: minDistance)
	}
}

// MARK: - Simple geometries

func createAxesNode(quiverLength: CGFloat, quiverThickness: CGFloat) -> SCNNode {
	let quiverThickness = (quiverLength / 50.0) * quiverThickness
	let chamferRadius = quiverThickness / 2.0
	
	let xQuiverBox = SCNBox(width: quiverLength, height: quiverThickness, length: quiverThickness, chamferRadius: chamferRadius)
	xQuiverBox.materials = [SCNMaterial.material(withDiffuse: UIColor.red, respondsToLighting: false)]
	let xQuiverNode = SCNNode(geometry: xQuiverBox)
	xQuiverNode.position = SCNVector3Make(Float(quiverLength / 2.0), 0.0, 0.0)
	
	let yQuiverBox = SCNBox(width: quiverThickness, height: quiverLength, length: quiverThickness, chamferRadius: chamferRadius)
	yQuiverBox.materials = [SCNMaterial.material(withDiffuse: UIColor.green, respondsToLighting: false)]
	let yQuiverNode = SCNNode(geometry: yQuiverBox)
	yQuiverNode.position = SCNVector3Make(0.0, Float(quiverLength / 2.0), 0.0)
	
	let zQuiverBox = SCNBox(width: quiverThickness, height: quiverThickness, length: quiverLength, chamferRadius: chamferRadius)
	zQuiverBox.materials = [SCNMaterial.material(withDiffuse: UIColor.blue, respondsToLighting: false)]
	let zQuiverNode = SCNNode(geometry: zQuiverBox)
	zQuiverNode.position = SCNVector3Make(0.0, 0.0, Float(quiverLength / 2.0))
	
	let quiverNode = SCNNode()
	quiverNode.addChildNode(xQuiverNode)
	quiverNode.addChildNode(yQuiverNode)
	quiverNode.addChildNode(zQuiverNode)
	quiverNode.name = "Axes"
	return quiverNode
}

func createCrossNode(size: CGFloat = 0.01, color: UIColor = UIColor.green, horizontal: Bool = true, opacity: CGFloat = 1.0) -> SCNNode {
	
	// Create a size x size m plane and put a grid texture onto it.
	let planeDimension = size
	
	var fileName = ""
	switch color {
	case UIColor.blue:
		fileName = "crosshair_blue"
	case UIColor.yellow:
		fallthrough
	default:
		fileName = "crosshair_yellow"
	}
	
	let path = Bundle.main.path(forResource: fileName, ofType: "png", inDirectory: "Models.scnassets")!
	let image = UIImage(contentsOfFile: path)
	
	let planeNode = SCNNode(geometry: createSquarePlane(size: planeDimension, contents: image))
	if let material = planeNode.geometry?.firstMaterial {
		material.ambient.contents = UIColor.black
		material.lightingModel = .constant
	}
	
	if horizontal {
		planeNode.eulerAngles = SCNVector3Make(Float.pi / 2.0, 0, Float.pi) // Horizontal.
	} else {
		planeNode.constraints = [SCNBillboardConstraint()] // Facing the screen.
	}
	
	let cross = SCNNode()
	cross.addChildNode(planeNode)
	cross.opacity = opacity
	return cross
}

func createSquarePlane(size: CGFloat, contents: AnyObject?) -> SCNPlane {
	let plane = SCNPlane(width: size, height: size)
	plane.materials = [SCNMaterial.material(withDiffuse: contents)]
	return plane
}

func createPlane(size: CGSize, contents: AnyObject?) -> SCNPlane {
	let plane = SCNPlane(width: size.width, height: size.height)
	plane.materials = [SCNMaterial.material(withDiffuse: contents)]
	return plane
}

// MARK: Float Extension

public extension Float {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: Float {
        return Float(arc4random()) / 0xFFFFFFFF
    }
    
    /// Random float between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random float point number between 0 and n max
    public static func random(min: Float, max: Float) -> Float {
        return Float.random * (max - min) + min
    }
}

// MARK: CGFloat Extension

public extension CGFloat {
    
    /// Randomly returns either 1.0 or -1.0.
    public static var randomSign: CGFloat {
        return (arc4random_uniform(2) == 0) ? 1.0 : -1.0
    }
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: CGFloat {
        return CGFloat(Float.random)
    }
    
    /// Random CGFloat between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random CGFloat point number between 0 and n max
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random * (max - min) + min
    }
}

// MARK: Double Extension

public extension Double {
    
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    public static var random: Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
    
    /// Random double between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random double point number between 0 and n max
    public static func random(min: Double, max: Double) -> Double {
        return Double.random * (max - min) + min
    }
}

