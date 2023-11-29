//
//  FeedsHelper.h
//  MPScoreboard2
//
//  Created by David Smith on 2/19/21.
//  Copyright © 2021 MaxPreps Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <MobileCoreServices/MobileCoreServices.h>

NS_ASSUME_NONNULL_BEGIN

@interface FeedsHelper : NSObject

+ (NSString *)getDateCode:(NSTimeInterval)utcOffset;
+ (NSString *)getHashCodeWithPassword:(NSString *)inputstr andDate:(NSString *)date;
+ (NSString *)generateBoundaryString;
+ (NSData *)createBodyWithBoundary:(NSString *)boundary parameters:(NSDictionary *)parameters path:(NSString *)path fieldName:(NSString *)fieldName;
+ (NSString *)mimeTypeForPath:(NSString *)path;
+ (NSString *)encryptString:(NSString *)input;
+ (NSData *)doCipher:(NSData *)plainText key:(NSString *)key iv:(NSString *)iv context:(CCOperation)encryptOrDecrypt;
+ (NSData *)decrypt:(NSData *)encryptedText key:(NSString *)key iv:(NSString *)iv;
+ (NSString *)sha256HashForText:(NSString*)text;
+ (NSString *)expandDictionaryIntoQueryString:(NSDictionary *)inputDict;
+ (NSString *)getRandomNumberString:(NSInteger)length;
+ (NSDictionary *)completeContextDataFromDictionary: (NSDictionary *)inputDictionary;
+ (BOOL)validateEmail:(NSString*)email;

@end

NS_ASSUME_NONNULL_END
