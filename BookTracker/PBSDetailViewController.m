//
//  PBSDetailViewController.m
//  BookTracker
//
//  Created by Philippe Schmid on 15.10.14.
//  Copyright (c) 2014 Philippe Schmid. All rights reserved.
//

#import "PBSDetailViewController.h"
#import "MBProgressHUD.h"
#import "PBSBook.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface PBSDetailViewController () <UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UIImageView *coverImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *pagesLabel;
@property (nonatomic, weak) IBOutlet UILabel *publisherLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@end

@implementation PBSDetailViewController

#pragma mark - Initializers

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.navigationController.delegate = self;
    }
    return self;
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:1.0f];
    titleLabel.text = @"BookDetail";
    [titleLabel sizeToFit];
    
    self.navigationItem.titleView = titleLabel;
    
    [self configureTableViewCells];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - Customization

- (void)configureTableViewCells
{
    [self.coverImageView setImageWithURL:[NSURL URLWithString:self.bookResult.imageLink]];
    self.coverImageView.layer.cornerRadius = 10.0f;
    self.coverImageView.clipsToBounds = YES;
    
    self.descriptionTextView.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f
                                                          blue:19/255.0f alpha:0.8f];
    self.publisherLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f
                                                     blue:19/255.0f alpha:0.8f];
    
    self.titleLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:1.0f];
    self.authorLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:1.0f];
    self.pagesLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:0.8f];
    self.dateLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:0.8f];
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@", self.bookResult.title];
    self.authorLabel.text = [NSString stringWithFormat:@"%@", self.bookResult.authors];
    self.pagesLabel.text = [NSString stringWithFormat:@"%@", self.bookResult.pages];
    self.dateLabel.text = [NSString stringWithFormat:@"%@", self.bookResult.publishedDate];
    self.publisherLabel.text = [NSString stringWithFormat:@"%@", self.bookResult.publisher];
    self.descriptionTextView.text = [NSString stringWithFormat:@"%@", self.bookResult.description];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
