//
//  AchievementsAwardsDetailViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/23/23.
//

import UIKit

protocol AchievementsAwardsDetailViewControllerDelegate: AnyObject
{
    func achievementsAwardsDetailViewControllerDidClose()
}

class AchievementsAwardsDetailViewController: UIViewController, UIAdaptivePresentationControllerDelegate
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    weak var delegate: AchievementsAwardsDetailViewControllerDelegate?
    
    var data: Dictionary<String,Any> = [:]
    
    // MARK: - Presentation Controller Delegate Methods
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool
    {
        return false // <-prevents the modal sheet from being closed
    }

    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController)
    {
        // called after the modal sheet was prevented from being closed and leads to your own logic
        self.delegate?.achievementsAwardsDetailViewControllerDidClose()
    }
    
    // MARK: - Button Methods
    
    @IBAction func closeButtonTouched()
    {
        self.delegate?.achievementsAwardsDetailViewControllerDidClose()
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 12
        self.view.layer.maskedCorners =  [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.view.clipsToBounds = true
        
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
                
        self.presentationController?.delegate = self
        
        let title = data["title"] as? String ?? ""
        let description = data["description"] as? String ?? ""
        let achievedOnDate = data["achievedOn"] as? String ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.isLenient = true
        dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
        let update = dateFormatter.date(from: achievedOnDate)
        if (update != nil)
        {
            dateFormatter.dateFormat = "MMM d, yyyy"
            let dateString = dateFormatter.string(from: update!)
            subtitleLabel.text = dateString
        }
        else
        {
            subtitleLabel.text = ""
        }
        
        titleLabel.text = title
        descriptionTextView.text = description

    }
}
