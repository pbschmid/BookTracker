//
//  PBSBookResult.h
//  BookTracker
//
//  Created by Philippe Schmid on 17.10.14.
//  Copyright (c) 2014 Philippe Schmid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBSBookResult : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *publisher;
@property (nonatomic, copy) NSString *bookDescription;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, strong) NSNumber *pages;
@property (nonatomic, strong) NSNumber *ISBN;
@property (nonatomic, copy) NSString *imageLink;
@property (nonatomic, copy) NSString *previewLink;
@property (nonatomic, strong) NSString *date;

@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *categories;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSNumber *numberOfRatings;

@end
