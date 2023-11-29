//
//  CustomDatePickerView.h
//  CBS-iOS
//
//  Created by David Smith on 10/22/18.
//  Copyright © 2018 MaxPreps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomDatePickerViewDelegate <NSObject>
@optional
- (void)closeCustomDatePickerAfterDoneButtonTouched;
- (void)closeCustomDatePickerAfterCancelButtonTouched;
@end



@interface CustomDatePickerView : UIView
{
    UIView          *blackBackgroundView;
    UIView          *containerView;
    UIDatePicker    *datePicker;
    UIView          *dimmingView;
    UISwitch        *tbaSwitch;
    
    int             bottomSafeAreaHeight;
            
    id <CustomDatePickerViewDelegate>   delegate;
}

@property (nonatomic) id delegate;
@property (nonatomic, readonly) BOOL tbaIsOn;
@property (nonatomic, weak) NSDate *selectedDate;

- (id)initWithFrame:(CGRect)frame dateMode:(BOOL)dateMode barColor:(UIColor *)barColor;


@end
