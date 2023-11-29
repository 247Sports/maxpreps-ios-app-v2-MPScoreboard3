//
//  TagAthleteAlertView.m
//  CBS-iOS
//
//  Created by David Smith on 10/13/22.
//  Copyright © 2022 MaxPreps. All rights reserved.
//

#import "TagAthleteAlertView.h"

@implementation TagAthleteAlertView
@synthesize delegate;

#pragma mark - Init Methods

- (id)initWithFrame:(CGRect)frame name:(NSString *)name
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        blackBackgroundView = [[UIView alloc]initWithFrame:frame];
        blackBackgroundView.backgroundColor = [UIColor blackColor];
        blackBackgroundView.alpha = 0.0;
        [self addSubview:blackBackgroundView];
        
        roundRectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 210)];
        roundRectView.center = self.center;
        roundRectView.backgroundColor = [UIColor whiteColor];
        roundRectView.layer.cornerRadius = 12;
        roundRectView.clipsToBounds = YES;
        roundRectView.transform = CGAffineTransformMakeTranslation(0, (frame.size.height / 2) + 105);
        [self addSubview:roundRectView];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(roundRectView.frame.size.width - 44, 4, 40, 40);
        [closeButton setImage:[UIImage imageNamed:@"CloseButtonGray"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(cancelButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [roundRectView addSubview:closeButton];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 42, 280, 24)];
        titleLabel.text = @"Tag Athlete";
        titleLabel.font = [UIFont fontWithName:@"siro-bold" size:20.0];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [roundRectView addSubview:titleLabel];
        
        NSString *subtitleText = [NSString stringWithFormat:@"Do you want to tag %@ in this video? It will be displayed on their profile.", name];
        
        
        UILabel *subtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 70, 270, 50)];
        subtitleLabel.numberOfLines = 2;
        subtitleLabel.text = subtitleText;
        subtitleLabel.font = [UIFont fontWithName:@"siro-regular" size:15.0];
        subtitleLabel.adjustsFontSizeToFitWidth = YES;
        subtitleLabel.minimumScaleFactor = 0.5;
        subtitleLabel.textColor = [UIColor blackColor];
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        [roundRectView addSubview:subtitleLabel];
         
        UIButton *selectAthleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectAthleteButton.frame = CGRectMake(30, 136, 256, 36);
        selectAthleteButton.backgroundColor = [UIColor darkGrayColor];
        selectAthleteButton.titleLabel.font = [UIFont fontWithName:@"siro-semibold" size:14.0];
        [selectAthleteButton setTitle:@"TAG THIS ATHLETE" forState:UIControlStateNormal];
        [selectAthleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        selectAthleteButton.layer.cornerRadius = 8;
        selectAthleteButton.clipsToBounds = YES;
        [selectAthleteButton addTarget:self action:@selector(selectAthleteButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [roundRectView addSubview:selectAthleteButton];

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
        self->roundRectView.transform = CGAffineTransformMakeTranslation(0, (self.frame.size.height / 2) + 105);
    }
                     completion:^(BOOL finished)
     {
         [self.delegate closeTagAthleteAlertAfterCancelButtonTouched];
     }];
    
}

- (void)selectAthleteButtonTouched
{
    [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self->blackBackgroundView.alpha = 0.0;
        self->roundRectView.transform = CGAffineTransformMakeTranslation(0, (self.frame.size.height / 2) + 105);
    }
                     completion:^(BOOL finished)
     {
         [self.delegate closeTagAthleteAlertAfterAthleteSelectButtonTouched];
     }];
}

@end
