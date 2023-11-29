//
//  CalendarViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/17/21.
//

import UIKit

protocol CalendarViewControllerDelegate: AnyObject
{
    func calendarViewControllerCancelButtonTouched()
    func calendarViewControllerSelectedDateButtonTouched()
}

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource
{
    weak var delegate: CalendarViewControllerDelegate?
    
    var selectedDate: Date!
    var availableDates: Array<Date>!
    var allContests: Array<Dictionary<String,Any>>!
    
    private var calendar: FSCalendar!
    
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var bottomContainerTitleLabel: UILabel!
    @IBOutlet weak var selectDateButton: UIButton!
    
    // MARK: - FSCalendar Delegates
    
    func minimumDate(for calendar: FSCalendar) -> Date
    {
        return MiscHelper.getTwoYearCalendarSpan(start: true)
        /*
        let today = Date()
        let gregorian = Calendar(identifier: .gregorian)
        var offsetComponents = DateComponents()
        offsetComponents.month = -12 // 12 months ago
        let minimumDate = gregorian.date(byAdding: offsetComponents, to: today)!
        return minimumDate
        */
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date
    {
        return MiscHelper.getTwoYearCalendarSpan(start: false)
        /*
        let today = Date()
        let gregorian = Calendar(identifier: .gregorian)
        var offsetComponents = DateComponents()
        offsetComponents.month = 12 // 12 momths from today
        let maximimumDate = gregorian.date(byAdding: offsetComponents, to: today)!
        return maximimumDate
        */
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int
    {
        let calendar = Calendar(identifier: .gregorian)
        var match = false
        
        for contestDate in self.availableDates
        {
            if (calendar.isDate(date, inSameDayAs: contestDate) == true)
            {
                match = true
                break
            }
        }
        
        if (match == true)
        {
            return 1
        }
        else
        {
            return 0
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        self.selectedDate = date
        
        let calendar = Calendar(identifier: .gregorian)
        var match = false
        var index = 0
        
        for contestDate in availableDates
        {
            if (calendar.isDate(date, inSameDayAs: contestDate) == true)
            {
                match = true
                break
            }
            index += 1
        }
        
        if (match == true)
        {
            let matchingDateObj = allContests[index]
            let contests = matchingDateObj["contestIds"] as! Array<String>
            let contestDate = availableDates[index]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M/d"
            let dateString = dateFormatter.string(from: contestDate)
            
            if (contests.count == 1)
            {
                let today = Date()
                
                if (calendar.isDate(date, inSameDayAs: today) == true)
                {
                    bottomContainerTitleLabel.text = String(contests.count) + " Game Today"
                }
                else
                {
                    bottomContainerTitleLabel.text = String(contests.count) + " Game on " + dateString
                }
            }
            else
            {
                let today = Date()
                
                if (calendar.isDate(date, inSameDayAs: today) == true)
                {
                    bottomContainerTitleLabel.text = String(contests.count) + " Games Today"
                }
                else
                {
                    bottomContainerTitleLabel.text = String(contests.count) + " Games on " + dateString
                }
            }
            selectDateButton.isEnabled = true
            selectDateButton.backgroundColor = UIColor.mpRedColor()
        }
        else
        {
            let today = Date()
            
            if (calendar.isDate(date, inSameDayAs: today) == true)
            {
                bottomContainerTitleLabel.text = "No Games Today"
            }
            else
            {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "M/d"
                let dateString = dateFormatter.string(from: date)
                
                bottomContainerTitleLabel.text = "No Games on " + dateString
            }
            selectDateButton.isEnabled = false
            selectDateButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func cancelButtonTouched(_ sender: UIButton)
    {
        self.delegate?.calendarViewControllerCancelButtonTouched()
    }
    
    @IBAction func selectDateButtonTouched(_ sender: UIButton)
    {
        self.delegate?.calendarViewControllerSelectedDateButtonTouched()
    }
    
    @IBAction func todayButtonTouched(_ sender: UIButton)
    {
        calendar.select(Date())
        
        // Initialize the UI again
        self.initializeUserInterface()
    }
    
    // MARK: - Initialize User Interface
    
    private func initializeUserInterface()
    {
        let today = Date()
        let calendar = Calendar(identifier: .gregorian)
        var match = false
        var index = 0
        
        for contestDate in availableDates
        {
            if (calendar.isDate(today, inSameDayAs: contestDate) == true)
            {
                match = true
                break
            }
            index += 1
        }
        
        if (match == true)
        {
            let matchingDateObj = allContests[index]
            let contests = matchingDateObj["contestIds"] as! Array<String>
            //let contestDate = availableDates[index]
            
            //let dateFormatter = DateFormatter()
            //dateFormatter.dateFormat = "M/d"
            //let dateString = dateFormatter.string(from: contestDate)
            
            if (contests.count == 1)
            {
                //bottomContainerTitleLabel.text = String(contests.count) + " Game on " + dateString
                bottomContainerTitleLabel.text = String(contests.count) + " Game Today"
            }
            else
            {
                //bottomContainerTitleLabel.text = String(contests.count) + " Games on " + dateString
                bottomContainerTitleLabel.text = String(contests.count) + " Games Today"
            }
            selectDateButton.isEnabled = true
            selectDateButton.backgroundColor = UIColor.mpRedColor()
        }
        else
        {
            bottomContainerTitleLabel.text = "No Games Today"
            selectDateButton.isEnabled = false
            selectDateButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        fakeStatusBar.backgroundColor = .clear
 
        // Size and locate the fakeStatusBar, navBar, containerScrollView, and tabBarContainer
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 76 + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        bottomContainerView.frame = CGRect(x: 0.0, y: kDeviceHeight - 110 - CGFloat(SharedData.bottomSafeAreaHeight), width: kDeviceWidth, height: 110 + CGFloat(SharedData.bottomSafeAreaHeight))
                
        navView.layer.cornerRadius = 12
        navView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navView.clipsToBounds = true
        
        selectDateButton.layer.cornerRadius = 8
        selectDateButton.clipsToBounds = true
        
        // Add a shadow to the bottomContainerView
        let shadowPath = UIBezierPath(rect: bottomContainerView.bounds)
        bottomContainerView.layer.masksToBounds = false
        bottomContainerView.layer.shadowColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        bottomContainerView.layer.shadowOffset = CGSize(width: 0, height: -3)
        bottomContainerView.layer.shadowOpacity = 0.5
        bottomContainerView.layer.shadowPath = shadowPath.cgPath
        
        // Add the calendar
        calendar = FSCalendar(frame: CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height - bottomContainerView.frame.size.height))
        calendar.delegate = self
        calendar.dataSource = self
        calendar.backgroundColor = UIColor.mpWhiteColor()
        self.view.insertSubview(calendar, belowSubview: bottomContainerView)
        
        calendar.pagingEnabled = false // Important
        calendar.allowsMultipleSelection = false
        calendar.firstWeekday = 1
        calendar.placeholderType = .none
        calendar.appearance.caseOptions = .headerUsesUpperCase
        calendar.appearance.weekdayTextColor = UIColor.mpBlackColor()
        calendar.appearance.headerTitleColor = UIColor.mpBlackColor()
        calendar.appearance.eventDefaultColor = UIColor.mpGreenColor()
        calendar.appearance.selectionColor = UIColor.mpRedColor()
        calendar.appearance.todayColor = UIColor.mpLightGrayColor()
        calendar.appearance.todaySelectionColor = UIColor.mpRedColor()
        calendar.appearance.separators = .none
        calendar.appearance.headerTitleFont = UIFont.mpBoldFontWith(size: 17)
        calendar.appearance.titleFont = UIFont.mpRegularFontWith(size: 14)
        calendar.appearance.weekdayFont = UIFont.mpSemiBoldFontWith(size: 14)
        calendar.rowHeight = 60
        
        calendar.select(Date())
        
        self.initializeUserInterface()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
                
        setNeedsStatusBarAppearanceUpdate()
        
        // Add some delay so the view is partially showing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            UIView.animate(withDuration: 0.3)
            { [self] in
                fakeStatusBar.backgroundColor = UIColor(white: 0, alpha: 0.6)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

    }

    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.lightContent
    }
    
    override open var shouldAutorotate: Bool
    {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation
    {
        return UIInterfaceOrientation.portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return .portrait
    }
}
