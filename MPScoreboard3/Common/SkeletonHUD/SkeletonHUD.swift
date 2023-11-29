//
//  SkeletonHUD.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/2/22.
//

import UIKit

class SkeletonHUD: NSObject
{    
    private var backgroundView: UIView!
    private var skeletonImageView: UIImageView!
    
    // MARK: - Skeleton Methods
    
    func show(skeletonFrame: CGRect, imageType: SkeletonImageType, parentView: UIView)
    {        
        backgroundView = UIView(frame: parentView.bounds)
        backgroundView.backgroundColor = .clear
        parentView.addSubview(backgroundView)
        
        // Add the gradient and animate it
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = skeletonFrame
        
        let gradientWidth = 0.17
        let gradientFirstStop = 0.1
        let animationSpeed = 1.0
        
        gradientLayer.startPoint = CGPoint(x: -1.0 + gradientWidth, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0 + gradientWidth, y: 0.0)
        
        let fadedGray = UIColor.init(white: 246.0/255.0, alpha: 1.0)
        let firstStop = UIColor.init(white: 238.0/255.0, alpha: 1.0)
        let secondStop = UIColor.init(white: 221.0/255.0, alpha: 1.0)
        
        let colors = [fadedGray.cgColor, firstStop.cgColor, secondStop.cgColor, firstStop.cgColor, fadedGray.cgColor]
        gradientLayer.colors = colors
        
        // Set the start and end points
        let startOne = NSNumber(floatLiteral: gradientLayer.startPoint.x)
        let startTwo = NSNumber(floatLiteral: gradientLayer.startPoint.x)
        let startThree = NSNumber(floatLiteral: 0.0)
        let startFour = NSNumber(floatLiteral: gradientWidth)
        let startFive = NSNumber(floatLiteral: 1.0 + gradientWidth)
        
        let startLocations = [startOne, startTwo, startThree, startFour, startFive]
        gradientLayer.locations = startLocations
        
        let stopOne = NSNumber(floatLiteral: 0.0)
        let stopTwo = NSNumber(floatLiteral: 1.0)
        let stopThree = NSNumber(floatLiteral: 1.0)
        let stopFour = NSNumber(floatLiteral: 1.0 + (gradientWidth - gradientFirstStop))
        let stopFive = NSNumber(floatLiteral: 1.0 + gradientWidth)
        
        let stopLocations = [stopOne, stopTwo, stopThree, stopFour, stopFive]
        
        // Build the basic animation
        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.fromValue = startLocations
        gradientAnimation.toValue = stopLocations
        gradientAnimation.repeatCount = Float.infinity
        gradientAnimation.fillMode = .forwards
        gradientAnimation.isRemovedOnCompletion = false
        gradientAnimation.duration = animationSpeed
        
        gradientLayer.add(gradientAnimation, forKey: "locations")
        backgroundView.layer.addSublayer(gradientLayer)
         
        // Add the skeleton image over top
        skeletonImageView = UIImageView(frame: CGRect(x: 0, y: skeletonFrame.origin.y, width: skeletonFrame.size.width, height: skeletonFrame.size.height))
        skeletonImageView.contentMode = .scaleAspectFill
        skeletonImageView.clipsToBounds = true
        
        if (SharedData.deviceAspectRatio as! AspectRatio == AspectRatio.high)
        {
            switch imageType
            {
            case SkeletonImageType.latest:
                skeletonImageView.image = UIImage(named: "LatestSkeleton-812")
            case SkeletonImageType.rankings:
                skeletonImageView.image = UIImage(named: "RankingsSkeleton-812")
            case SkeletonImageType.scoreboards:
                skeletonImageView.image = UIImage(named: "ScoreboardSkeleton-812")
            case SkeletonImageType.scores:
                skeletonImageView.image = UIImage(named: "ScoresSkeleton-812")
            case SkeletonImageType.stats:
                skeletonImageView.image = UIImage(named: "StatsSkeleton-812")
            }
        }
        else
        {
            switch imageType
            {
            case SkeletonImageType.latest:
                skeletonImageView.image = UIImage(named: "LatestSkeleton-667")
            case SkeletonImageType.rankings:
                skeletonImageView.image = UIImage(named: "RankingsSkeleton-667")
            case SkeletonImageType.scoreboards:
                skeletonImageView.image = UIImage(named: "ScoreboardSkeleton-667")
            case SkeletonImageType.scores:
                skeletonImageView.image = UIImage(named: "ScoresSkeleton-667")
            case SkeletonImageType.stats:
                skeletonImageView.image = UIImage(named: "StatsSkeleton-667")
            }
        }
        
        backgroundView.addSubview(skeletonImageView)
    }
    
    func hide()
    {
        skeletonImageView.removeFromSuperview()
        backgroundView.removeFromSuperview()
    }
    
    
}
