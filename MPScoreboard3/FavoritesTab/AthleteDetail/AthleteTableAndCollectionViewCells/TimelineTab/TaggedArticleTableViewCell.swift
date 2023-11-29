//
//  TaggedArticleTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/2/21.
//

import UIKit

class TaggedArticleTableViewCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var innerTitleLabel: UILabel!
    @IBOutlet weak var innerSubtitleLabel: UILabel!
    @IBOutlet weak var innerImageView: UIImageView!
    @IBOutlet weak var viewMoreButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    // MARK: - Load Data
    
    func loadData(itemData: Dictionary<String,Any>)
    {
        /*
         0 : 8 elements
                   ▿ 0 : 2 elements
                     - key : data
                     ▿ value : 5 elements
                       ▿ 0 : 2 elements
                         - key : subHeadline
                         - value : Though still battling "specialist" and "non-athlete" tag, kickers aren't asked to prove themselves in college as much as they used to; Roughly one in three Division I college football programs are signing kickers straight out of high school.
                       ▿ 1 : 2 elements
                         - key : thumbnailUrl
                         - value : https://images.maxpreps.com/editorial/article/d/b/d/dbdaa559-777b-40ce-8b02-ecd6884e7f8b/96a73fa4-ea56-e111-8395-002655e6c45a_original.jpg?version=634648194600000000
                       ▿ 2 : 2 elements
                         - key : writerName
                         - value : Mitch Stephens
                       ▿ 3 : 2 elements
                         - key : articleUrl
                         - value : https://dev.maxpreps.com/news/WaXa23t3zkCLAuzWiE5_iw/high-school-kickers-are-earning-keep,-signing-on-dotted-line.htm
                       ▿ 4 : 2 elements
                         - key : headline
                         - value : Kickers are earning their keep
                   ▿ 1 : 2 elements
                     - key : title
                     - value : Article
                   ▿ 2 : 2 elements
                     - key : timeStamp
                     - value : 2012-02-14T12:23:00
                   ▿ 3 : 2 elements
                     - key : text
                     - value : Jon David Smith has been tagged in the article "Kickers are earning their keep".
                   ▿ 4 : 2 elements
                     - key : links
                     ▿ value : 1 element
                       ▿ 0 : 2 elements
                         ▿ 0 : 2 elements
                           - key : url
                           - value : https://dev.maxpreps.com/athlete/jon-david-smith/YvH-N_TlEeKZ5AAmVebBJg/news.htm
                         ▿ 1 : 2 elements
                           - key : text
                           - value : View More Articles
                   ▿ 5 : 2 elements
                     - key : type
                     - value : 1
                   ▿ 6 : 2 elements
                     - key : timeStampString
                     - value : Tuesday, Feb 14, 2012
                   ▿ 7 : 2 elements
                     - key : shareLink
                     - value : https://dev.maxpreps.com/news/WaXa23t3zkCLAuzWiE5_iw/high-school-kickers-are-earning-keep,-signing-on-dotted-line.htm
         */
        let title = itemData["title"] as! String
        titleLabel.text = title
        
        let subtitle = itemData["text"] as! String
        subtitleLabel.text = subtitle
        
        let timeText = itemData["timeStampString"] as! String
        dateLabel.text = timeText
        
        let links = itemData["links"] as! Array<Dictionary<String,String>>
        let link = links.first
        let moreButtonTitle = link!["text"]
        viewMoreButton.setTitle(moreButtonTitle, for: .normal)
        
        let data = itemData["data"] as! Dictionary<String,Any>
        
        let headline = data["headline"] as? String ?? ""
        innerTitleLabel.text = headline
        
        let writerName = data["writerName"] as? String ?? ""
        innerSubtitleLabel.text = "By: " + writerName
        
        let innerImageUrlString = data["thumbnailUrl"] as? String ?? ""
        
        if (innerImageUrlString.count > 0)
        {
            let url = URL(string: innerImageUrlString)
            
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.innerImageView.image = image
                    }
                    else
                    {
                        self.innerImageView.image = UIImage(named: "EmptyArticleImage")
                    }
                }
            }
        }
        else
        {
            self.innerImageView.image = UIImage(named: "EmptyArticleImage")
        }
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        innerContainerView.layer.cornerRadius = 12
        innerContainerView.clipsToBounds = true
        
        innerImageView.layer.cornerRadius = 4
        innerImageView.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
