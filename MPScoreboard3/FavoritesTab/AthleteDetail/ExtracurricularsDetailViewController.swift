//
//  ExtracurricularsDetailViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 9/5/23.
//

import UIKit

protocol ExtracurricularsDetailViewControllerDelegate: AnyObject
{
    func extracurricularsDetailViewControllerDidClose()
}

class ExtracurricularsDetailViewController: UIViewController, UIAdaptivePresentationControllerDelegate
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    weak var delegate: ExtracurricularsDetailViewControllerDelegate?
    
    var data: Dictionary<String,Any> = [:]
    
    // MARK: - Presentation Controller Delegate Methods
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool
    {
        return false // <-prevents the modal sheet from being closed
    }

    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController)
    {
        // called after the modal sheet was prevented from being closed and leads to your own logic
        self.delegate?.extracurricularsDetailViewControllerDidClose()
    }
    
    // MARK: - Button Methods
    
    @IBAction func closeButtonTouched()
    {
        self.delegate?.extracurricularsDetailViewControllerDidClose()
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
        
        let title = data["activity"] as? String ?? ""
        let description = data["description"] as? String ?? ""
        let role = data["role"] as? String ?? ""

        titleLabel.text = title
        subtitleLabel.text = role
        descriptionTextView.text = description

    }
}
