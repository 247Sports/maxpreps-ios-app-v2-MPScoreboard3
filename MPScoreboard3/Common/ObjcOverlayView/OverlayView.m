//
//  OverlayView.m
//  MPScoreboard3
//
//  Created by David Smith on 9/14/21.
//

#import "OverlayView.h"

@implementation OverlayView

+ (void)showCheckmarkOverlayWithMessage:(NSString *)message withDismissHandler:(void(^)(void))completion
{
    /*
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil];
    OverlayView *overlay = (OverlayView *)[subviewArray objectAtIndex:0];
    overlay.frame = [UIScreen mainScreen].bounds;
    //overlay.overlayLabel.text = message;
    //overlay.overlayLabel.font = [UIFont systemFontOfSize:17];
    
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [window.rootViewController.view addSubview:overlay];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [overlay removeFromSuperview];
        completion();
    });
    */
    UIView *containerView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    containerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    UIView *overlay = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 156, 156)];
    overlay.center = containerView.center;
    overlay.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    overlay.layer.cornerRadius = 10;
    overlay.clipsToBounds = YES;
    [containerView addSubview:overlay];
    
    UIImageView *checkmark = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 68, 46)];
    checkmark.center = CGPointMake(overlay.frame.size.width / 2, (overlay.frame.size.height / 2) - 15);
    [checkmark setImage:[UIImage imageNamed:@"OverlayCheckmark"]];
    [overlay addSubview:checkmark];
    
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, overlay.frame.size.height - 46, overlay.frame.size.width - 16, 24)];
    textLabel.text = message;
    textLabel.textColor = [UIColor blackColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = [UIFont systemFontOfSize:18];
    [overlay addSubview:textLabel];
    
    // Add the container to the window
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:containerView];
    
    // Dismiss after 1.5 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [containerView removeFromSuperview];
        completion();
    });
}

+ (void)showPopupOverlayWithMessage:(NSString *)message withDismissHandler:(void(^)(void))completion
{
    UIView *containerView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    containerView.backgroundColor = UIColor.clearColor;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    int bottomSafeAreaHeight = window.safeAreaInsets.bottom;
    int overlayHeight = 70 + bottomSafeAreaHeight;
    int labelPadY = 0;
    
    // Shift the label and icon down a bit for phones with notches
    if (bottomSafeAreaHeight > 0)
    {
        labelPadY = 15;
    }

    //UIColor *overlayColor = [UIColor colorWithRed:0.0 green:74.0/255.0 blue:206.0/255.0 alpha:1];
    UIColor *overlayColor = [UIColor colorWithRed:225.0/255.0 green:5.0/255.0 blue:0.0 alpha:1];
    
    UIView *overlay = [[UIView alloc]initWithFrame:CGRectMake(0, containerView.frame.size.height - overlayHeight, containerView.frame.size.width, overlayHeight)];
    overlay.backgroundColor = overlayColor;
    overlay.transform = CGAffineTransformMakeTranslation(0, overlayHeight);
    //overlay.layer.cornerRadius = 16;
    //overlay.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    //overlay.clipsToBounds = YES;
    [containerView addSubview:overlay];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20 + labelPadY, overlay.frame.size.width - 40, 20)];
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = message;
    [overlay addSubview:label];
    
    UIImageView *checkmark = [[UIImageView alloc]initWithFrame:CGRectMake(0, 16 + labelPadY, 28, 28)];
    [checkmark setImage:[UIImage imageNamed: @"OverlayCheckmarkRound"]];
    [overlay addSubview:checkmark];
    
    // Shift the image to the left of the text
    int textWidth = [self getTextWidth:message size:label.frame.size font:label.font];
    checkmark.center = CGPointMake(((overlay.frame.size.width - textWidth) / 2) - 24 , checkmark.center.y);
    
    // Add the container to the window
    [window addSubview:containerView];
    
    // Animate the overlay
    [UIView animateWithDuration:0.25 animations:^{
        
        // Show the overlay
        overlay.transform = CGAffineTransformIdentity;
    }
                     completion:^(BOOL finished){
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.16 animations:^{
                
                // Hide the overlay
                overlay.transform = CGAffineTransformMakeTranslation(0, overlayHeight);
            }
                             completion:^(BOOL finished){
                
                [containerView removeFromSuperview];
                completion();
                
            }];
        });
        
    }];

}

+ (void)showTwoLinePopupOverlayWithMessage:(NSString *)message boldText:(NSString *)boldText withDismissHandler:(void(^)(void))completion
{
    UIView *containerView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    containerView.backgroundColor = UIColor.clearColor;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    int bottomSafeAreaHeight = window.safeAreaInsets.bottom;
    int overlayHeight = 70 + bottomSafeAreaHeight;
    int labelPadY = 0;
    
    // Shift the label and icon down a bit for phones with notches
    if (bottomSafeAreaHeight > 0)
    {
        labelPadY = 15;
    }

    //UIColor *overlayColor = [UIColor colorWithRed:0.0 green:74.0/255.0 blue:206.0/255.0 alpha:1];
    UIColor *overlayColor = [UIColor colorWithRed:225.0/255.0 green:5.0/255.0 blue:0.0 alpha:1];
    
    UIView *overlay = [[UIView alloc]initWithFrame:CGRectMake(0, containerView.frame.size.height - overlayHeight, containerView.frame.size.width, overlayHeight)];
    overlay.backgroundColor = overlayColor;
    overlay.transform = CGAffineTransformMakeTranslation(0, overlayHeight);
    //overlay.layer.cornerRadius = 16;
    //overlay.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    //overlay.clipsToBounds = YES;
    [containerView addSubview:overlay];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60, 10 + labelPadY, overlay.frame.size.width - 80, 40)];
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    label.textAlignment = NSTextAlignmentLeft; //NSTextAlignmentCenter;
    label.numberOfLines = 2;
    label.minimumScaleFactor = 0.7;
    label.adjustsFontSizeToFitWidth = YES;
    [overlay addSubview:label];
    
    // Make some of the characters bold
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:message];
    NSRange selectedRange = [message rangeOfString:boldText];
    [string beginEditing];
    [string addAttribute:NSFontAttributeName
               value:[UIFont systemFontOfSize:15 weight:UIFontWeightBold]
               range:selectedRange];
    [string endEditing];
    label.attributedText = string;
    
    UIImageView *checkmark = [[UIImageView alloc]initWithFrame:CGRectMake(20, 16 + labelPadY, 28, 28)];
    [checkmark setImage:[UIImage imageNamed: @"OverlayCheckmarkRound"]];
    [overlay addSubview:checkmark];
    
    // Shift the image to the left of the text
    //int textWidth = [self getTextWidth:message size:label.frame.size font:label.font];
    //checkmark.center = CGPointMake(((overlay.frame.size.width - textWidth) / 2) - 24 , checkmark.center.y);
    
    // Add the container to the window
    [window addSubview:containerView];
    
    // Animate the overlay
    [UIView animateWithDuration:0.25 animations:^{
        
        // Show the overlay
        overlay.transform = CGAffineTransformIdentity;
    }
                     completion:^(BOOL finished){
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.16 animations:^{
                
                // Hide the overlay
                overlay.transform = CGAffineTransformMakeTranslation(0, overlayHeight);
            }
                             completion:^(BOOL finished){
                
                [containerView removeFromSuperview];
                completion();
                
            }];
        });
        
    }];

}

+ (void)showPopdownOverlayWithMessage:(NSString *)message title:(NSString *)title overlayColor:(UIColor *)overlayColor withDismissHandler:(void(^)(void))completion
{
    UIView *containerView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    containerView.backgroundColor = UIColor.clearColor;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    int topSafeAreaHeight = window.safeAreaInsets.top;
    
    //UIColor *overlayColor = [UIColor colorWithRed:254.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1];
    
    UIView *overlay = [[UIView alloc]initWithFrame:CGRectMake(28, 8 + topSafeAreaHeight, containerView.frame.size.width - 56 , 100)];
    overlay.backgroundColor = overlayColor;
    overlay.transform = CGAffineTransformMakeTranslation(0, -108 - topSafeAreaHeight);
    overlay.layer.cornerRadius = 16;
    overlay.clipsToBounds = YES;
    [containerView addSubview:overlay];
    
    UIImageView *alertIcon = [[UIImageView alloc]initWithFrame:CGRectMake(16, 16 , 20, 20)];
    [alertIcon setImage:[UIImage imageNamed: @"AlertIcon"]];
    [overlay addSubview:alertIcon];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 14, 240, 24)];
    titleLabel.textColor = [UIColor colorWithRed:204.0/255.0 green:14.0/255.0 blue:0.0 alpha:1];
    titleLabel.font = [UIFont fontWithName:@"siro-semibold" size:19];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text = title;
    [overlay addSubview:titleLabel];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 44, overlay.frame.size.width - 32, 40)];
    messageLabel.textColor = UIColor.blackColor;
    messageLabel.font = [UIFont fontWithName:@"siro-regular" size:15];
    messageLabel.numberOfLines = 0;
    messageLabel.adjustsFontSizeToFitWidth = YES;
    messageLabel.minimumScaleFactor = 0.5;
    messageLabel.textAlignment = NSTextAlignmentLeft;
    messageLabel.text = message;
    [overlay addSubview:messageLabel];
    
    // Add the container to the window
    [window addSubview:containerView];
    
    // Animate the overlay
    [UIView animateWithDuration:0.25 animations:^{
        
        // Show the overlay
        overlay.transform = CGAffineTransformIdentity;
    }
                     completion:^(BOOL finished){
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.16 animations:^{
                
                // Hide the overlay
                overlay.transform = CGAffineTransformMakeTranslation(0, -108 - topSafeAreaHeight);
            }
                             completion:^(BOOL finished){
                
                [containerView removeFromSuperview];
                completion();
                
            }];
        });
        
    }];

}

+ (CGFloat)getTextWidth:(NSString *)text size:(CGSize)size font:(UIFont *)font
{
    CGSize constraint = CGSizeMake(CGFLOAT_MAX,size.height);
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [text boundingRectWithSize:constraint
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:font}
                                            context:context].size;
    
    return ceil(boundingBox.width);
}

@end
