//
//  PBSBookResult.m
//  BookTracker
//
//  Created by Philippe Schmid on 17.10.14.
//  Copyright (c) 2014 Philippe Schmid. All rights reserved.
//

#import "PBSBookResult.h"

@implementation PBSBookResult

#pragma mark - Accessors

- (void)setLanguage:(NSString *)language
{
    _language = [self convertISOCode:language];
}

- (void)setYear:(NSString *)year
{
    _year = [self formatDate:year];
}

- (void)setRating:(NSNumber *)rating
{
    if (rating) {
        _rating = rating;
    } else {
        _rating = [NSNumber numberWithInt:0];
    }
}

- (void)setNumberOfRatings:(NSNumber *)numberOfRatings
{
    if (numberOfRatings) {
        _numberOfRatings = numberOfRatings;
    } else {
        _numberOfRatings = [NSNumber numberWithInt:0];
    }
}

#pragma mark - ISO 639-1 Converter

+ (NSDictionary *)ISOMap
{
    static NSDictionary *_language = nil;
    if (!_language) {
        _language = @{
                     @"en" : @"English",
                     @"fr" : @"French",
                     @"de" : @"German",
                     @"it" : @"Italian",
                     @"es" : @"Spanish",
                     @"zh" : @"Chinese",
                     @"ja" : @"Japanese",
                     @"sv" : @"Swedish",
                     @"da" : @"Danish",
                     @"no" : @"Norwegian",
                     };
    }
    return _language;
}

- (NSString *)convertISOCode:(NSString *)code
{
    return [PBSBookResult ISOMap][code];
}

#pragma mark - Formatters

- (NSString *)formatDate:(NSString *)date
{
    return [date substringToIndex:4];
}

- (NSNumber *)formatNumber:(NSString *)number
{
    static NSNumberFormatter *numberFormatter = nil;
    if (numberFormatter == nil) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    }
    return [numberFormatter numberFromString:number];
}

@end
