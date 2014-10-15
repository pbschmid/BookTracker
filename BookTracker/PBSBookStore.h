//
//  PBSBookStore.h
//  BookTracker
//
//  Created by Philippe Schmid on 15.10.14.
//  Copyright (c) 2014 Philippe Schmid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PBSBookStore : NSObject

- (void)fetchResultsForText:(NSString *)text category:(NSInteger)category;

@end
