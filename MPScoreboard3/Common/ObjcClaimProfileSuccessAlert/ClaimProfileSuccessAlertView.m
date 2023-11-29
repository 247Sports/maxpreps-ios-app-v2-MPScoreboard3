//
//  ClaimProfileSuccesAlertView.m
//  CBS-iOS
//
//  Created by David Smith on 6/16/23.
//  Copyright © 2023 MaxPreps. All rights reserved.
//

#import "ClaimProfileSuccessAlertView.h"

@implementation ClaimProfileSuccessAlertView
@synthesize delegate;

#pragma mark - Init Methods

- (id)initWithFrame:(CGRect)frame message:(NSString *)message
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        blackBackgroundView = [[UIView alloc]initWithFrame:frame];
        blackBackgroundView.backgroundColor = [UIColor blackColor];
        blackBackgroundView.alpha = 0.0;
        [self addSubview:blackBackgroundView];
        
        if (message.length > 0)
        {
            roundRectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 208)];
        }
        else
        {
            roundRectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 168)];
        }
        roundRectView.center = self.center;
        roundRectView.backgroundColor = [UIColor whiteColor];
        roundRectView.layer.cornerRadius = 12;
        roundRectView.clipsToBounds = YES;
        roundRectView.transform = CGAffineTransformMakeTranslation(0, (frame.size.height / 2) + 104);
        [self addSubview:roundRectView];
        
        UIImageView *successImage = [[UIImageView alloc]initWithFrame:CGRectMake(((roundRectView.frame.size.width - 32) / 2), 20, 32, 32)];
        [successImage setImage:[UIImage imageNamed:@"ClaimedProfileSuccessIcon"]];
        [roundRectView addSubview:successImage];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 62, 280, 26)];
        titleLabel.text = @"You've Claimed A Profile!";
        titleLabel.font = [UIFont fontWithName:@"siro-semibold" size:20.0];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [roundRectView addSubview:titleLabel];
        
        if (message.length > 0)
        {
            UILabel *subtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 94, 270, 44)];
            subtitleLabel.numberOfLines = 2;
            subtitleLabel.text = message;
            subtitleLabel.font = [UIFont fontWithName:@"siro-regular" size:16.0];
            subtitleLabel.adjustsFontSizeToFitWidth = YES;
            subtitleLabel.minimumScaleFactor = 0.5;
            subtitleLabel.textColor = [UIColor darkGrayColor];
            subtitleLabel.textAlignment = NSTextAlignmentCenter;
            [roundRectView addSubview:subtitleLabel];
        }
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (message.length > 0)
        {
            doneButton.frame = CGRectMake(20, 154, 280, 32);
        }
        else
        {
            doneButton.frame = CGRectMake(20, 114, 280, 32);
        }
        doneButton.backgroundColor = [UIColor blackColor];
        doneButton.titleLabel.font = [UIFont fontWithName:@"siro-semibold" size:16.0];
        [doneButton setTitle:@"Close" forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        doneButton.layer.cornerRadius = 8;
        doneButton.clipsToBounds = YES;
        [doneButton addTarget:self action:@selector(doneButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [roundRectView addSubview:doneButton];
        
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

- (void)doneButtonTouched
{
    [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self->blackBackgroundView.alpha = 0.0;
        self->roundRectView.transform = CGAffineTransformMakeTranslation(0, (self.frame.size.height / 2) + 104);
    }
                     completion:^(BOOL finished)
     {
         [self.delegate closeClaimProfileSuccessAlertAfterDoneButtonTouched];
     }];
}

@end
