//
//  ZipCodeHelper.h
//  MPScoreboard
//
//  Created by David Smith on 5/11/15.
//  Modified on 3/1/21
//  Copyright (c) 2015 MaxPreps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZipCodeHelper : NSObject

+ (NSString *)stateForZipCode:(NSString *)zipCode;
+ (NSDictionary *)locationForZipCode:(NSString *)zipCode;

+ (NSDictionary *)locationForAd;

@end
