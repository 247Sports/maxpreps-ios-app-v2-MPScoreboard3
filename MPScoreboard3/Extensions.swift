//
//  Extensions.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/4/21.
//

import UIKit

// MARK: - Date Format Cheet Sheet
/*
 Wednesday, Sep 12, 2018           --> EEEE, MMM d, yyyy
 09/12/2018                        --> MM/dd/yyyy
 09-12-2018 14:11                  --> MM-dd-yyyy HH:mm
 Sep 12, 2:11 PM                   --> MMM d, h:mm a
 September 2018                    --> MMMM yyyy
 Sep 12, 2018                      --> MMM d, yyyy
 Wed, 12 Sep 2018 14:11:54 +0000   --> E, d MMM yyyy HH:mm:ss Z
 2018-09-12T14:11:54+0000          --> yyyy-MM-dd'T'HH:mm:ssZ
 12.09.18                          --> dd.MM.yy
 10:41:02.112                      --> HH:mm:ss.SSS
*/

// MARK: - Fonts

extension UIFont
{
    /*
        regular = 400
        semibold = 600
        bold = 700
        extrabold = 800
        heavy = 900
    */
    
    class func mpLightFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "siro-light", size: size)!
    }
    
    class func mpRegularFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "siro-regular", size: size)!
    }
    class func mpSemiBoldFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "siro-semibold", size: size)!
    }
    class func mpBoldFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "siro-bold", size: size)!
    }
    class func mpExtraBoldFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "siro-extrabold", size: size)!
    }
    class func mpHeavyFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "siro-heavy", size: size)!
    }
    class func mpItalicFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "siro-italic", size: size)!
    }
}

// MARK: - Colors

extension UIColor
{
    // Used for the onboarding error popdown background
    class func mpPinkMessageColor() -> UIColor {
        return UIColor(red: 254.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 1)
    }
    
    class func mpOffWhiteNavColor() -> UIColor {
        //return UIColor(red: 245.0/255.0, green: 246.0/255.0, blue: 247.0/255.0, alpha: 1)
        return UIColor(named: "MPOffWhiteColor")!
        // F5F6F7
    }
    
    class func mpHeaderBackgroundColor() -> UIColor {
        //return UIColor(red: 230.0/255.0, green: 234.0/255.0, blue: 234.0/255.0, alpha: 1)
        return UIColor(named: "MPHeaderBackgroundColor")!
    } // EDEEF2
    
    class func mpGrayButtonBorderColor() -> UIColor {
        //return UIColor(red: 230.0/255.0, green: 234.0/255.0, blue: 234.0/255.0, alpha: 1)
        return UIColor(named: "MPGrayButtonBorderColor")!
    } // D9DBDE

    class func mpRedColor() -> UIColor {
        //return UIColor(red: 225.0/255.0, green: 5.0/255.0, blue: 0.0/255.0, alpha: 1)
        return UIColor(named: "MPRedColor")!
    } // E10500
    
    class func mpPickerToolbarColor() -> UIColor {
        //return UIColor(red: 225.0/255.0, green: 5.0/255.0, blue: 0.0/255.0, alpha: 1)
        return UIColor(named: "MPRedColor")!
    } // E10500
    
    class func mpNegativeRedColor() -> UIColor {
        //return UIColor(red: 204.0/255.0, green: 14.0/255.0, blue: 0.0/255.0, alpha: 1)
        return UIColor(named: "MPNegativeRedColor")!
    } // CC0E00
    
    class func mpGreenColor() -> UIColor {
        //return UIColor(red: 5.0/255.0, green: 163.0/255.0, blue: 66.0/255.0, alpha: 1)
        return UIColor(named: "MPGreenColor")!
    } // 05A342
    
    class func mpBlueColor() -> UIColor {
        //return UIColor(red: 0.0/255.0, green: 74.0/255.0, blue: 206.0/255.0, alpha: 1)
        return UIColor(named: "MPBlueColor")!
    } // 004ACE CBS blue
    
    class func mpLightGrayColor() -> UIColor {
        //return UIColor(red: 166.0/255.0, green: 169.0/255.0, blue: 173.0/255.0, alpha: 1)
        return UIColor(named: "MPLightGrayColor")!
    } // A6A9AD Light Gray Text
    
    class func mpLighterGrayColor() -> UIColor {
        //return UIColor(red: 194.0/255.0, green: 196.0/255.0, blue: 198.0/255.0, alpha: 1)
        return UIColor(named: "MPLighterGrayColor")!
    } // C2C4C6 Lighter Gray Text
    
    class func mpGrayColor() -> UIColor {
        //return UIColor(red: 117.0/255.0, green: 118.0/255.0, blue: 120.0/255.0, alpha: 1)
        return UIColor(named: "MPGrayColor")!
    } // 757678 Tertiary Text
 
    class func mpDarkGrayColor() -> UIColor {
        //return UIColor(red: 101.0/255.0, green: 102.0/255.0, blue: 103.0/255.0, alpha: 1)
        return UIColor(named: "MPDarkGrayColor")!
    } // 656667 Secondary Text
    
    class func mpBlackColor() -> UIColor {
        //return UIColor(red: 32.0/255.0, green: 33.0/255.0, blue: 33.0/255.0, alpha: 1)
        return UIColor(named: "MPBlackColor")!
    } // 202121 Primary Text
    
    class func mpWhiteColor() -> UIColor {
        //return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
        return UIColor(named: "MPWhiteColor")!
    } // ffffff White
    
    class func mpWhiteAlpha80Color() -> UIColor {
        return UIColor(named: "MPWhiteAlpha80Color")!
    } // ffffff White with 80% alpha
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
            
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        {
            return UIColor(red: min(red + percentage/100, 1.0),
                               green: min(green + percentage/100, 1.0),
                               blue: min(blue + percentage/100, 1.0),
                               alpha: alpha)
        }
        else
        {
            return nil
        }
    }
    
    /*
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // Bad data, String should be 6 or 8 characters
        if (hexString.count) < 6
        {
            self.init(red:0.5, green:0.5, blue:0.5, alpha:1.0)
            return
        }

        // strip 0X or 0x if it appears
        if (hexString.hasPrefix("0X") || hexString.hasPrefix("0x"))
        {
            hexString = ((hexString as NSString?)?.substring(from: 2))!
        }

        if hexString.count != 6
        {
            self.init(red:0.5, green:0.5, blue:0.5, alpha:1.0)
            return
        }

        // If the team color is white, dim it
        if hexString.lowercased() == "ffffff"
        {
            self.init(red:0.8, green:0.8, blue:0.8, alpha:1.0)
            return
        }

        // If the team color is black, lighten it
        if hexString.lowercased() == "000000"
        {
            self.init(red:0.2, green:0.2, blue:0.2, alpha:1.0)
            return
        }
        
        let scanner = Scanner(string: hexString)
        //if (hexString.hasPrefix("#"))
        //{
            //scanner.scanLocation = 1
        //}
        var color: UInt64 = 0
        //scanner.scanHexInt32(&color)
        scanner.scanHexInt64(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
 */
}

// MARK: - Images

extension UIImage
{
    func getColorIfCornersMatch() -> UIColor?
    {
        let provider = self.cgImage!.dataProvider
        let providerData = provider!.data
        let data = CFDataGetBytePtr(providerData)
        
        // Look at the pixels inset at each corner by 2
        let numberOfComponents = 4
        var x = 2
        var y = 2
        
        let pixelData1 = ((Int(size.width) * y) + x) * numberOfComponents
        let r1 = data![pixelData1]
        let g1 = data![pixelData1 + 1]
        let b1 = data![pixelData1 + 2]
        let a1 = data![pixelData1 + 3]
        let r1Val = CGFloat(r1) / 255.0
        let g1Val = CGFloat(g1) / 255.0
        let b1Val = CGFloat(b1) / 255.0
        let a1Val = CGFloat(a1) / 255.0
        
        x = Int(self.size.width - 3)
        y = 2
        let pixelData2 = ((Int(size.width) * y) + x) * numberOfComponents
        let r2 = data![pixelData2]
        let g2 = data![pixelData2 + 1]
        let b2 = data![pixelData2 + 2]
        let a2 = data![pixelData2 + 3]
        let r2Val = CGFloat(r2) / 255.0
        let g2Val = CGFloat(g2) / 255.0
        let b2Val = CGFloat(b2) / 255.0
        
        x = 2
        y = Int(self.size.height - 3)
        let pixelData3 = ((Int(size.width) * y) + x) * numberOfComponents
        let r3 = data![pixelData3]
        let g3 = data![pixelData3 + 1]
        let b3 = data![pixelData3 + 2]
        let a3 = data![pixelData3 + 3]
        let r3Val = CGFloat(r3) / 255.0
        let g3Val = CGFloat(g3) / 255.0
        let b3Val = CGFloat(b3) / 255.0
        
        x = Int(self.size.width - 3)
        y = Int(self.size.height - 3)
        let pixelData4 = ((Int(size.width) * y) + x) * numberOfComponents
        let r4 = data![pixelData4]
        let g4 = data![pixelData4 + 1]
        let b4 = data![pixelData4 + 2]
        let a4 = data![pixelData4 + 3]
        let r4Val = CGFloat(r4) / 255.0
        let g4Val = CGFloat(g4) / 255.0
        let b4Val = CGFloat(b4) / 255.0
        
        // Calculate the corner luminance
        let luma1 = (r1Val * CGFloat(0.2126)) + (g1Val * CGFloat(0.7152)) + (b1Val * CGFloat(0.0722))
        let luma2 = (r2Val * CGFloat(0.2126)) + (g2Val * CGFloat(0.7152)) + (b2Val * CGFloat(0.0722))
        let luma3 = (r3Val * CGFloat(0.2126)) + (g3Val * CGFloat(0.7152)) + (b3Val * CGFloat(0.0722))
        let luma4 = (r4Val * CGFloat(0.2126)) + (g4Val * CGFloat(0.7152)) + (b4Val * CGFloat(0.0722))
        
        let meanLuma = (luma1 + luma2 + luma3 + luma4) / 4.0
        let lumaDiff = meanLuma - luma1
        let absoluteValOfLumaDiff = abs(lumaDiff)
        
        // Check if the meanLuma is similar to the upper left corner's luma and the corner alphas match
        //if ((r1 == r2) && (r2 == r3) && (r3 == r4) && (g1 == g2) && (g2 == g3) && (g3 == g4) && (b1 == b2) && (b2 == b3) && (b3 == b4) && (a1 == a2) && (a2 == a3) && (a3 == a4))
        if ((absoluteValOfLumaDiff < 0.01) && (a1 == a2) && (a2 == a3) && (a3 == a4))
        {
            return UIColor(red: r1Val, green: g1Val, blue: b1Val, alpha: a1Val)
        }
        else
        {
            return nil
        }
    }
    
    class func drawImageOnLargerCanvas(image useImage: UIImage, canvasSize: CGSize, canvasColor: UIColor ) -> UIImage
    {
        let rect = CGRect(origin: .zero, size: canvasSize)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)

        // fill the entire image
        canvasColor.setFill()
        UIRectFill(rect)

        // calculate a Rect the size of the image to draw, centered in the canvas rect
        let centeredImageRect = CGRect(x: (canvasSize.width - useImage.size.width) / 2,
                                       y: (canvasSize.height - useImage.size.height) / 2,
                                       width: useImage.size.width,
                                       height: useImage.size.height)

        // get a drawing context
        let context = UIGraphicsGetCurrentContext();

        // "cut" a transparent rectangle in the middle of the "canvas" image
        context?.clear(centeredImageRect)

        // draw the image into that rect
        useImage.draw(in: centeredImageRect)

        // get the new "image in the center of a canvas image"
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!

    }
    
    class func maskRoundedImage(image: UIImage, radius: CGFloat) -> UIImage
    {
        let imageView: UIImageView = UIImageView(image: image)
        let layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = radius
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage!
    }
    
    // Creates a UIImage given a UIColor
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1))
    {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
    
// MARK: - Dictionary
    
extension Dictionary
{
    func merge(dict: Dictionary<Key,Value>) -> Dictionary<Key,Value>
    {
        var mutableCopy = self
        for (key, value) in dict
        {
            // If both dictionaries have a value for same key, the value of the other dictionary is used.
            mutableCopy[key] = value
        }
        return mutableCopy
    }
}

// MARK: - String

extension String
{
    func widthOfString(usingFont font: UIFont) -> CGFloat
    {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }

    func heightOfString(usingFont font: UIFont) -> CGFloat
    {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }

    func sizeOfString(usingFont font: UIFont) -> CGSize
    {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
    
    func attributedStringWithSpacing(kernValue: CGFloat) -> NSAttributedString
    {
        let attributedString = NSMutableAttributedString(string: self)
        let range = NSRange(self)
        attributedString.addAttribute(NSAttributedString.Key.kern, value:kernValue, range: range!)
        return attributedString
    }
    
    func attributedText(withString string: String, boldString: String, font: UIFont, size: CGFloat) -> NSAttributedString
    {
        let attributedString = NSMutableAttributedString(string: string,
                                                     attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.mpBoldFontWith(size: size)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat
    {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat
    {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func size(font: UIFont, width: CGFloat) -> CGSize
    {
        let attrString = NSAttributedString(string: self, attributes: [NSAttributedString.Key.font: font])
        let bounds = attrString.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        let size = CGSize(width: bounds.width, height: bounds.height)
        return size
    }
    
    var containsEmoji: Bool
    {
        for scalar in unicodeScalars
        {
            switch scalar.value
            {
            //case 0x1F600...0x1F64F, // Emoticons
                //0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                //0x1F680...0x1F6FF, // Transport and Map
                //0x2600...0x26FF,   // Misc symbols
                //0x2700...0x27BF,   // Dingbats
                //0xFE00...0xFE0F:   // Variation Selectors
            case 0x0080...0x02AF, 0x0300...0x03FF, 0x0600...0x06FF, 0x0C00...0x0C7F, 0x1DC0...0x1DFF, 0x1E00...0x1EFF, 0x2000...0x209F, 0x20D0...0x214F, 0x2190...0x23FF, 0x2460...0x25FF, 0x2600...0x27EF, 0x2900...0x29FF, 0x2B00...0x2BFF, 0x2C60...0x2C7F, 0x2E00...0x2E7F, 0x3000...0x303F, 0xA490...0xA4CF, 0xE000...0xF8FF, 0xFE00...0xFE0F, 0xFE30...0xFE4F, 0x1F000...0x1F02F, 0x1F0A0...0x1F0FF, 0x1F100...0x1F64F, 0x1F680...0x1F6FF, 0x1F910...0x1F96B, 0x1F980...0x1F9E0:
                return true
            default:
                continue
            }
        }
        return false
        
        /*
         unicode-range: U+0080-02AF, U+0300-03FF, U+0600-06FF, U+0C00-0C7F, U+1DC0-1DFF, U+1E00-1EFF, U+2000-209F, U+20D0-214F, U+2190-23FF, U+2460-25FF, U+2600-27EF, U+2900-29FF, U+2B00-2BFF, U+2C60-2C7F, U+2E00-2E7F, U+3000-303F, U+A490-A4CF, U+E000-F8FF, U+FE00-FE0F, U+FE30-FE4F, U+1F000-1F02F, U+1F0A0-1F0FF, U+1F100-1F64F, U+1F680-1F6FF, U+1F910-1F96B, U+1F980-1F9E0;
         */
    }
    
    var isValidUrl: Bool
    {
        if let validUrl = URL(string: self)
        {
            return UIApplication.shared.canOpenURL(validUrl)
        }
        return false
    }
}

// MARK: - UILabel

extension UILabel
{
    @IBInspectable
    var letterSpace: CGFloat
    {
        set
        {
            let attributedString: NSMutableAttributedString!
            if let currentAttrString = attributedText
            {
                attributedString = NSMutableAttributedString(attributedString: currentAttrString)
            }
            else
            {
                attributedString = NSMutableAttributedString(string: text ?? "")
                text = nil
            }
            attributedString.addAttribute(NSAttributedString.Key.kern,
                                          value: newValue,
                                          range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }

        get
        {
            if let currentLetterSpace = attributedText?.attribute(NSAttributedString.Key.kern, at: 0, effectiveRange: .none) as? CGFloat
            {
                return currentLetterSpace
            }
            else
            {
                return 0
            }
        }
    }
}

// MARK: - UIView

extension UIView
{
    class func fromNib<T: UIView>() -> T
    {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

// MARK: - UIImageView

extension UIImageView
{
    func setImageColor(color: UIColor)
    {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

// MARK: - URL Helpers
/*
extension URL
{
    var components: URLComponents?
    {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)
    }
}

extension Array where Iterator.Element == URLQueryItem
{
    subscript(_ key: String) -> String?
    {
        return first(where: { $0.name == key })?.value
    }
}
*/
extension URL
{
    subscript(queryParam: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        if let parameters = url.queryItems {
            return parameters.first(where: { $0.name == queryParam })?.value
        } else if let paramPairs = url.fragment?.components(separatedBy: "?").last?.components(separatedBy: "&") {
            for pair in paramPairs where pair.contains(queryParam) {
                return pair.components(separatedBy: "=").last
            }
            return nil
        } else {
            return nil
        }
    }
}

