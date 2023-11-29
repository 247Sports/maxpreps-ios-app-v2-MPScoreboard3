//
//  OnboardingAlertView.m
//  CBS-iOS
//
//  Created by David Smith on 3/25/22.
//  Copyright © 2022 MaxPreps. All rights reserved.
//

#import "OnboardingAlertView.h"

@implementation OnboardingAlertView
@synthesize delegate;

#pragma mark - Init Methods

- (id)initWithFrame:(CGRect)frame color:(UIColor *)color title:(NSString *)title message:(NSString *)message topButtonTitle:(NSString *)topButtonTitle bottomButtonTitle:(NSString *)bottomButtonTitle
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        blackBackgroundView = [[UIView alloc]initWithFrame:frame];
        blackBackgroundView.backgroundColor = [UIColor blackColor];
        blackBackgroundView.alpha = 0.0;
        [self addSubview:blackBackgroundView];
        
        roundRectHeight = 242;
        if (![bottomButtonTitle isEqualToString: @""])
        {
            roundRectHeight = 290;
        }
        roundRectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, roundRectHeight)];
        roundRectView.center = self.center;
        roundRectView.backgroundColor = [UIColor whiteColor];
        roundRectView.layer.cornerRadius = 12;
        roundRectView.clipsToBounds = YES;
        roundRectView.transform = CGAffineTransformMakeTranslation(0, (frame.size.height / 2) + (roundRectHeight / 2));
        [self addSubview:roundRectView];
        
        /*
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(roundRectView.frame.size.width - 44, 4, 40, 40);
        [closeButton setImage:[UIImage imageNamed:@"CloseButtonGray"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(cancelButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [roundRectView addSubview:closeButton];
        */
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 40, roundRectView.frame.size.width - 40, 50)];
        titleLabel.numberOfLines = 2;
        titleLabel.text = title;
        titleLabel.font = [UIFont fontWithName:@"siro-bold" size:21.0];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.minimumScaleFactor = 0.5;
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [roundRectView addSubview:titleLabel];
        
        UILabel *subtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 100, roundRectView.frame.size.width - 40, 60)];
        subtitleLabel.numberOfLines = 3;
        subtitleLabel.text = message;
        subtitleLabel.font = [UIFont fontWithName:@"siro-regular" size:15.0];
        subtitleLabel.adjustsFontSizeToFitWidth = YES;
        subtitleLabel.minimumScaleFactor = 0.5;
        subtitleLabel.textColor = [UIColor blackColor];
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        [roundRectView addSubview:subtitleLabel];
        
        UIButton *topButton = [UIButton buttonWithType:UIButtonTypeCustom];
        topButton.frame = CGRectMake(24, 182, roundRectView.frame.size.width - 48, 36);
        topButton.backgroundColor = color;
        topButton.titleLabel.font = [UIFont fontWithName:@"siro-semibold" size:14.0];
        [topButton setTitle:topButtonTitle forState:UIControlStateNormal];
        [topButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        topButton.layer.cornerRadius = 8;
        topButton.clipsToBounds = YES;
        [topButton addTarget:self action:@selector(topButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [roundRectView addSubview:topButton];

        if (![bottomButtonTitle isEqualToString: @""])
        {
            UIButton *bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
            bottomButton.frame = CGRectMake(24, 230, roundRectView.frame.size.width - 48, 36);
            bottomButton.backgroundColor = [UIColor clearColor];
            bottomButton.titleLabel.font = [UIFont fontWithName:@"siro-semibold" size:14.0];
            [bottomButton setTitle:bottomButtonTitle forState:UIControlStateNormal];
            [bottomButton setTitleColor:color forState:UIControlStateNormal];
            bottomButton.layer.cornerRadius = 8;
            bottomButton.layer.borderWidth = 1;
            bottomButton.layer.borderColor = [color CGColor];
            bottomButton.clipsToBounds = YES;
            [bottomButton addTarget:self action:@selector(bottomButtonTouched) forControlEvents:UIControlEventTouchUpInside];
            [roundRectView addSubview:bottomButton];
        }
        
        
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
        self->roundRectView.transform = CGAffineTransformMakeTranslation(0, (self.frame.size.height / 2) + (self->roundRectHeight / 2));
    }
                     completion:^(BOOL finished)
     {
         [self.delegate closeOnboardingAlertAfterCancelButtonTouched];
     }];
    
}

- (void)topButtonTouched
{
    [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self->blackBackgroundView.alpha = 0.0;
        self->roundRectView.transform = CGAffineTransformMakeTranslation(0, (self.frame.size.height / 2) + (self->roundRectHeight / 2));
    }
                     completion:^(BOOL finished)
     {
         [self.delegate closeOnboardingAlertAfterTopButtonTouched];
     }];
}

- (void)bottomButtonTouched
{
    [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self->blackBackgroundView.alpha = 0.0;
        self->roundRectView.transform = CGAffineTransformMakeTranslation(0, (self.frame.size.height / 2) + (self->roundRectHeight / 2));
    }
                     completion:^(BOOL finished)
     {
         [self.delegate closeOnboardingAlertAfterBottomButtonTouched];
     }];
}

@end
