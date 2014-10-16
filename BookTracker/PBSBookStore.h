//
//  PBSBookStore.h
//  BookTracker
//
//  Created by Philippe Schmid on 15.10.14.
//  Copyright (c) 2014 Philippe Schmid. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionBlock)(BOOL finished, NSError *error);

@interface PBSBookStore : NSObject

@property (nonatomic, readonly, strong) NSMutableArray *bookResults;

- (void)fetchResultsForText:(NSString *)text category:(NSInteger)category completion:(CompletionBlock)block;

@end
