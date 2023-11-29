// ColorHelper.h

// Extends the UIImage class to support cropping
#import <UIKit/UIKit.h>

@interface ColorHelper : NSObject

+ (UIColor *)colorFromHexString:(NSString *)hexString colorCorrection:(BOOL)colorCorrection;

@end
