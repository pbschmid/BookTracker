//
//  PBSTextViewController.m
//  BookTracker
//
//  Created by Philippe Schmid on 22.10.14.
//  Copyright (c) 2014 Philippe Schmid. All rights reserved.
//

#import "PBSTextViewController.h"

@interface PBSTextViewController () <UINavigationControllerDelegate>

@end

@implementation PBSTextViewController

#pragma mark - Initializers

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationController.delegate = self;
    }
    return self;
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeNavigationBar];
    UITextView *textView = (UITextView *)[self.view viewWithTag:1000];
    textView.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:0.8f];
    textView.text = self.textToShow;
}

- (void)customizeNavigationBar
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:1.0f];
    titleLabel.text = NSLocalizedString(@"Description", @"Navigation: Title");
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
