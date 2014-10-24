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
    if (year) {
        _year = [self formatDate:year];
    } else {
        _year = NSLocalizedString(@"Unknown", "Year: Unknown");
    }
}

- (void)setAuthor:(NSString *)author
{
    if (author) {
        _author = author;
    } else {
        _author = NSLocalizedString(@"Unknown", "Author: Unknown");
    }
}

- (void)setPublisher:(NSString *)publisher
{
    if (publisher) {
        _publisher = publisher;
    } else {
        _publisher = NSLocalizedString(@"Unknown", "Publisher: Unknown");
    }
}

- (void)setPages:(NSNumber *)pages
{
    if (pages) {
        _pages = pages;
    } else {
        _pages = [NSNumber numberWithChar:0];
    }
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

- (void)setBookDescription:(NSString *)bookDescription
{
    if (bookDescription) {
        _bookDescription = bookDescription;
    } else {
        _bookDescription = NSLocalizedString(@"No description available.", "Description: Unknown");
    }
}

#pragma mark - ISO 639-1 Conversion

+ (NSDictionary *)ISOMap
{
    static NSDictionary *_language = nil;
    if (!_language) {
        _language = @{
                     @"en" : NSLocalizedString(@"English", @"Converter: en"),
                     @"fr" : NSLocalizedString(@"French", @"Converter: fr"),
                     @"de" : NSLocalizedString(@"German", @"Converter: de"),
                     @"it" : NSLocalizedString(@"Italian", @"Converter: it"),
                     @"es" : NSLocalizedString(@"Spanish", @"Converter: es"),
                     @"zh" : NSLocalizedString(@"Chinese", @"Converter: zh"),
                     @"ja" : NSLocalizedString(@"Japanese", @"Converter: ja"),
                     @"sv" : NSLocalizedString(@"Swedish", @"Converter: sv"),
                     @"da" : NSLocalizedString(@"Danish", @"Converter: da"),
                     @"no" : NSLocalizedString(@"Norwegian", @"Converter: no")
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
    if (!numberFormatter) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    }
    return [numberFormatter numberFromString:number];
}

@end
