//
//  ZipCodeHelper.m
//  MPScoreboard
//
//  Created by David Smith on 5/11/15.
//  Modified on 3/1/21
//  Copyright (c) 2015 MaxPreps. All rights reserved.
//

#import "ZipCodeHelper.h"

//#define kDefaultSchoolState @"AL"
#define kLatitudeKey @"Latitude"
#define kLongitudeKey @"Longitude"
// Oak Ridge
#define kDefaultSchoolLocation [NSDictionary dictionaryWithObjectsAndKeys:@"38.679866", kLatitudeKey, @"-121.070664", kLongitudeKey, nil]
#define kCurrentLocationKey @"CurrentLocation"
#define kUserZipKey @"Zip"

@implementation ZipCodeHelper

// MARK: - ZipCode Helpers

+ (NSString *)stateForZipCode:(NSString *)zipCode
{
    //NSString *state = @"";
    
    if ([zipCode length] == 0)
    {
        return @"";
    }

    // Use the one that was included in the bundle
    NSString *pathname = [[NSBundle mainBundle] pathForResource:@"ZipCodes" ofType:@"txt" inDirectory:@"/"];
    
    NSString *wordstring = [NSString stringWithContentsOfFile:pathname encoding:NSASCIIStringEncoding error:nil];
    
    NSMutableArray *wordArray = [[NSMutableArray alloc]initWithArray:[wordstring componentsSeparatedByString:@"\r\n"]];
    
    for (int i = 0; i < [wordArray count]; i++)
    {
        // The data is arranged as follows: ZipCode , State (short name), Latitude, Longitude
    
        NSArray *dataArray = [[wordArray objectAtIndex:i] componentsSeparatedByString:@","];
        
        if ([dataArray count] > 0)
        {
            NSString *aZipCode = [dataArray objectAtIndex:0];
            NSString *aState = [dataArray objectAtIndex:1];
            
            NSString *fiveDigitZipCode;
            
            if ([aZipCode length] == 3)
                fiveDigitZipCode = [NSString stringWithFormat:@"00%@", aZipCode];
            else if ([aZipCode length] == 4)
                fiveDigitZipCode = [NSString stringWithFormat:@"0%@", aZipCode];
            else
                fiveDigitZipCode = aZipCode;
            
            if ([fiveDigitZipCode isEqualToString:zipCode])
            {
                // Match found
                return aState;
            }
        }
        else
            // A problem exists with the CR-LF in the file so return ""
            return @"";
        
    }
        
    // Match wasn't found so return ""
    return @"";
}

+ (NSDictionary *)locationForZipCode:(NSString *)zipCode
{
    // Use the one that was included in the bundle
    NSString *pathname = [[NSBundle mainBundle] pathForResource:@"ZipCodes" ofType:@"txt" inDirectory:@"/"];
    
    NSString *wordstring = [NSString stringWithContentsOfFile:pathname encoding:NSASCIIStringEncoding error:nil];
    
    NSMutableArray *wordArray = [[NSMutableArray alloc]initWithArray:[wordstring componentsSeparatedByString:@"\r\n"]];
    
    for (int i = 0; i < [wordArray count]; i++)
    {
        // The data is arranged as follows: ZipCode , State (short name), Latitude, Longitude
        
        NSArray *dataArray = [[wordArray objectAtIndex:i] componentsSeparatedByString:@","];
        
        if ([dataArray count] > 0)
        {
            NSString *aZipCode = [dataArray objectAtIndex:0];
            NSString *aLatitude = [dataArray objectAtIndex:2];
            NSString *aLongitude = [dataArray objectAtIndex:3];
            
            NSString *fiveDigitZipCode;
            
            if ([aZipCode length] == 3)
                fiveDigitZipCode = [NSString stringWithFormat:@"00%@", aZipCode];
            else if ([aZipCode length] == 4)
                fiveDigitZipCode = [NSString stringWithFormat:@"0%@", aZipCode];
            else
                fiveDigitZipCode = aZipCode;
            
            if ([fiveDigitZipCode isEqualToString:zipCode])
            {
                // Match found
                return [NSDictionary dictionaryWithObjectsAndKeys:aLatitude, kLatitudeKey, aLongitude, kLongitudeKey, nil];
            }
        }
        else
            // A problem exists with the CR-LF in the file
            return kDefaultSchoolLocation;
        
    }
        
    // Match wasn't found so use kDefaultSchoolLocation (Abbevile, AL)
    return kDefaultSchoolLocation;
}

#pragma mark - Ad Location Helper

+ (NSDictionary *)locationForAd
{
    // Added in V4.9.0
    NSString *latitudeString = @"0.0";
    NSString *longitudeString = @"0.0";
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // Use the current location that came from the location
    NSDictionary *currentLocation = [prefs dictionaryForKey:kCurrentLocationKey];
    
    if ([currentLocation objectForKey:kLatitudeKey] && [currentLocation objectForKey:kLongitudeKey])
    {
        latitudeString = [currentLocation objectForKey:kLatitudeKey];
        longitudeString = [currentLocation objectForKey:kLongitudeKey];
    }
    
    // Override the location using the zip code that is already in prefs if it exists
    if ([[prefs objectForKey:kUserZipKey] length] > 0)
    {
        NSDictionary *currentLocationDictionary = [ZipCodeHelper locationForZipCode:[prefs objectForKey:kUserZipKey]];
        
        latitudeString = [currentLocationDictionary objectForKey:kLatitudeKey];
        longitudeString = [currentLocationDictionary objectForKey:kLongitudeKey];
    }
    
    NSDictionary *location;
    
    if ([latitudeString isEqualToString:@"0.0"] && [longitudeString isEqualToString:@"0.0"])
    {
        // If the location is still missing, use a random location from the following:
        /*
         New York 10001
         Los Angeles 90001
         Philadelphia 19092
         Dallas 75201
         Chicago 60601
         Boston 02108
         Minneapolis 55401
         Atlanta 30303
         Washington 20001
         Detroit 48201
         Denver 80012
         San Francisco 94102
         Houston 77002
         */
        NSArray *zipCodes = [NSArray arrayWithObjects:@"10001", @"90001", @"19092", @"75201", @"60601", @"02108", @"55401", @"30303", @"20001",@"48201",@"80012",@"94102",@"77002", nil];
        NSDate *now = [NSDate new];
        NSTimeInterval ticks = [now timeIntervalSinceReferenceDate];
        int tickInteger = ticks;
        int randomNumber = tickInteger % 13;
        
        NSDictionary *randomLocation;
        
        if (randomNumber < [zipCodes count])
            randomLocation = [ZipCodeHelper locationForZipCode:[zipCodes objectAtIndex:randomNumber]];
        else
            randomLocation = [ZipCodeHelper locationForZipCode:0];
        
        location = [NSDictionary dictionaryWithObjectsAndKeys:[randomLocation objectForKey:kLatitudeKey], kLatitudeKey, [randomLocation objectForKey:kLongitudeKey], kLongitudeKey, nil];
    }
    else
        location = [NSDictionary dictionaryWithObjectsAndKeys:latitudeString, kLatitudeKey, longitudeString, kLongitudeKey, nil];
    
    //NSLog(@"Latitude: %@, Longitude: %@", latitudeString, longitudeString);

    return location;
}

@end
