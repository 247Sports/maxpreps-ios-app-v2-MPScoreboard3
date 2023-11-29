//
//  DTBDebugProperties.h
//  DTBiOSSDK
//
//  Created by Amazon Publisher Services on 9/12/20.
//  Copyright © 2020 amazon.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DTBDebugProperties : NSObject

// Test flag to test out or enable SKAdnetwork response
@property (nonatomic) BOOL skadnTestMode;

+ (BOOL)isDebugFlagTurnedOnForFeature:(NSString *)feature;

@end

NS_ASSUME_NONNULL_END
