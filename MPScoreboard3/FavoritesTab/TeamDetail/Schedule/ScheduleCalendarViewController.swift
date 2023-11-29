//ScheduleCalendarViewController
//  .swift
//  MPScoreboard3
//
//  Created by David Smith on 9/29/21.
//

import UIKit

protocol ScheduleCalendarViewControllerDelegate: AnyObject
{
    func scheduleCalendarSelectButtonTouched()
    func scheduleCalendarCancelButtonTouched()
}

class ScheduleCalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource
{
    weak var delegate: ScheduleCalendarViewControllerDelegate?
    
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var selectDateButton: UIButton!
    @IBOutlet weak var tbaDateSwitch: UISwitch!

    var dimmedBackground = false
    var selectedDate = Date()
    var tbaDate = false
    var availableDates: Array<Date>!
    
    private var calendar: FSCalendar!
    
    // MARK: - FSCalendar Delegates
    
    func minimumDate(for calendar: FSCalendar) -> Date
    {
        return MiscHelper.getThreeYearCalendarSpan(start: true)
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date
    {
        return MiscHelper.getThreeYearCalendarSpan(start: false)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        self.selectedDate = date
        self.tbaDate = false
        
        tbaDateSwitch.isOn = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        let dateString = dateFormatter.string(from: selectedDate)
        selectDateButton.setTitle("SELECT " + dateString, for: .normal)
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
    
    // MARK: - Button Methods
    
    @IBAction func cancelButtonTouched(_ sender: UIButton)
    {
        self.delegate?.scheduleCalendarCancelButtonTouched()
    }
    
    @IBAction func selectButtonTouched(_ sender: UIButton)
    {
        self.delegate?.scheduleCalendarSelectButtonTouched()
    }
    
    @IBAction func todayButtonTouched(_ sender: UIButton)
    {
        let today = Date()
        calendar.select(today)
        selectedDate = today
        tbaDate = false
        tbaDateSwitch.isOn = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        let dateString = dateFormatter.string(from: selectedDate)
        selectDateButton.setTitle("SELECT " + dateString, for: .normal)
    }
    
    @IBAction func tbaDateSwitchChanged()
    {
        if (tbaDateSwitch.isOn == true)
        {
            selectDateButton.setTitle("SELECT TBA", for: .normal)
            tbaDate = true
        }
        else
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M/d"
            let dateString = dateFormatter.string(from: selectedDate)
            selectDateButton.setTitle("SELECT " + dateString, for: .normal)
            tbaDate = false
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Size and locate the fakeStatusBar, navBar, containerScrollView, and tabBarContainer
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 76 + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        bottomContainerView.frame = CGRect(x: 0.0, y: kDeviceHeight - 110 - CGFloat(SharedData.bottomSafeAreaHeight), width: kDeviceWidth, height: 110 + CGFloat(SharedData.bottomSafeAreaHeight))
        //calendarView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: CGFloat(kDeviceHeight) - navView.frame.size.height - fakeStatusBar.frame.size.height - 12)
         
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
        
        tbaDateSwitch.layer.cornerRadius = 16
        tbaDateSwitch.clipsToBounds = true
        tbaDateSwitch.backgroundColor = UIColor.mpOffWhiteNavColor()
        tbaDateSwitch.onTintColor = UIColor.mpRedColor()
        
        // Initialize the date button
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        let dateString = dateFormatter.string(from: selectedDate)
        selectDateButton.setTitle("SELECT " + dateString, for: .normal)
        
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
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if (dimmedBackground == true)
        {
            // Add some delay so the view is partially showing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
            {
                UIView.animate(withDuration: 0.3)
                { [self] in
                    fakeStatusBar.backgroundColor = UIColor(white: 0, alpha: 0.6)
                }
            }
        }
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
