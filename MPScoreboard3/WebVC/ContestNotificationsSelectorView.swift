//
//  ContestNotificationsSelectorView.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/18/23.
//

import UIKit

protocol ContestNotificationsSelectorViewDelegate: AnyObject
{
    func contestNotificationsSelectorViewDidCancel()
}

class ContestNotificationsSelectorView: UIView, UITableViewDelegate, UITableViewDataSource
{
    weak var delegate: ContestNotificationsSelectorViewDelegate?
    
    private var roundRectView: UIView!
    private var notificationTableView: UITableView!
    
    private var notificationsArray: Array<Any> = []
    private var sportCopy = ""
    private var contestIdCopy = ""
    private var contestDateCopy = Date()
    
    // MARK: - Update Contest Notifications
    
    private func updateContestNotifications()
    {
        /*
        kContestNotificationsDictionaryKey // Dictionary
        kContestNotificationSettingsKey // Array
        kContestNotificationDateKey // String
        */
        var replacementNotificationObj: Dictionary<String,Any> = [:]
        replacementNotificationObj[kContestNotificationDateKey] = self.contestDateCopy
        replacementNotificationObj[kContestNotificationSettingsKey] = notificationsArray
        
        var existingContestNotifications = kUserDefaults.dictionary(forKey: kContestNotificationsDictionaryKey)
        
        // Get the current notification for this contestId
        // Add the replacement notification and save to prefs
        existingContestNotifications![self.contestIdCopy] = replacementNotificationObj
        kUserDefaults.set(existingContestNotifications, forKey: kContestNotificationsDictionaryKey)
        
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return notificationsArray.count
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
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if (cell == nil)
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }
        
        cell?.selectionStyle = .none
        
        let notificationObj = notificationsArray[indexPath.row] as! Dictionary<String,Any>

        cell?.textLabel?.text = notificationObj[kNewNotificationNameKey] as? String ?? ""
        cell?.textLabel?.textColor = UIColor.mpBlackColor()
        cell?.textLabel?.font = UIFont.mpRegularFontWith(size: 15.0)
        
        // Add a notification switch
        let notificationSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        notificationSwitch.center = CGPoint(x: tableView.frame.size.width - (notificationSwitch.bounds.size.width / 2.0) - 16, y: 24.0)
        notificationSwitch.backgroundColor = .clear
        notificationSwitch.onTintColor = UIColor.mpRedColor()
        notificationSwitch.tag = 100 + indexPath.row
        notificationSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell?.contentView.addSubview(notificationSwitch)
        
        // Update the switch state
        notificationSwitch.isOn = notificationObj[kNewNotificationIsEnabledForAppKey] as! Bool
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Switch Changed Method
    
    @objc private func switchChanged(_ sender: UISwitch)
    {
        let index = sender.tag - 100
        var notification = notificationsArray[index] as! Dictionary<String,Any>
        notification[kNewNotificationIsEnabledForAppKey] = sender.isOn
        notificationsArray[index] = notification
    }
    
    // MARK: - Button Methods
    
    @objc func closeButtonTouched()
    {
        // Update the data
        self.updateContestNotifications()
        
        // Animate back
        let scaleTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        let translateTransform = CGAffineTransform(translationX: (roundRectView.frame.size.width / 2.0), y: -roundRectView.frame.size.height / 2.0)
        
        UIView.animate(withDuration: 0.33, animations: {
            
            // Return to the button location
            self.roundRectView.alpha = 0
            self.roundRectView.transform = CGAffineTransformConcat(scaleTransform, translateTransform)
        })
        { (finished) in
            
            self.delegate?.contestNotificationsSelectorViewDidCancel()
        }
    }
    
    // MARK: - Gesture Methods
    
    @objc func handleTap(sender: UITapGestureRecognizer)
    {
        // Update the data
        self.updateContestNotifications()
        
        // Animate back
        let scaleTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        let translateTransform = CGAffineTransform(translationX: (roundRectView.frame.size.width / 2.0), y: -roundRectView.frame.size.height / 2.0)
        
        UIView.animate(withDuration: 0.33, animations: {
            
            // Return to the button location
            self.roundRectView.alpha = 0
            self.roundRectView.transform = CGAffineTransformConcat(scaleTransform, translateTransform)
        })
        { (finished) in
            
            self.delegate?.contestNotificationsSelectorViewDidCancel()
        }
    }
    
    // MARK: - Init Methods
    
    required init(frame: CGRect, buttonFrame: CGRect, contestId: String, sport: String, contestDate: Date)
    {
        super.init(frame: frame)
        
        self.sportCopy = sport
        self.contestIdCopy = contestId
        self.contestDateCopy = contestDate
        
        print(self.sportCopy)
        print(self.contestIdCopy)
        
        self.backgroundColor = .clear
        
        let clearBackgroundView = UIView(frame: frame)
        clearBackgroundView.backgroundColor = .clear
        self.addSubview(clearBackgroundView)
        
        // Add a tap gesture recognizer to the blackBackgroundView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        clearBackgroundView.addGestureRecognizer(tapGesture)
        
        // Calculate the height and build the notificationsArray
        var height = 0
        let existingContestNotifications = kUserDefaults.dictionary(forKey: kContestNotificationsDictionaryKey)
        
        if (sport == "Football")
        {
            height = (kFootballContestNotifications.count * 48)
            
            // Use the defaults if this contest didn't exist in prefs
            if (existingContestNotifications![self.contestIdCopy] != nil)
            {
                let existingContestNotification = existingContestNotifications![self.contestIdCopy] as! Dictionary<String,Any>
                notificationsArray = existingContestNotification[kContestNotificationSettingsKey] as! Array<Any>
            }
            else
            {
                notificationsArray = kFootballContestNotifications
            }
        }
        else if (sport == "Basketball")
        {
            height = (kBasketballContestNotifications.count * 48)
            
            // Use the defaults if this contest didn't exist in prefs
            if (existingContestNotifications![self.contestIdCopy] != nil)
            {
                let existingContestNotification = existingContestNotifications![self.contestIdCopy] as! Dictionary<String,Any>
                notificationsArray = existingContestNotification[kContestNotificationSettingsKey] as! Array<Any>
            }
            else
            {
                notificationsArray = kBasketballContestNotifications
            }
        }
        else
        {
            height = (kOtherSportContestNotifications.count * 48)
            
            // Use the defaults if this contest didn't exist in prefs
            if (existingContestNotifications![self.contestIdCopy] != nil)
            {
                let existingContestNotification = existingContestNotifications![self.contestIdCopy] as! Dictionary<String,Any>
                notificationsArray = existingContestNotification[kContestNotificationSettingsKey] as! Array<Any>
            }
            else
            {
                notificationsArray = kOtherSportContestNotifications
            }
        }
        
        roundRectView = UIView(frame: CGRect(x: 32.0, y: buttonFrame.origin.y + buttonFrame.size.height, width: frame.size.width - 64.0, height: CGFloat(height + 108)))
        roundRectView.backgroundColor = UIColor.mpWhiteColor()
        roundRectView.layer.cornerRadius = 12
        
        // Add a shadow to the view
        roundRectView.layer.masksToBounds = false
        roundRectView.layer.shadowColor = UIColor(white: 0.6, alpha: 1.0).cgColor
        roundRectView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        roundRectView.layer.shadowRadius = 4
        roundRectView.layer.shadowOpacity = 0.5
        self.addSubview(roundRectView)
        
        let titleLabel = UILabel(frame: CGRect(x: 16.0, y: 12, width: 150.0, height: 24.0))
        titleLabel.textColor = UIColor.mpBlackColor()
        titleLabel.font = UIFont.mpBoldFontWith(size: 17.0)
        titleLabel.text = "Set Alerts"
        roundRectView.addSubview(titleLabel)
        
        let horizLine1 = UIView(frame: CGRect(x: 0, y: 47, width: roundRectView.frame.size.width, height: 1))
        horizLine1.backgroundColor = UIColor.mpHeaderBackgroundColor()
        roundRectView.addSubview(horizLine1)
        
        let horizLine2 = UIView(frame: CGRect(x: 0, y: roundRectView.frame.size.height - 60.0, width: roundRectView.frame.size.width, height: 1))
        horizLine2.backgroundColor = UIColor.mpHeaderBackgroundColor()
        roundRectView.addSubview(horizLine2)
        
        notificationTableView = UITableView(frame: CGRect(x: 0, y: 48.0, width: roundRectView.frame.size.width, height: CGFloat(height)), style: .grouped)
        notificationTableView.backgroundColor = UIColor.mpWhiteColor()
        notificationTableView.separatorStyle = .none
        notificationTableView.delegate = self
        notificationTableView.dataSource = self
        notificationTableView.contentInsetAdjustmentBehavior = .never
        notificationTableView.isScrollEnabled = false
        roundRectView.addSubview(notificationTableView)
        
        let closeButton = UIButton(type: .system)
        closeButton.frame = CGRect(x: 16.0, y: roundRectView.frame.size.height - 44.0, width: roundRectView.frame.size.width - 32.0, height: 28.0)
        closeButton.layer.cornerRadius = 8
        closeButton.clipsToBounds = true
        closeButton.backgroundColor = UIColor.mpBlackColor()
        closeButton.setTitle("Done", for: .normal)
        closeButton.setTitleColor(UIColor.mpWhiteColor(), for: .normal)
        closeButton.contentHorizontalAlignment = .center
        closeButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 15)
        closeButton.addTarget(self, action: #selector(closeButtonTouched), for: .touchUpInside)
        roundRectView.addSubview(closeButton)
        
        
        // Transform and shrink the view to the button location
        let scaleTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        let translateTransform = CGAffineTransform(translationX: (roundRectView.frame.size.width / 2.0), y: -roundRectView.frame.size.height / 2.0)
        roundRectView.transform = CGAffineTransformConcat(scaleTransform, translateTransform)
        roundRectView.alpha = 0
 
        // Animate to full size and rotate the button
        UIView.animate(withDuration: 0.33, animations: {
            
            self.roundRectView.alpha = 1.0
            self.roundRectView.transform = .identity
        })
        { (finished) in
            
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

}
