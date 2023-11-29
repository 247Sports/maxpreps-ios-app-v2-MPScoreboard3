//
//  OnboardingAlertView.h
//  CBS-iOS
//
//  Created by David Smith on 3/25/21.
//  Copyright © 2022 MaxPreps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OnboardingAlertViewDelegate <NSObject>
@optional
- (void)closeOnboardingAlertAfterCancelButtonTouched;
- (void)closeOnboardingAlertAfterTopButtonTouched;
- (void)closeOnboardingAlertAfterBottomButtonTouched;
@end



@interface OnboardingAlertView : UIView
{
    UIView *blackBackgroundView;
    UIView *roundRectView;
    int roundRectHeight;
        
    id <OnboardingAlertViewDelegate>   delegate;
}

@property (nonatomic) id delegate;

- (id)initWithFrame:(CGRect)frame color:(UIColor *)color title:(NSString *)title message:(NSString *)message topButtonTitle:(NSString *)topButtonTitle bottomButtonTitle:(NSString *)bottomButtonTitle;

@end
