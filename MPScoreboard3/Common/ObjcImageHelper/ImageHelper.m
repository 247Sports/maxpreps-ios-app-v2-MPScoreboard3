// ImageHelper.m

#import "ImageHelper.h"

@implementation ImageHelper

#pragma mark -  Image Cropper

+ (UIImage *)cropImage:(UIImage *)image inRect:(CGRect)rect
{
    double (^rad)(double) = ^(double deg) {
        return deg / 180.0 * M_PI;
    };

    CGAffineTransform rectTransform;
    switch (image.imageOrientation)
    {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -image.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -image.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -image.size.width, -image.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    rectTransform = CGAffineTransformScale(rectTransform, image.scale, image.scale);

    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectApplyAffineTransform(rect, rectTransform));
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);

    return result;
}

#pragma mark - Image Scaler

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
