//
//  CalendarSubscribeAlertView.m
//  CBS-iOS
//
//  Created by David Smith on 9/30/19.
//  Copyright © 2019 MaxPreps. All rights reserved.
//

#import "CalendarSubscribeAlertView.h"

@implementation CalendarSubscribeAlertView
@synthesize delegate;

#pragma mark - Init Methods

- (id)initWithFrame:(CGRect)frame color:(UIColor *)color
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        blackBackgroundView = [[UIView alloc]initWithFrame:frame];
        blackBackgroundView.backgroundColor = [UIColor blackColor];
        blackBackgroundView.alpha = 0.0;
        [self addSubview:blackBackgroundView];
        
        roundRectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 380)];
        roundRectView.center = self.center;
        roundRectView.backgroundColor = [UIColor whiteColor];
        roundRectView.layer.cornerRadius = 12;
        roundRectView.clipsToBounds = YES;
        roundRectView.transform = CGAffineTransformMakeTranslation(0, (frame.size.height / 2) + 190);
        [self addSubview:roundRectView];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(10, 10, 40, 40);
        [closeButton setImage:[UIImage imageNamed:@"CloseCircular"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(cancelButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [roundRectView addSubview:closeButton];
        
        UIImageView *calendarImage = [[UIImageView alloc]initWithFrame:CGRectMake((roundRectView.frame.size.width - 220) / 2, 50, 220, 82)];
        [calendarImage setImage:[UIImage imageNamed:@"CalendarSyncImage"]];
        [roundRectView addSubview:calendarImage];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 140, 280, 22)];
        titleLabel.text = @"Calendar Sync";
        titleLabel.font = [UIFont fontWithName:@"siro-bold" size:18.0];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [roundRectView addSubview:titleLabel];
        
        UILabel *subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 170, 280, 36)];
        subTitleLabel.numberOfLines = 2;
        subTitleLabel.text = @"Synchronize your device calendar\nto your team's schedule.";
        subTitleLabel.font = [UIFont fontWithName:@"siro-semibold" size:14.0];
        subTitleLabel.textColor = [UIColor blackColor];
        subTitleLabel.textAlignment = NSTextAlignmentCenter;
        [roundRectView addSubview:subTitleLabel];
        
        UIColor *mpRedColor = [UIColor colorWithRed:225.0/255.0 green:5.0/255.0 blue:0.0 alpha:1];
        
        UIButton *appleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        appleButton.frame = CGRectMake(40, 220, 220, 40);
        appleButton.backgroundColor = [UIColor clearColor];
        appleButton.titleLabel.font = [UIFont fontWithName:@"siro-semibold" size:14.0];
        [appleButton setTitle:@"APPLE CALENDAR" forState:UIControlStateNormal];
        [appleButton setTitleColor:mpRedColor forState:UIControlStateNormal];
        appleButton.layer.cornerRadius = 8;
        appleButton.layer.borderColor = mpRedColor.CGColor;
        appleButton.layer.borderWidth = 1.0;
        appleButton.clipsToBounds = YES;
        [appleButton addTarget:self action:@selector(appleButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [roundRectView addSubview:appleButton];
        
        UIButton *thirdPartyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        thirdPartyButton.frame = CGRectMake(40, 270, 220, 40);
        thirdPartyButton.backgroundColor = [UIColor clearColor];
        thirdPartyButton.titleLabel.font = [UIFont fontWithName:@"siro-semibold" size:14.0];
        [thirdPartyButton setTitle:@"THIRD PARTY CALENDAR" forState:UIControlStateNormal];
        [thirdPartyButton setTitleColor:mpRedColor forState:UIControlStateNormal];
        thirdPartyButton.layer.cornerRadius = 8;
        thirdPartyButton.layer.borderColor = mpRedColor.CGColor;
        thirdPartyButton.layer.borderWidth = 1.0;
        thirdPartyButton.clipsToBounds = YES;
        [thirdPartyButton addTarget:self action:@selector(thirdPartyButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [roundRectView addSubview:thirdPartyButton];
        
        UIButton *unsubscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        unsubscribeButton.frame = CGRectMake(40, 320, 220, 40);
        unsubscribeButton.backgroundColor = [UIColor clearColor];
        unsubscribeButton.titleLabel.font = [UIFont fontWithName:@"siro-semibold" size:14.0];;
        [unsubscribeButton setTitle:@"UNSUBSCRIBE" forState:UIControlStateNormal];
        [unsubscribeButton setTitleColor:mpRedColor forState:UIControlStateNormal];
        unsubscribeButton.layer.cornerRadius = 8;
        unsubscribeButton.layer.borderColor = mpRedColor.CGColor;
        unsubscribeButton.layer.borderWidth = 1.0;
        unsubscribeButton.clipsToBounds = YES;
        [unsubscribeButton addTarget:self action:@selector(unsubscribeButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [roundRectView addSubview:unsubscribeButton];
        
        // Animate
        [UIView animateWithDuration:0.33 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self->blackBackgroundView.alpha = 0.7;
            self->roundRectView.transform = CGAffineTransformMakeTranslation(0, -20);
            
        }
                         completion:^(BOOL finished)
         {
             [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                 
                 self->roundRectView.transform = CGAffineTransformMakeTranslation(0, 10);
                 
             }
                              completion:^(BOOL finished)
              {
                  
                  [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                      
                      self->roundRectView.transform = CGAffineTransformMakeTranslation(0, 0);
                      
                  }
                                   completion:^(BOOL finished)
                   {
                       
                       
                   }];
              }];
             
         }];
        
    }
    return self;
}

#pragma mark - Button Methods

- (void)cancelButtonTouched
{
    [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self->blackBackgroundView.alpha = 0.0;
        self->roundRectView.transform = CGAffineTransformMakeTranslation(0, (self.frame.size.height / 2) + 190);
    }
                     completion:^(BOOL finished)
     {
         [self.delegate closeCalendarSubscribeAlertAfterCancelButtonTouched];
     }];
    
}

- (void)appleButtonTouched
{
    [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self->blackBackgroundView.alpha = 0.0;
        self->roundRectView.transform = CGAffineTransformMakeTranslation(0, (self.frame.size.height / 2) + 190);
    }
                     completion:^(BOOL finished)
     {
         [self.delegate closeCalendarSubscribeAlertAfterAppleButtonTouched];
     }];
}

- (void)thirdPartyButtonTouched
{
    [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self->blackBackgroundView.alpha = 0.0;
        self->roundRectView.transform = CGAffineTransformMakeTranslation(0, (self.frame.size.height / 2) + 190);
    }
                     completion:^(BOOL finished)
     {
         [self.delegate closeCalendarSubscribeAlertAfterThirdPartyButtonTouched];
     }];
}

- (void)unsubscribeButtonTouched
{
    [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self->blackBackgroundView.alpha = 0.0;
        self->roundRectView.transform = CGAffineTransformMakeTranslation(0, (self.frame.size.height / 2) + 190);
    }
                     completion:^(BOOL finished)
     {
         [self.delegate closeCalendarSubscribeAlertAfterUnsubscribeButtonTouched];
     }];
}

@end
