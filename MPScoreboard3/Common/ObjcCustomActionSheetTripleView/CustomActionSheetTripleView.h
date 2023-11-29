//
//  CustomActionSheetTripleView.h
//  CBS-iOS
//
//  Created by David Smith on 1/3/19.
//  Copyright © 2019. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomActionSheetTripleViewDelegate <NSObject>
@optional
- (void)closeCustomTripleActionSheetAfterCancelButtonTouched;
- (void)closeCustomTripleActionSheetAfterButtonZeroTouched;
- (void)closeCustomTripleActionSheetAfterButtonOneTouched;
- (void)closeCustomTripleActionSheetAfterButtonTwoTouched;
@end



@interface CustomActionSheetTripleView : UIView
{
    UIView *backgroundCircleView;
    UIButton *cancelButton;
    UIButton *buttonZero;
    UIButton *buttonOne;
    UIButton *buttonTwo;
    UILabel *labelZero;
    UILabel *labelOne;
    UILabel *labelTwo;
    
    int     bottomSafeAreaHeight;
    
    id <CustomActionSheetTripleViewDelegate>   delegate;
}

@property (nonatomic) id delegate;

- (id)initWithFrame:(CGRect)frame buttonZeroTitle:(NSString *)titleZero buttonOneTitle:(NSString *)titleOne buttonTwoTitle:(NSString *)titleTwo color:(UIColor *)color;

@end
