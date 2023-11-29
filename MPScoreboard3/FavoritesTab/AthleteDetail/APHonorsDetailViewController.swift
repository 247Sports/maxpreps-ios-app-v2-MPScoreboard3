//
//  APHonorsDetailViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/8/23.
//

import UIKit

protocol APHonorsDetailViewControllerDelegate: AnyObject
{
    func apHonorsDetailViewControllerDidClose()
}

class APHonorsDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAdaptivePresentationControllerDelegate
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dataTableView: UITableView!
    
    weak var delegate: APHonorsDetailViewControllerDelegate?
    
    var titleString = ""
    var dataArray: Array<String> = []
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 48.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // APHonors Cell
        var cell = tableView.dequeueReusableCell(withIdentifier: "APHonorsTableViewCell") as? APHonorsTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("APHonorsTableViewCell", owner: self, options: nil)
            cell = nib![0] as? APHonorsTableViewCell
        }
        
        cell?.selectionStyle = .none
        
        let title = dataArray[indexPath.row]
        //cell?.titleLabel.text = String(format: "%d. %@", indexPath.row + 1, title)
        cell?.titleLabel.text = title
        
        // Decide how to round the cells
        cell?.containerView.layer.cornerRadius = 0
        cell?.containerView.clipsToBounds = true
        cell?.horizLine.isHidden = false
        
        if (dataArray.count == 1)
        {
            // Round all corners of the cell
            cell?.containerView.layer.cornerRadius = 8
        }
        else
        {
            // Round the first and last cells only
            if (indexPath.row == 0)
            {
                cell?.containerView.layer.cornerRadius = 8
                cell?.containerView.layer.maskedCorners =  [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
            
            if (indexPath.row == (dataArray.count - 1))
            {
                cell?.containerView.layer.cornerRadius = 8
                cell?.containerView.layer.maskedCorners =  [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
        }
        
        // Get rid of the last horizLine
        if (indexPath.row == dataArray.count - 1)
        {
            cell?.horizLine.isHidden = true
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Presentation Controller Delegate Methods
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool
    {
        return false // <-prevents the modal sheet from being closed
    }

    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController)
    {
        // called after the modal sheet was prevented from being closed and leads to your own logic
        self.delegate?.apHonorsDetailViewControllerDidClose()
    }
    
    // MARK: - Button Methods
    
    @IBAction func closeButtonTouched()
    {
        self.delegate?.apHonorsDetailViewControllerDidClose()
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 12
        self.view.layer.maskedCorners =  [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.view.clipsToBounds = true
        
        titleLabel.text = titleString
        
        self.presentationController?.delegate = self

    }
}
