//
//  OverlayView.h
//  MPScoreboard3
//
//  Created by David Smith on 9/14/21.
//

#import <UIKit/UIKit.h>

@interface OverlayView : UIView

typedef void (^DismissBlock)(void);

+ (void)showCheckmarkOverlayWithMessage:(NSString *)message withDismissHandler:(DismissBlock)completion;
+ (void)showPopupOverlayWithMessage:(NSString *)message withDismissHandler:(DismissBlock)completion;
+ (void)showTwoLinePopupOverlayWithMessage:(NSString *)message boldText:(NSString *)boldText withDismissHandler:(void(^)(void))completion;
+ (void)showPopdownOverlayWithMessage:(NSString *)message title:(NSString *)title overlayColor:(UIColor *)overlayColor withDismissHandler:(void(^)(void))completion;

@end
