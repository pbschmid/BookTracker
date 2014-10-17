//
//  PBSDetailViewController.h
//  BookTracker
//
//  Created by Philippe Schmid on 15.10.14.
//  Copyright (c) 2014 Philippe Schmid. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBSBook;

@interface PBSDetailViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) PBSBook *bookResult;

@end
