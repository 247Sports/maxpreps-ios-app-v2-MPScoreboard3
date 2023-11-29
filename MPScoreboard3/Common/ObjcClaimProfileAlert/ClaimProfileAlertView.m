//
//  ClaimProfileAlertView.m
//  CBS-iOS
//
//  Created by David Smith on 11/4/21.
//  Copyright © 2021 MaxPreps. All rights reserved.
//
//  This class has two different inits. One has one or two buttons (parent or athlete + parent). The other has just one button (parent or athlete)

#import "ClaimProfileAlertView.h"

@implementation ClaimProfileAlertView
@synthesize delegate;

#pragma mark - Init Methods

- (id)initWithFrame:(CGRect)frame color:(UIColor *)color name:(NSString *)name parentOnly:(Boolean)parentOnly
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        blackBackgroundView = [[UIView alloc]initWithFrame:frame];
        blackBackgroundView.backgroundColor = [UIColor blackColor];
        blackBackgroundView.alpha = 0.0;
        [self addSubview:blackBackgroundView];
        
        int height = 356;
        
        if (parentOnly)
        {
            height = 322;
        }
        
        roundRectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, height)];
        roundRectView.center = self.center;
        roundRectView.backgroundColor = [UIColor whiteColor];
        roundRectView.layer.cornerRadius = 12;
        roundRectView.clipsToBounds = YES;
        roundRectView.transform = CGAffineTransformMakeTranslation(0, (frame.size.height / 2) + 190);
        [self addSubview:roundRectView];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(roundRectView.frame.size.width - 44, 4, 40, 40);
        [closeButton setImage:[UIImage imageNamed:@"CloseButtonGray"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(cancelButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [roundRectView addSubview:closeButton];
        
        UIImageView *calendarImage = [[UIImageView alloc]initWithFrame:CGRectMake(((roundRectView.frame.size.width - 84) / 2), 62, 84, 84)];
        [calendarImage setImage:[UIImage imageNamed:@"ClaimedProfileIconLarge"]];
        [roundRectView addSubview:calendarImage];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 162, 280, 24)];
        titleLabel.text = @"Confirmation";
        titleLabel.font = [UIFont fontWithName:@"siro-bold" size:20.0];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [roundRectView addSubview:titleLabel];
        
        NSString *subtitleText = [NSString stringWithFormat:@"To claim this profile, please confirm\nyour relationship to %@.", name];
        
        if (parentOnly)
        {
            subtitleText = [NSString stringWithFormat:@"To claim this profile, please confirm\n %@ is your child.", name];
        }
        
        UILabel *subtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 190, 270, 50)];
        subtitleLabel.numberOfLines = 2;
        subtitleLabel.text = subtitleText;
        subtitleLabel.font = [UIFont fontWithName:@"siro-regular" size:15.0];
        subtitleLabel.adjustsFontSizeToFitWidth = YES;
        subtitleLabel.minimumScaleFactor = 0.5;
        subtitleLabel.textColor = [UIColor blackColor];
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        [roundRectView addSubview:subtitleLabel];
        
        UIColor *mpRedColor = [UIColor colorWithRed:225.0/255.0 green:5.0/255.0 blue:0.0 alpha:1];
        
        if (!parentOnly)
        {
            UIButton *selectAthleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            selectAthleteButton.frame = CGRectMake(30, 256, 260, 36);
            selectAthleteButton.backgroundColor = mpRedColor;
            selectAthleteButton.titleLabel.font = [UIFont fontWithName:@"siro-semibold" size:14.0];
            [selectAthleteButton setTitle:@"YES, THIS IS ME!" forState:UIControlStateNormal];
            [selectAthleteButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            selectAthleteButton.layer.cornerRadius = 8;
            selectAthleteButton.clipsToBounds = YES;
            [selectAthleteButton addTarget:self action:@selector(selectAthleteButtonTouched) forControlEvents:UIControlEventTouchUpInside];
            [roundRectView addSubview:selectAthleteButton];
        }
        
        int yStart = 300;
        if (parentOnly)
        {
            yStart = 256;
        }
        UIButton *selectParentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectParentButton.frame = CGRectMake(30, yStart, 260, 36);
        selectParentButton.backgroundColor = [UIColor clearColor];
        selectParentButton.titleLabel.font = [UIFont fontWithName:@"siro-semibold" size:14.0];
        [selectParentButton setTitle:@"THIS IS MY CHILD" forState:UIControlStateNormal];
        [selectParentButton setTitleColor:mpRedColor forState:UIControlStateNormal];
        selectParentButton.layer.cornerRadius = 8;
        selectParentButton.layer.borderColor = mpRedColor.CGColor;
        selectParentButton.layer.borderWidth = 1.0;
        selectParentButton.clipsToBounds = YES;
        [selectParentButton addTarget:self action:@selector(selectParentButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [roundRectView addSubview:selectParentButton];
        
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

- (id)initWithFrame:(CGRect)frame color:(UIColor *)color name:(NSString *)name isParent:(Boolean)isParent
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        blackBackgroundView = [[UIView alloc]initWithFrame:frame];
        blackBackgroundView.backgroundColor = [UIColor blackColor];
        blackBackgroundView.alpha = 0.0;
        [self addSubview:blackBackgroundView];
        
        roundRectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 350)];
        roundRectView.center = self.center;
        roundRectView.backgroundColor = [UIColor whiteColor];
        roundRectView.layer.cornerRadius = 12;
        roundRectView.clipsToBounds = YES;
        roundRectView.transform = CGAffineTransformMakeTranslation(0, (frame.size.height / 2) + 175);
        [self addSubview:roundRectView];
        
        /*
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(roundRectView.frame.size.width - 44, 4, 40, 40);
        [closeButton setImage:[UIImage imageNamed:@"CloseButtonGray"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(cancelButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [roundRectView addSubview:closeButton];
        */
        
        UIImageView *calendarImage = [[UIImageView alloc]initWithFrame:CGRectMake(((roundRectView.frame.size.width - 84) / 2), 32, 84, 84)];
        [calendarImage setImage:[UIImage imageNamed:@"ClaimedProfileIconLarge"]];
        [roundRectView addSubview:calendarImage];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 132, 280, 24)];
        titleLabel.text = @"Claim this Profile?";
        titleLabel.font = [UIFont fontWithName:@"siro-bold" size:20.0];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [roundRectView addSubview:titleLabel];
        
        NSString *subtitleText = [NSString stringWithFormat:@"To claim this profile, please confirm that you are %@.", name];
        
        if (isParent)
        {
            subtitleText = [NSString stringWithFormat:@"To claim this profile, please confirm\n %@ is your child.", name];
        }
        
        UILabel *subtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 160, 270, 50)];
        subtitleLabel.numberOfLines = 2;
        subtitleLabel.text = subtitleText;
        subtitleLabel.font = [UIFont fontWithName:@"siro-regular" size:15.0];
        subtitleLabel.adjustsFontSizeToFitWidth = YES;
        subtitleLabel.minimumScaleFactor = 0.5;
        subtitleLabel.textColor = [UIColor blackColor];
        subtitleLabel.textAlignment = NSTextAlignmentCenter;
        [roundRectView addSubview:subtitleLabel];
        
        UIColor *mpRedColor = [UIColor colorWithRed:225.0/255.0 green:5.0/255.0 blue:0.0 alpha:1];

        if (isParent)
        {
            UIButton *selectParentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            selectParentButton.frame = CGRectMake(30, 226, 256, 36);
            selectParentButton.backgroundColor = color;
            selectParentButton.titleLabel.font = [UIFont fontWithName:@"siro-semibold" size:14.0];
            [selectParentButton setTitle:@"THIS IS MY CHILD" forState:UIControlStateNormal];
            [selectParentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            selectParentButton.layer.cornerRadius = 8;
            selectParentButton.clipsToBounds = YES;
            [selectParentButton addTarget:self action:@selector(selectParentButtonTouched) forControlEvents:UIControlEventTouchUpInside];
            [roundRectView addSubview:selectParentButton];
        }
        else
        {
            UIButton *selectAthleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            selectAthleteButton.frame = CGRectMake(30, 226, 256, 36);
            selectAthleteButton.backgroundColor = color;
            selectAthleteButton.titleLabel.font = [UIFont fontWithName:@"siro-semibold" size:14.0];
            [selectAthleteButton setTitle:@"YES, THIS IS ME!" forState:UIControlStateNormal];
            [selectAthleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            selectAthleteButton.layer.cornerRadius = 8;
            selectAthleteButton.clipsToBounds = YES;
            [selectAthleteButton addTarget:self action:@selector(selectAthleteButtonTouched) forControlEvents:UIControlEventTouchUpInside];
            [roundRectView addSubview:selectAthleteButton];
        }
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(30, 278, 256, 36);
        cancelButton.backgroundColor = [UIColor clearColor];
        cancelButton.titleLabel.font = [UIFont fontWithName:@"siro-semibold" size:14.0];
        [cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
        [cancelButton setTitleColor:mpRedColor forState:UIControlStateNormal];
        cancelButton.layer.cornerRadius = 8;
        cancelButton.layer.borderWidth = 1;
        cancelButton.layer.borderColor = mpRedColor.CGColor;
        cancelButton.clipsToBounds = YES;
        [cancelButton addTarget:self action:@selector(cancelButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [roundRectView addSubview:cancelButton];
        
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
        self->roundRectView.transform = CGAffineTransformMakeTranslation(0, (self.frame.size.height / 2) + 175);
    }
                     completion:^(BOOL finished)
     {
         [self.delegate closeClaimProfileAlertAfterCancelButtonTouched];
     }];
    
}

- (void)selectAthleteButtonTouched
{
    [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self->blackBackgroundView.alpha = 0.0;
        self->roundRectView.transform = CGAffineTransformMakeTranslation(0, (self.frame.size.height / 2) + 175);
    }
                     completion:^(BOOL finished)
     {
         [self.delegate closeClaimProfileAlertAfterAthleteSelectButtonTouched];
     }];
}

- (void)selectParentButtonTouched
{
    [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self->blackBackgroundView.alpha = 0.0;
        self->roundRectView.transform = CGAffineTransformMakeTranslation(0, (self.frame.size.height / 2) + 175);
    }
                     completion:^(BOOL finished)
     {
         [self.delegate closeClaimProfileAlertAfterParentSelectButtonTouched];
     }];
}

@end
