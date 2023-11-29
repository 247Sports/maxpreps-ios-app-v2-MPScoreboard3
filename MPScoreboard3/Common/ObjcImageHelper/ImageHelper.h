// ImageHelper.h

// Extends the UIImage class to support cropping
#import <UIKit/UIKit.h>

@interface ImageHelper : NSObject

+ (UIImage *)cropImage:(UIImage *)image inRect:(CGRect)rect;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
