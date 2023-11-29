//
//  NewsStatsCollectionViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 12/23/21.
//

import UIKit

class NewsStatsCollectionViewCell: UICollectionViewCell, RoundSegmentControlViewDelegate
{
    // 50 Properties. Yikes!!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var genderSportLabel: UILabel!
    @IBOutlet weak var sportIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var fullTeamStatLeadersButton: UIButton!
    @IBOutlet weak var fullPlayerStatLeadersButton: UIButton!
    
    @IBOutlet weak var innerContainerView1: UIView!
    @IBOutlet weak var innerAthletePhotoImageView1: UIImageView!
    @IBOutlet weak var innerMascotImageView1: UIImageView!
    @IBOutlet weak var innerInitalLabel1: UILabel!
    @IBOutlet weak var innerCategoryLabel1: UILabel!
    @IBOutlet weak var innerTitleLabel1: UILabel!
    @IBOutlet weak var innerSubtitleLabel1: UILabel!
    @IBOutlet weak var innerPositionLabel1: UILabel!
    @IBOutlet weak var innerPointsLabel1: UILabel!
    @IBOutlet weak var innerShortCategoryLabel1: UILabel!
    @IBOutlet weak var innerButton1: UIButton!
    
    @IBOutlet weak var innerContainerView2: UIView!
    @IBOutlet weak var innerAthletePhotoImageView2: UIImageView!
    @IBOutlet weak var innerMascotImageView2: UIImageView!
    @IBOutlet weak var innerInitalLabel2: UILabel!
    @IBOutlet weak var innerCategoryLabel2: UILabel!
    @IBOutlet weak var innerTitleLabel2: UILabel!
    @IBOutlet weak var innerSubtitleLabel2: UILabel!
    @IBOutlet weak var innerPositionLabel2: UILabel!
    @IBOutlet weak var innerPointsLabel2: UILabel!
    @IBOutlet weak var innerShortCategoryLabel2: UILabel!
    @IBOutlet weak var innerButton2: UIButton!
    
    @IBOutlet weak var innerContainerView3: UIView!
    @IBOutlet weak var innerAthletePhotoImageView3: UIImageView!
    @IBOutlet weak var innerMascotImageView3: UIImageView!
    @IBOutlet weak var innerInitalLabel3: UILabel!
    @IBOutlet weak var innerCategoryLabel3: UILabel!
    @IBOutlet weak var innerTitleLabel3: UILabel!
    @IBOutlet weak var innerSubtitleLabel3: UILabel!
    @IBOutlet weak var innerPositionLabel3: UILabel!
    @IBOutlet weak var innerPointsLabel3: UILabel!
    @IBOutlet weak var innerShortCategoryLabel3: UILabel!
    @IBOutlet weak var innerButton3: UIButton!
    
    @IBOutlet weak var innerContainerView4: UIView!
    @IBOutlet weak var innerAthletePhotoImageView4: UIImageView!
    @IBOutlet weak var innerMascotImageView4: UIImageView!
    @IBOutlet weak var innerInitalLabel4: UILabel!
    @IBOutlet weak var innerCategoryLabel4: UILabel!
    @IBOutlet weak var innerTitleLabel4: UILabel!
    @IBOutlet weak var innerSubtitleLabel4: UILabel!
    @IBOutlet weak var innerPositionLabel4: UILabel!
    @IBOutlet weak var innerPointsLabel4: UILabel!
    @IBOutlet weak var innerShortCategoryLabel4: UILabel!
    @IBOutlet weak var innerButton4: UIButton!
    
    var roundSegmentControl: RoundSegmentControlView!
    
    // MARK: - RoundSegmentControlView Delegate
    
    func segmentChanged()
    {
        
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        containerView.clipsToBounds = true
        
        innerAthletePhotoImageView1.layer.cornerRadius = innerAthletePhotoImageView1.frame.size.width / 2.0
        innerAthletePhotoImageView1.clipsToBounds = true
        
        innerAthletePhotoImageView2.layer.cornerRadius = innerAthletePhotoImageView2.frame.size.width / 2.0
        innerAthletePhotoImageView2.clipsToBounds = true
        
        innerAthletePhotoImageView3.layer.cornerRadius = innerAthletePhotoImageView3.frame.size.width / 2.0
        innerAthletePhotoImageView3.clipsToBounds = true
        
        innerAthletePhotoImageView4.layer.cornerRadius = innerAthletePhotoImageView4.frame.size.width / 2.0
        innerAthletePhotoImageView4.clipsToBounds = true
        
        roundSegmentControl = RoundSegmentControlView(frame: CGRect(x: 16, y: 70, width: kDeviceWidth - 64, height: 32), buttonOneTitle: "PLAYER", buttonTwoTitle: "TEAM")
        roundSegmentControl.delegate = self
        containerView.addSubview(roundSegmentControl)
    }

}
