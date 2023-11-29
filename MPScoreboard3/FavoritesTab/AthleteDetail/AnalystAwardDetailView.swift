//
//  AnalystAwardDetailView.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/15/21.
//

import UIKit

protocol AnalystAwardDetailViewDelegate: AnyObject
{
    func closeAnalystAwardDetailView()
}

class AnalystAwardDetailView: UIView
{
    weak var delegate: AnalystAwardDetailViewDelegate?
    
    private var blackBackgroundView : UIView?
    private var containerView : UIView?
    private var topBackgroundView : UIView?
    private var iconContainerView : UIView?
    private var iconImageView: UIImageView?
    private var titleLabel: UILabel?
    private var subtitleLabel: UILabel?
    
    // MARK: - Load Data Method
    
    func loadData(_ award: Dictionary<String,Any>, athlete: Athlete)
    {
        // Load the gradient color
        let schoolColorString = athlete.schoolColor
        let topColor = ColorHelper.color(fromHexString: schoolColorString, colorCorrection: true)
        let bottomColor = topColor?.withAlphaComponent(0.5)
        //let topColor = UIColor(red: 0.0, green: 74.0/255.0, blue: 206.0/255.0, alpha: 1)
        //let bottomColor = UIColor(red: 0.0, green: 74.0/255.0, blue: 206.0/255.0, alpha: 0.5)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: kDeviceWidth - 40, height: topBackgroundView!.frame.size.height)
        gradientLayer.colors = [topColor!.cgColor, bottomColor!.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        topBackgroundView!.layer.insertSublayer(gradientLayer, at: 0)
                
        let title = award["athleteName"] as! String
        titleLabel?.text = title
        
        let subtitle = award["comments"] as! String
        subtitleLabel?.text = subtitle
                
        // Load the badgeUrl
        let urlString = award["badgeUrl"] as! String
                    
        if (urlString.count > 0)
        {
            let url = URL(string: urlString)
            
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.iconImageView!.image = image
                    }
                    else
                    {
                        self.iconImageView!.image = UIImage(named: "XmanLogo")
                    }
                }
            }
        }
        else
        {
            self.iconImageView!.image = UIImage(named: "XmanLogo")
        }
        
        /*
         Printing description of award:
         ▿ 12 elements
           ▿ 0 : 2 elements
             - key : "awardName"
             - value : Analyst Award
           ▿ 1 : 2 elements
             - key : "timeStampString"
             - value : Jan 26, 2021
           ▿ 2 : 2 elements
             - key : "timeStamp"
             - value : 2021-01-26T11:45:00
           ▿ 3 : 2 elements
             - key : "sportSeasonId"
             - value : a9cbf684-16ef-4997-9539-15fefe9df410
           ▿ 4 : 2 elements
             - key : "athleteName"
             - value : Jaxson Dart
           ▿ 5 : 2 elements
             - key : "athleteId"
             - value : cbde04ce-7989-483c-96ca-09ee29ce4143
           ▿ 6 : 2 elements
             - key : "teamId"
             - value : 7e4dce6a-b7c1-4d9a-959c-892cd4b227df
           ▿ 7 : 2 elements
             - key : "storyLinkUrl"
             - value : https://www.maxpreps.com/news/CbPAwRvb6UKj3w50Cb572w/maxpreps-high-school-football-player-of-the-year-in-each-state.htm
           ▿ 8 : 2 elements
             - key : "badgeUrl"
             - value : https://images.maxpreps.com/analyst/category/cb6f83b3-d867-eb11-80ce-a444a33a3a97.png?version=637613654184418188
           ▿ 9 : 2 elements
             - key : "type"
             - value : MaxPreps High School Football Player of the Year - Utah Player of the Year
           ▿ 10 : 2 elements
             - key : "storyLinkText"
             - value : View Story
           ▿ 11 : 2 elements
             - key : "comments"
             - value : Congratulations to Jaxson Dart of Corner Canyon High School for being selected to the MaxPreps High School Football Player of the Year - Utah Player of the Year.
         */
    }
    
    // MARK: - Gesture Methods
    
    @objc func handleTap(sender: UITapGestureRecognizer)
    {
        // Animate the roundRectView and blackBackgroundView
        UIView.animate(withDuration: 0.24, animations:
                        {
                            self.containerView?.transform = CGAffineTransform(translationX: 0, y: kDeviceHeight)
                            self.blackBackgroundView?.alpha = 0.0
                        })
        { (finished) in
            
            self.delegate?.closeAnalystAwardDetailView()
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
        
        containerView = UIView(frame: CGRect(x: Int((kDeviceWidth - 335) / 2.0), y: Int((kDeviceHeight - 340) / 2.0), width: 335, height: 340))
        containerView?.backgroundColor = UIColor.mpWhiteColor()
        containerView?.layer.cornerRadius = 12
        containerView?.clipsToBounds = true
        
        //let shift = kDeviceHeight - ((kDeviceHeight - 340) / 2.0)
        containerView?.transform = CGAffineTransform(translationX: 0, y: kDeviceHeight)
        self.addSubview(containerView!)
        
        // Top backgroundView with a gradient layer
        topBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: (containerView?.frame.size.width)!, height: 110))
        topBackgroundView?.backgroundColor = .black
        containerView?.addSubview(topBackgroundView!)
        
        /*
        let topColor = UIColor(red: 0.0, green: 74.0/255.0, blue: 206.0/255.0, alpha: 1)
        let bottomColor = UIColor(red: 0.0, green: 74.0/255.0, blue: 206.0/255.0, alpha: 0.5)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: kDeviceWidth - 40, height: topBackgroundView!.frame.size.height)
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        topBackgroundView!.layer.insertSublayer(gradientLayer, at: 0)
        */
        
        // Add the icon containerView and iconImageView
        iconContainerView = UIView(frame: CGRect(x: ((containerView?.frame.size.width)! - 140) / 2.0, y: 40, width: 140, height: 140))
        iconContainerView?.backgroundColor = UIColor.mpWhiteColor()
        iconContainerView?.layer.cornerRadius = 70.0
        iconContainerView?.layer.borderWidth = 5.0
        iconContainerView?.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        iconContainerView?.clipsToBounds = true
        containerView?.addSubview(iconContainerView!)
        
        iconImageView = UIImageView(frame: CGRect(x: 25, y: 25, width: 90, height: 90))
        iconImageView?.contentMode = .scaleAspectFit
        iconImageView?.clipsToBounds = true
        iconContainerView?.addSubview(iconImageView!)
        
        titleLabel = UILabel(frame: CGRect(x: 20, y: 195, width: (containerView?.frame.size.width)! - 40, height: 20))
        titleLabel?.textColor = UIColor.mpBlackColor()
        titleLabel?.textAlignment = .center
        titleLabel?.font = UIFont.mpBoldFontWith(size: 17)
        containerView?.addSubview(titleLabel!)
        
        subtitleLabel = UILabel(frame: CGRect(x: 20, y: 225, width: (containerView?.frame.size.width)! - 40, height: 100))
        subtitleLabel?.numberOfLines = 5
        subtitleLabel?.textColor = UIColor.mpGrayColor()
        subtitleLabel?.textAlignment = .center
        subtitleLabel?.font = UIFont.mpRegularFontWith(size: 15)
        containerView?.addSubview(subtitleLabel!)
        
        /*
        iconContainerView = UIView(frame: CGRect(x: ((containerView?.frame.size.width)! - 72) / 2.0, y: 20, width: 72, height: 72))
        iconContainerView?.backgroundColor = UIColor.mpWhiteColor()
        iconContainerView!.layer.cornerRadius = iconContainerView!.frame.size.width / 2.0
        iconContainerView!.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        iconContainerView!.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        iconContainerView!.layer.shadowOpacity = 1.0
        iconContainerView!.layer.shadowRadius = 4.0
        iconContainerView!.clipsToBounds = false
        containerView?.addSubview(iconContainerView!)
        */

        // Animate the imageView and blackBackgroundView
        UIView.animate(withDuration: 0.24, animations:
                        {
                            self.containerView?.transform = CGAffineTransform(translationX: 0, y: -10)
                            self.blackBackgroundView?.alpha = 0.7
                        })
        { (finished) in
            UIView.animate(withDuration: 0.24, animations:
                            {
                                self.containerView?.transform = CGAffineTransform(translationX: 0, y: 5)
                                
                            })
            { (finished) in
                UIView.animate(withDuration: 0.24, animations:
                                {
                                    self.containerView?.transform = CGAffineTransform(translationX: 0, y: 0)
                                    
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
