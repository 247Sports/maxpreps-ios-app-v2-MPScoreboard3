//
//  ClaimProfileSuccessAlertView.h
//  CBS-iOS
//
//  Created by David Smith on 6/16/23.
//  Copyright © 2023 MaxPreps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ClaimProfileSuccessAlertViewDelegate <NSObject>
@optional
//- (void)closeClaimProfileSuccessAlertAfterCancelButtonTouched;
- (void)closeClaimProfileSuccessAlertAfterDoneButtonTouched;
@end



@interface ClaimProfileSuccessAlertView : UIView
{
    UIView *blackBackgroundView;
    UIView *roundRectView;
        
    id <ClaimProfileSuccessAlertViewDelegate>   delegate;
}

@property (nonatomic) id delegate;

- (id)initWithFrame:(CGRect)frame message:(NSString *)message;

@end
