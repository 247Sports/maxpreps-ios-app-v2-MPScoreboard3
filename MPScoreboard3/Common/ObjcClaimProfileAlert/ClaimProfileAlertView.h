//
//  ClaimProfileAlertView.h
//  CBS-iOS
//
//  Created by David Smith on 11/4/21.
//  Copyright © 2021 MaxPreps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ClaimProfileAlertViewDelegate <NSObject>
@optional
- (void)closeClaimProfileAlertAfterCancelButtonTouched;
- (void)closeClaimProfileAlertAfterAthleteSelectButtonTouched;
- (void)closeClaimProfileAlertAfterParentSelectButtonTouched;
@end



@interface ClaimProfileAlertView : UIView
{
    UIView *blackBackgroundView;
    UIView *roundRectView;
        
    id <ClaimProfileAlertViewDelegate>   delegate;
}

@property (nonatomic) id delegate;

- (id)initWithFrame:(CGRect)frame color:(UIColor *)color name:(NSString *)name parentOnly:(Boolean)parentOnly;

- (id)initWithFrame:(CGRect)frame color:(UIColor *)color name:(NSString *)name isParent:(Boolean)isParent;

@end
