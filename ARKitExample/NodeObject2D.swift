//
//  NodeObject2D.swift
//  ARKitExample
//
//  Created by Maximilian Klinke on 06.02.18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class NodeObject2D: SCNNode {
    
    var width: CGFloat
    var distanceToUser: Float
    var offsetVertical: Float
    var offsetAngle: Float
    
    var animationStartingOpacity: CGFloat?
    var animationEndingOpacity: CGFloat?
    var animationTranslationVector: SCNVector3?
    var animationTime: Double?
    
    
    var animateBack = false
    var animationRepeats = false
    
    
    override init() {
        self.width = 0.1
        self.distanceToUser = 0.5
        self.offsetVertical = 0.0
        self.offsetAngle = 0.0
        
        
        super.init()
    }
    
    init(width: CGFloat, distanceToUser: Float, offsetVertical: Float, offsetAngle: Float) {
        self.width = width
        self.distanceToUser = distanceToUser
        self.offsetVertical = offsetVertical
        if offsetVertical == 0.0 {
            self.offsetVertical = 0.01
        }
        self.offsetAngle = offsetAngle
        
        super.init()
    }
    
    init(width: CGFloat, distanceToUser: Float, offsetVertical: Float, offsetAngle: Float, animationStartingOpacity: CGFloat, animationEndingOpacity: CGFloat, animationTranslationVector: SCNVector3, animationTime: Double) {
        self.width = width
        self.distanceToUser = distanceToUser
        self.offsetVertical = offsetVertical
        self.offsetAngle = offsetAngle
        
        self.animationTranslationVector = animationTranslationVector
        self.animationStartingOpacity = animationStartingOpacity
        self.animationEndingOpacity = animationEndingOpacity
        self.animationTime = animationTime
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func placeObject(currentFrame: ARFrame){
        let x = sin(self.offsetAngle)*self.distanceToUser
        var z = cos(self.offsetAngle)*self.distanceToUser
        
        var translation = matrix_identity_float4x4
        translation.columns.3.y = self.offsetVertical
        translation.columns.3.x = -1.0*x
        translation.columns.3.z = -1.0*z
        
        let cameraTransform = currentFrame.camera.transform
        var trans = matrix_identity_float4x4
        trans.columns.3 = cameraTransform.columns.3
        
        self.simdTransform = matrix_multiply(trans, translation)
        
        //Not divide by zero
        if z == 0.0 {
            z = 0.01
        }
        self.eulerAngles = SCNVector3Make(atan(offsetVertical/z), offsetAngle, 0.0)
        // Maybe I have to change this - try it out with z-part: atan(offsetVertical/x)
        
        if animationStartingOpacity != nil {
            self.opacity = animationStartingOpacity!
        }
    }
    
    func animate(){
        if (self.animationEndingOpacity != nil) && (self.animationStartingOpacity != nil) && self.animationTranslationVector != nil && self.animationTime != nil {
            
            let animationOpacity = CABasicAnimation(keyPath: "opacity")
            animationOpacity.fromValue = self.animationStartingOpacity
            animationOpacity.toValue = self.animationEndingOpacity
            animationOpacity.duration = animationTime!
            animationOpacity.autoreverses = self.animateBack
            if self.animationRepeats {
                animationOpacity.repeatCount = .infinity
            }
            
            let animationTranslation = CABasicAnimation(keyPath: "position")
            animationTranslation.fromValue = self.position
            animationTranslation.toValue = self.position + animationTranslationVector!
            animationTranslation.duration = animationTime!
            animationTranslation.autoreverses = self.animateBack
            if self.animationRepeats {
                animationTranslation.repeatCount = .infinity
            }
            
            self.addAnimation(animationOpacity, forKey: nil)
            self.addAnimation(animationTranslation, forKey: nil)
            
        }else{
            return
        }
        
        
    }
    
    
    
    
    
}
