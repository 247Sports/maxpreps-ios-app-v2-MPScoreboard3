//
//  TagAthleteAlertView.h
//  CBS-iOS
//
//  Created by David Smith on 10/13/22.
//  Copyright © 2022 MaxPreps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TagAthleteAlertViewDelegate <NSObject>
@optional
- (void)closeTagAthleteAlertAfterCancelButtonTouched;
- (void)closeTagAthleteAlertAfterAthleteSelectButtonTouched;
@end



@interface TagAthleteAlertView : UIView
{
    UIView *blackBackgroundView;
    UIView *roundRectView;
        
    id <TagAthleteAlertViewDelegate>   delegate;
}

@property (nonatomic) id delegate;

- (id)initWithFrame:(CGRect)frame name:(NSString *)name;

@end
