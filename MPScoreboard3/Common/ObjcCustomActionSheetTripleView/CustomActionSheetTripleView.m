//
//  CustomActionSheetTripleView.m
//  CBS-iOS
//
//  Created by David Smith on 1/3/19.
//  Copyright © 2019. All rights reserved.
//

#import "CustomActionSheetTripleView.h"

#define kTabBarHeight 49.0

@implementation CustomActionSheetTripleView
@synthesize delegate;

#pragma mark - Init Methods

- (id)initWithFrame:(CGRect)frame buttonZeroTitle:(NSString *)titleZero buttonOneTitle:(NSString *)titleOne buttonTwoTitle:(NSString *)titleTwo color:(UIColor *)color
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        // Added for swift implementation
        UIWindow *window = [UIApplication sharedApplication].windows[0];
        bottomSafeAreaHeight = window.safeAreaInsets.bottom;
        
        // Added from the older app
        int yOffset = 54;
        
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
        [singleTapGesture setNumberOfTapsRequired:1];
        [self addGestureRecognizer:singleTapGesture];
        
        
        backgroundCircleView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width - 76, frame.size.height - 121 - bottomSafeAreaHeight + kTabBarHeight - yOffset, 56, 56)];
        backgroundCircleView.layer.cornerRadius = 28;
        backgroundCircleView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        backgroundCircleView.alpha = 0.1;
        [self addSubview:backgroundCircleView];
        
        UIImage *templateImage = [[UIImage imageNamed:@"WhitePlus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        
        if ([titleOne length] > 0)
        {
            buttonOne = [UIButton buttonWithType:UIButtonTypeCustom];
            buttonOne.frame = CGRectMake(frame.size.width - 66, frame.size.height - 113 - bottomSafeAreaHeight+ kTabBarHeight - yOffset, 40, 40);
            buttonOne.backgroundColor = [UIColor whiteColor];
            buttonOne.layer.cornerRadius = 20;
            [buttonOne setImage:templateImage forState:UIControlStateNormal];
            buttonOne.tintColor = color;
            [buttonOne addTarget:self action:@selector(buttonOneTouched) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:buttonOne];
        }
        
        if ([titleZero length] > 0)
        {
            buttonZero = [UIButton buttonWithType:UIButtonTypeCustom];
            buttonZero.frame = CGRectMake(frame.size.width - 66, frame.size.height - 113 - bottomSafeAreaHeight+ kTabBarHeight - yOffset, 40, 40);
            buttonZero.backgroundColor = [UIColor whiteColor];
            buttonZero.layer.cornerRadius = 20;
            [buttonZero setImage:templateImage forState:UIControlStateNormal];
            buttonZero.tintColor = color;
            [buttonZero addTarget:self action:@selector(buttonZeroTouched) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:buttonZero];
        }
        
        buttonTwo = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonTwo.frame = CGRectMake(frame.size.width - 66, frame.size.height - 113 - bottomSafeAreaHeight+ kTabBarHeight - yOffset, 40, 40);
        buttonTwo.backgroundColor = [UIColor whiteColor];
        buttonTwo.layer.cornerRadius = 20;
        [buttonTwo setImage:templateImage forState:UIControlStateNormal];
        buttonTwo.tintColor = color;
        [buttonTwo addTarget:self action:@selector(buttonTwoTouched) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonTwo];
        
        if ([titleOne length] > 0)
        {
            labelOne = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width - 242, frame.size.height - 104 - bottomSafeAreaHeight+ kTabBarHeight - yOffset, 160, 20)];
            labelOne.textColor = [UIColor whiteColor];
            labelOne.font = [UIFont systemFontOfSize:16];
            labelOne.textAlignment = NSTextAlignmentRight;
            labelOne.text = titleOne;
            labelOne.alpha = 0.0;
            [self addSubview:labelOne];
        }
        
        if ([titleZero length] > 0)
        {
            labelZero = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width - 242, frame.size.height - 104 - bottomSafeAreaHeight+ kTabBarHeight - yOffset, 160, 20)];
            labelZero.textColor = [UIColor whiteColor];
            labelZero.font = [UIFont systemFontOfSize:16];
            labelZero.textAlignment = NSTextAlignmentRight;
            labelZero.text = titleZero;
            labelZero.alpha = 0.0;
            [self addSubview:labelZero];
        }
        
        labelTwo = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width - 242, frame.size.height - 104 - bottomSafeAreaHeight+ kTabBarHeight - yOffset, 160, 20)];
        labelTwo.textColor = [UIColor whiteColor];
        labelTwo.font = [UIFont systemFontOfSize:16];
        labelTwo.textAlignment = NSTextAlignmentRight;
        labelTwo.text = titleTwo;
        labelTwo.alpha = 0.0;
        [self addSubview:labelTwo];
        
        cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(frame.size.width - 76, frame.size.height - 121 - bottomSafeAreaHeight+ kTabBarHeight - yOffset, 60, 60);
        cancelButton.backgroundColor = color;
        cancelButton.layer.cornerRadius = cancelButton.frame.size.width / 2;
        [cancelButton setImage:[UIImage imageNamed:@"WhitePlus"] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(tapDetected) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];

        // Animate the background and the buttons
        [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
            
            // Grow the backgound and rotate the cancel button
            self->backgroundCircleView.transform = CGAffineTransformMakeScale(50.0, 50.0);
            self->backgroundCircleView.alpha = 1.0;
            self->cancelButton.transform = CGAffineTransformMakeRotation(3.14 / 4.0);
            
            // Blend the labels in
            self->labelOne.alpha = 1.0;
            self->labelTwo.alpha = 1.0;
            self->labelZero.alpha = 1.0;
            
            // Overshoot the animation
            float overShoot = -15.0;
            self->buttonZero.transform = CGAffineTransformMakeTranslation(0.0, -188.0 + overShoot);
            self->buttonOne.transform = CGAffineTransformMakeTranslation(0.0, -128.0 + overShoot);
            self->buttonTwo.transform = CGAffineTransformMakeTranslation(0.0, -68.0 + overShoot);
            self->labelZero.transform = CGAffineTransformMakeTranslation(0.0, -189.0 + overShoot);
            self->labelOne.transform = CGAffineTransformMakeTranslation(0.0, -129.0 + overShoot);
            self->labelTwo.transform = CGAffineTransformMakeTranslation(0.0, -69.0 + overShoot);
        
        } completion:^(BOOL finished){
            
            [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
                
                // Undershoot the animation
                float underShoot = 5.0;
                self->buttonZero.transform = CGAffineTransformMakeTranslation(0.0, -188.0 + underShoot);
                self->buttonOne.transform = CGAffineTransformMakeTranslation(0.0, -128.0 + underShoot);
                self->buttonTwo.transform = CGAffineTransformMakeTranslation(0.0, -68.0 + underShoot);
                self->labelZero.transform = CGAffineTransformMakeTranslation(0.0, -189.0 + underShoot);
                self->labelOne.transform = CGAffineTransformMakeTranslation(0.0, -129.0 + underShoot);
                self->labelTwo.transform = CGAffineTransformMakeTranslation(0.0, -69.0 + underShoot);
                
            } completion:^(BOOL finished){
                
                [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
                    
                    // Finish the animation
                    self->buttonZero.transform = CGAffineTransformMakeTranslation(0.0, -188.0);
                    self->buttonOne.transform = CGAffineTransformMakeTranslation(0.0, -128.0);
                    self->buttonTwo.transform = CGAffineTransformMakeTranslation(0.0, -68.0);
                    self->labelZero.transform = CGAffineTransformMakeTranslation(0.0, -189.0);
                    self->labelOne.transform = CGAffineTransformMakeTranslation(0.0, -129.0);
                    self->labelTwo.transform = CGAffineTransformMakeTranslation(0.0, -69.0);
                    
                } completion:^(BOOL finished){
                    
                }];
                
            }];
            
         }];
        
    }
    return self;
}

#pragma mark - Tap Gesture Method

- (void)tapDetected
{
    [self closingAnimation:3];
}

#pragma mark - Button Methods

- (void)buttonZeroTouched
{
    [self closingAnimation:0];
}

- (void)buttonOneTouched
{
    [self closingAnimation:1];
}

- (void)buttonTwoTouched
{
    [self closingAnimation:2];
}

#pragma mark - Closing Animation Method

- (void)closingAnimation:(int)source
{
    [UIView animateWithDuration:0.33 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self->backgroundCircleView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        //backgroundCircleView.alpha = 0.5;
        self->cancelButton.transform = CGAffineTransformMakeRotation(0.0);
        self->buttonZero.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
        self->buttonOne.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
        self->buttonTwo.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
        self->labelZero.alpha = 0.0;
        self->labelZero.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
        self->labelOne.alpha = 0.0;
        self->labelOne.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
        self->labelTwo.alpha = 0.0;
        self->labelTwo.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    }
                     completion:^(BOOL finished)
     {
         switch (source)
         {
             case 0:
                 [self.delegate closeCustomTripleActionSheetAfterButtonZeroTouched];
                 break;
                 
             case 1:
                 [self.delegate closeCustomTripleActionSheetAfterButtonOneTouched];
                 break;
                 
             case 2:
                 [self.delegate closeCustomTripleActionSheetAfterButtonTwoTouched];
                 break;
                 
             case 3:
                 [self.delegate closeCustomTripleActionSheetAfterCancelButtonTouched];
                 break;
                 
             default:
                 break;
         }
         
     }];
}

@end
