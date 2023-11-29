//
//  SearchSportViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/1/21.
//

import UIKit

protocol SearchSportViewControllerDelegate: AnyObject
{
    func searchSportSelectButtonTouched()
    func searchSportCancelButtonTouched()
}

class SearchSportViewController: UIViewController
{
    weak var delegate: SearchSportViewControllerDelegate?
    
    var selectedSport = ""
    var selectedGender = ""
    var showReducedSports = false
    
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    
    private var boysSports = [] as Array<String>
    private var girlsSports = [] as Array<String>
    
    // MARK: - Build Sport Containers
    
    private func buildSportContainers()
    {
        let cellWidth = Int((containerScrollView.frame.size.width - 40) / 2)
        let cellHeight = 44
        let startY = 40
        let labelPadX = 40
        let boysStartX = 20
        let girlsStartX = boysStartX + cellWidth
        var index = 0
        
        // Build the boys first
        let boysHeaderLabel = UILabel(frame: CGRect(x: 20, y: 10, width: 100, height: 30))
        boysHeaderLabel.font = UIFont.mpSemiBoldFontWith(size: 14)
        boysHeaderLabel.textColor = UIColor.mpGrayColor()
        boysHeaderLabel.text = "BOYS"
        containerScrollView.addSubview(boysHeaderLabel)
        
        for boysSport in boysSports
        {
            let containerView = UIView(frame: CGRect(x: boysStartX, y: startY + (index * cellHeight), width: cellWidth, height: cellHeight))
            containerView.backgroundColor = UIColor.mpWhiteColor()
            
            let titleLabel = UILabel(frame: CGRect(x: labelPadX, y: 12, width: cellWidth - labelPadX, height: 20))
            titleLabel.textColor = UIColor.mpBlackColor()
            titleLabel.font = UIFont.mpBoldFontWith(size: 15)
            titleLabel.text = boysSport
            
            let iconImageView = UIImageView(frame: CGRect(x: 0, y: 12, width: 20, height: 20))
            iconImageView.image = MiscHelper.getImageForSport(boysSport)
            
            let sportButton = UIButton(type: .custom)
            sportButton.frame = CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight)
            sportButton.backgroundColor = .clear
            sportButton.tag = 100 + index
            sportButton.addTarget(self, action: #selector(boysSportButtonTouched(_:)), for: .touchUpInside)
            
            containerView.addSubview(iconImageView)
            containerView.addSubview(titleLabel)
            containerView.addSubview(sportButton)
            containerScrollView.addSubview(containerView)
            
            index += 1
        }
        
        index = 0
        
        // Build the girls
        let girlsHeaderLabel = UILabel(frame: CGRect(x: 20 + cellWidth, y: 10, width: 100, height: 30))
        girlsHeaderLabel.font = UIFont.mpSemiBoldFontWith(size: 14)
        girlsHeaderLabel.textColor = UIColor.mpGrayColor()
        girlsHeaderLabel.text = "GIRLS"
        containerScrollView.addSubview(girlsHeaderLabel)
        
        for girlsSport in girlsSports
        {
            let containerView = UIView(frame: CGRect(x: girlsStartX, y: startY + (index * cellHeight), width: cellWidth, height: cellHeight))
            containerView.backgroundColor = UIColor.mpWhiteColor()
            
            let titleLabel = UILabel(frame: CGRect(x: labelPadX, y: 12, width: cellWidth - labelPadX, height: 20))
            titleLabel.textColor = UIColor.mpBlackColor()
            titleLabel.font = UIFont.mpBoldFontWith(size: 15)
            titleLabel.text = girlsSport
            
            let iconImageView = UIImageView(frame: CGRect(x: 0, y: 12, width: 20, height: 20))
            iconImageView.image = MiscHelper.getImageForSport(girlsSport)
            
            let sportButton = UIButton(type: .custom)
            sportButton.frame = CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight)
            sportButton.backgroundColor = .clear
            sportButton.tag = 100 + index
            sportButton.addTarget(self, action: #selector(girlsSportButtonTouched(_:)), for: .touchUpInside)
            
            containerView.addSubview(iconImageView)
            containerView.addSubview(titleLabel)
            containerView.addSubview(sportButton)
            containerScrollView.addSubview(containerView)
            
            index += 1
        }
        
        if (boysSports.count >= girlsSports.count)
        {
            let height = boysSports.count * cellHeight
            containerScrollView.contentSize = CGSize(width: Int(containerScrollView.frame.size.width), height: startY + height + 10)
        }
        else
        {
            let height = girlsSports.count * cellHeight
            containerScrollView.contentSize = CGSize(width: Int(containerScrollView.frame.size.width), height: startY + height + 10)
        }
        
    }
    
    // MARK: - Button Methods
    
    @IBAction func cancelButtonTouched(_ sender: UIButton)
    {
        self.delegate?.searchSportCancelButtonTouched()
    }
    
    @objc private func boysSportButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        selectedSport = boysSports[index]
        selectedGender = "Boys"
        
        self.delegate?.searchSportSelectButtonTouched()
    }
    
    @objc private func girlsSportButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        selectedSport = girlsSports[index]
        selectedGender = "Girls"
        
        self.delegate?.searchSportSelectButtonTouched()
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Size the fakeStatusBar, navBar, and containerScrollView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 80 + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        containerScrollView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height - 12, width: kDeviceWidth, height: kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height + 12 - CGFloat(SharedData.bottomSafeAreaHeight))
        
        navView.layer.cornerRadius = 12
        navView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navView.clipsToBounds = true
        
        fakeStatusBar.backgroundColor = .clear
        
        if (showReducedSports == true)
        {
            boysSports = kSearchReducedBoysSportsArray
            girlsSports = kSearchReducedGirlsSportsArray
        }
        else
        {
            boysSports = kSearchBoysSportsArray
            girlsSports = kSearchGirlsSportsArray
        }
        
        self.buildSportContainers()
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
