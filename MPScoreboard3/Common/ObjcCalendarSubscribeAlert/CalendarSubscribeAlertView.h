//
//  CalendarSubscribeAlertView.h
//  CBS-iOS
//
//  Created by David Smith on 8/30/19.
//  Copyright © 2019 MaxPreps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CalendarSubscribeAlertViewDelegate <NSObject>
@optional
- (void)closeCalendarSubscribeAlertAfterCancelButtonTouched;
- (void)closeCalendarSubscribeAlertAfterAppleButtonTouched;
- (void)closeCalendarSubscribeAlertAfterThirdPartyButtonTouched;
- (void)closeCalendarSubscribeAlertAfterUnsubscribeButtonTouched;
@end



@interface CalendarSubscribeAlertView : UIView
{
    UIView *blackBackgroundView;
    UIView *roundRectView;
        
    id <CalendarSubscribeAlertViewDelegate>   delegate;
}

@property (nonatomic) id delegate;

- (id)initWithFrame:(CGRect)frame color:(UIColor *)color;

@end
