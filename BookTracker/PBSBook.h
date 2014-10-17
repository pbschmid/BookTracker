//
//  PBSBook.h
//  BookTracker
//
//  Created by Philippe Schmid on 17.10.14.
//  Copyright (c) 2014 Philippe Schmid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PBSBook : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * publisher;
@property (nonatomic, retain) NSString * bookDescription;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSNumber * pages;
@property (nonatomic, retain) NSNumber * isbn;
@property (nonatomic, retain) NSString * imageLink;
@property (nonatomic, retain) NSString * previewLink;
@property (nonatomic, retain) NSString * author;

@end
