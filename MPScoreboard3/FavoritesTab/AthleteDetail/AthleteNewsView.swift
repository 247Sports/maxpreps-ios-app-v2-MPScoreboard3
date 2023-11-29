//
//  AthleteNewsView.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/20/21.
//

import UIKit

protocol AthleteNewsViewDelegate: AnyObject
{
    func athleteNewsViewDidScroll(_ yScroll : Int)
    func athleteNewsWebButtonTouched(urlString: String, title: String)
}

class AthleteNewsView: UIView, UITableViewDelegate, UITableViewDataSource
{
    weak var delegate: AthleteNewsViewDelegate?
    
    var selectedAthlete : Athlete?
    
    private var newsTableView: UITableView!
    private var newsArray = [] as! Array<Dictionary<String,Any>>
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Get News
        
    func getCareerNews()
    {
        // Show the busy indicator
        //MBProgressHUD.showAdded(to: self, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        let careerId = self.selectedAthlete!.careerId
        
        CareerFeeds.getCareerNews(careerId) { [self] (result, error) in
            
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                //MBProgressHUD.hide(for: self, animated: true)
                if (self.progressOverlay != nil)
                {
                    self.progressOverlay.hide(animated: false)
                    self.progressOverlay = nil
                }
            }
            
            if error == nil
            {
                print("Get career news success.")
                let news = result!["articles"] as! Array<Dictionary<String,Any>>
                newsArray = news
            }
            else
            {
                print("Get career news failed.")
                
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "There was a problem getting the news from the server.", lastItemCancelType: false) { (tag) in
                    
                }
            }
            
            self.newsTableView.reloadData()
        }
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return newsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 188.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        // Calculate the footer required if the content doesn't exceed the visible region by at least 180
        let contentHeight = newsArray.count * 120
        let tableViewVisibleHeight = self.frame.size.height - 180
        let difference = contentHeight - Int(tableViewVisibleHeight)
        print("Height Difference: " + String(difference))
        
        if (difference > 0) && (difference <= 180)
        {
            let pad = CGFloat(180 - difference)
            return pad + 62
        }
        else
        {
            return 8.0 + 62
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 188))
        view.backgroundColor = UIColor.mpWhiteColor()
        
        let grayView = UIView(frame: CGRect(x: 0, y: 180, width: tableView.frame.size.width, height: 8))
        grayView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        view.addSubview(grayView)

        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "AthleteNewsTableViewCell") as? AthleteNewsTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("AthleteNewsTableViewCell", owner: self, options: nil)
            cell = nib![0] as? AthleteNewsTableViewCell
        }
        
        cell?.selectionStyle = .none
        cell?.titleLabel.text = ""
        cell?.subtitleLabel.text = ""
        cell?.thumbnailImageView.image = nil;
        
        let article = newsArray[indexPath.row]
    
        //let headline = article["headline"] as! String
        let headline = article["listHeadline"] as! String
        cell?.titleLabel.text = headline
        
        let writerFirstName = article["writerFirstName"] as! String
        let writerLastName = article["writerLastName"] as! String
        cell?.subtitleLabel.text = "By " + writerFirstName + " " + writerLastName
        
        let date = article["publishedOnString"] as! String
        cell?.dateLabel.text = date
        
        let thumbnailUrl = article["thumbnailUrl"] as! String
        
        if (thumbnailUrl.count > 0)
        {
            // Get the data and make an image
            let url = URL(string: thumbnailUrl)
            
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        cell?.thumbnailImageView?.image = image
                    }
                    else
                    {
                        cell?.thumbnailImageView?.image = UIImage(named: "EmptyArticleImage")
                    }
                }
            }
        }
        else
        {
            cell?.thumbnailImageView?.image = UIImage(named: "EmptyArticleImage")
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let article = newsArray[indexPath.row]
    
        let urlString = article["canonicalUrl"] as! String
    
        self.delegate?.athleteNewsWebButtonTouched(urlString: urlString, title: "Article")
    }
    
    // MARK: - Set TableView Scroll Location
    
    func setTableViewScrollLocation(yScroll: Int)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
        {
            self.newsTableView.contentOffset = CGPoint(x: 0, y: yScroll)
        }
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        self.delegate?.athleteNewsViewDidScroll(Int(scrollView.contentOffset.y))
    }
    
    // MARK: - Init Method
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        // Add the tableView
        newsTableView = UITableView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), style: .grouped)
        newsTableView.delegate = self
        newsTableView.dataSource = self
        newsTableView.separatorStyle = .none
        self.addSubview(newsTableView)
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
