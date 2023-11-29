//
//  CustomDatePicker.m
//  CBS-iOS
//
//  Created by David Smith on 10/22/18.
//  Copyright © 2018 MaxPreps. All rights reserved.
//

#import "CustomDatePickerView.h"

@implementation CustomDatePickerView
@synthesize delegate;

#define kNavBarHeight 44

#pragma mark - Switch Method

- (void)tbaSwitchChanged
{
    if (tbaSwitch.isOn)
        dimmingView.hidden = NO;
    else
        dimmingView.hidden = YES;
}

#pragma mark - Init Methods

- (id)initWithFrame:(CGRect)frame dateMode:(BOOL)dateMode barColor:(UIColor *)barColor
{
    self = [super initWithFrame:frame];
    
    if (self)
    {        
        self.backgroundColor = [UIColor clearColor];
        
        // Added for swift implementation
        UIWindow *window = [UIApplication sharedApplication].windows[0];
        bottomSafeAreaHeight = window.safeAreaInsets.bottom;
        
        blackBackgroundView = [[UIView alloc]initWithFrame:frame];
        blackBackgroundView.backgroundColor = [UIColor blackColor];
        blackBackgroundView.alpha = 0.0;
        [self addSubview:blackBackgroundView];
        
        datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake((frame.size.width - 320) / 2, kNavBarHeight, frame.size.width, 216)];
        datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        
        if (dateMode)
        {
            datePicker.datePickerMode = UIDatePickerModeDate;
        }
        else
        {
            datePicker.datePickerMode = UIDatePickerModeTime;
            datePicker.minuteInterval = 5;
        }
        
        containerView = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height - datePicker.frame.size.height - kNavBarHeight - bottomSafeAreaHeight, frame.size.width, datePicker.frame.size.height + kNavBarHeight + bottomSafeAreaHeight)];
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.transform = CGAffineTransformMakeTranslation(0, datePicker.frame.size.height + kNavBarHeight + bottomSafeAreaHeight);
        [self addSubview:containerView];
        
        UIView *tabBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, containerView.frame.size.width, kNavBarHeight)];
        tabBar.backgroundColor = barColor;
        [containerView addSubview:tabBar];
        
        [containerView addSubview:datePicker];
        
        dimmingView = [[UIView alloc]initWithFrame:CGRectMake(0, kNavBarHeight, containerView.frame.size.width, containerView.frame.size.height - kNavBarHeight)];
        dimmingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        [containerView addSubview:dimmingView];
        
        dimmingView.hidden = YES;
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(16, 0, 70, kNavBarHeight);
        cancelButton.backgroundColor = [UIColor clearColor];
        //cancelButton.titleLabel.font = [UIFont systemFontOfSize:21];
        cancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:19];
        cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [tabBar addSubview:cancelButton];
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.frame = CGRectMake(tabBar.frame.size.width - 76, 0, 60, kNavBarHeight);
        doneButton.backgroundColor = [UIColor clearColor];
        //doneButton.titleLabel.font = [UIFont systemFontOfSize:21];
        doneButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:19];
        doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [doneButton setTitle:@"Select" forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(doneButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [tabBar addSubview:doneButton];
        
        // Calculate the onTintColor for the switch
        const CGFloat *components = CGColorGetComponents(barColor.CGColor);
        UIColor *tintColor = [UIColor colorWithRed:components[0] / 2.0 green:components[1] / 2.0 blue:components[2] / 2.0 alpha:1];
        
        tbaSwitch = [[UISwitch alloc]initWithFrame:CGRectZero];
        tbaSwitch.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        tbaSwitch.onTintColor = tintColor;
        tbaSwitch.layer.cornerRadius = 16;
        [tbaSwitch addTarget:self action:@selector(tbaSwitchChanged) forControlEvents:UIControlEventValueChanged];
        tbaSwitch.transform = CGAffineTransformMakeScale(0.8, 0.8);
        tbaSwitch.center = CGPointMake((tabBar.frame.size.width / 2) + 30, tabBar.frame.size.height / 2);
        [tabBar addSubview:tbaSwitch];
        
        UILabel *tbaLabel = [[UILabel alloc]initWithFrame:CGRectMake((tabBar.frame.size.width / 2) - 58, 10, 60, 24)];
        tbaLabel.textAlignment = NSTextAlignmentRight;
        tbaLabel.textColor = [UIColor whiteColor];
        tbaLabel.font = [UIFont systemFontOfSize:13];
        [tabBar addSubview:tbaLabel];
        
        if (dateMode)
            tbaLabel.text = @"TBA Date";
        else
            tbaLabel.text = @"TBA Time";
        
        // Animate
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self->blackBackgroundView.alpha = 0.5;
            self->containerView.transform = CGAffineTransformMakeTranslation(0, 0);
        }
                         completion:^(BOOL finished)
         {
             
         }];
        
    }
    return self;
}

#pragma mark - Button Methods

- (void)cancelButtonTouched
{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self->blackBackgroundView.alpha = 0.0;
        self->containerView.transform = CGAffineTransformMakeTranslation(0, self->datePicker.frame.size.height + kNavBarHeight + self->bottomSafeAreaHeight);
    }
                     completion:^(BOOL finished)
     {
         [self.delegate closeCustomDatePickerAfterCancelButtonTouched];
     }];
    
}

- (void)doneButtonTouched
{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self->blackBackgroundView.alpha = 0.0;
        self->containerView.transform = CGAffineTransformMakeTranslation(0, self->datePicker.frame.size.height + kNavBarHeight + self->bottomSafeAreaHeight);
    }
                     completion:^(BOOL finished)
     {
         self->_tbaIsOn = self->tbaSwitch.isOn;
         self->_selectedDate = self->datePicker.date;
         
         [self.delegate closeCustomDatePickerAfterDoneButtonTouched];
     }];
    
}

@end
