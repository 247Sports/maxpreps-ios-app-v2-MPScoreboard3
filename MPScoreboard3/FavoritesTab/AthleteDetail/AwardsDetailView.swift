//
//  AwardsDetailView.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/15/21.
//

import UIKit

protocol AwardsDetailViewDelegate: AnyObject
{
    func closeAwardsDetailView()
}

class AwardsDetailView: UIView
{
    weak var delegate: AwardsDetailViewDelegate?
    
    private var blackBackgroundView : UIView?
    private var awardImageView : UIImageView?
    
    // MARK: - Load Image Method
    
    func loadImage(_ image: UIImage)
    {
        awardImageView?.image = image
    }
    
    // MARK: - Gesture Methods
    
    @objc func handleTap(sender: UITapGestureRecognizer)
    {
        // Animate the roundRectView and blackBackgroundView
        UIView.animate(withDuration: 0.24, animations:
                        {
                            self.awardImageView?.transform = CGAffineTransform(translationX: 0, y: kDeviceHeight)
                            self.blackBackgroundView?.alpha = 0.0
                        })
        { (finished) in
            
            self.delegate?.closeAwardsDetailView()
        }
    }
    
    // MARK: - Init Method
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        blackBackgroundView = UIView(frame: frame)
        blackBackgroundView?.backgroundColor = UIColor.mpBlackColor()
        blackBackgroundView?.alpha = 0.0
        self.addSubview(blackBackgroundView!)
        
        // Add a tap gesture recognizer to the blackBackgroundView
        let topTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        blackBackgroundView?.addGestureRecognizer(topTapGesture)
        
        awardImageView = UIImageView(frame: CGRect(x: Int((kDeviceWidth - 335) / 2.0), y: Int((kDeviceHeight - 340) / 2.0), width: 335, height: 340))
        awardImageView?.backgroundColor = .clear
        awardImageView?.layer.cornerRadius = 12
        awardImageView?.clipsToBounds = true
        awardImageView?.contentMode = .scaleAspectFit
        
        //let shift = kDeviceHeight - ((kDeviceHeight - 340) / 2.0)
        awardImageView?.transform = CGAffineTransform(translationX: 0, y: kDeviceHeight)
        self.addSubview(awardImageView!)

        // Animate the imageView and blackBackgroundView
        UIView.animate(withDuration: 0.24, animations:
                        {
                            self.awardImageView?.transform = CGAffineTransform(translationX: 0, y: -10)
                            self.blackBackgroundView?.alpha = 0.7
                        })
        { (finished) in
            UIView.animate(withDuration: 0.24, animations:
                            {
                                self.awardImageView?.transform = CGAffineTransform(translationX: 0, y: 5)
                                
                            })
            { (finished) in
                UIView.animate(withDuration: 0.24, animations:
                                {
                                    self.awardImageView?.transform = CGAffineTransform(translationX: 0, y: 0)
                                    
                                })
                { (finished) in
                    
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

}
