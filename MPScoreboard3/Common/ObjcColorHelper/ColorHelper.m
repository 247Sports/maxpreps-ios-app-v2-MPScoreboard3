// ColorHelper.m

#import "ColorHelper.h"

@implementation ColorHelper

#pragma mark -  Smart Hex to Color Method

+ (UIColor *)colorFromHexString:(NSString *)hexString colorCorrection:(BOOL)colorCorrection
{
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    if (colorCorrection)
    {
        // If the team color is white, dim it
        if ([[cString lowercaseString] isEqualToString:@"ffffff"])
            return [UIColor colorWithWhite:0.9 alpha:1.0];
    
        // If the team color is black, lighten it
        if ([[cString lowercaseString] isEqualToString:@"000000"])
            return [UIColor colorWithWhite:0.2 alpha:1.0];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    if (colorCorrection)
    {
        float rLum = r * 0.2126 / 255.0;
        float gLum = g * 0.7152 / 255.0;
        float bLum = b * 0.0722 / 255.0;
        
        // Calculate the total luminace to see if the color is too bright
        float totalLum = rLum + gLum + bLum;
        
        if (totalLum > 0.8)
        {
            // Reduce each color so the total luminace is 80%
            float scaleFactor = 1.0 - (totalLum - 0.8);
            
            float rNew = r * scaleFactor;
            float gNew = g * scaleFactor;
            float bNew = b * scaleFactor;
            
            return [UIColor colorWithRed:((float) rNew / 255.0f)
                                   green:((float) gNew / 255.0f)
                                    blue:((float) bNew / 255.0f)
                                   alpha:1.0f];
        }
        else
        {
            // Leave the color alone
            return [UIColor colorWithRed:((float) r / 255.0f)
                                   green:((float) g / 255.0f)
                                    blue:((float) b / 255.0f)
                                   alpha:1.0f];
        }
    }
    else
    {
        // Leave the color alone
        return [UIColor colorWithRed:((float) r / 255.0f)
                               green:((float) g / 255.0f)
                                blue:((float) b / 255.0f)
                               alpha:1.0f];
    }
    
}

@end
