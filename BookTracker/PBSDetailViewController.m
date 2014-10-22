//
//  PBSDetailViewController.m
//  BookTracker
//
//  Created by Philippe Schmid on 15.10.14.
//  Copyright (c) 2014 Philippe Schmid. All rights reserved.
//

#import "PBSDetailViewController.h"
#import "PBSSearchViewController.h"
#import "PBSListViewController.h"
#import "PBSWebViewController.h"
#import "MBProgressHUD.h"
#import "PBSBookResult.h"
#import "PBSBook.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

static NSString * const ManagedObjectContextSaveDidFailNotification =
                        @"ManagedObjectContextSaveDidFailNotification";

@interface PBSDetailViewController () <UINavigationControllerDelegate, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UIImageView *coverImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *pagesLabel;
@property (nonatomic, weak) IBOutlet UILabel *publisherLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *languageLabel;
@property (nonatomic, weak) IBOutlet UILabel *ratingLabel;
@property (nonatomic, weak) IBOutlet UILabel *previewLabel;

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
    
    [self configureView];
}

#pragma mark - Customization

- (void)configureView
{
    self.coverImageView.layer.cornerRadius = 10.0f;
    self.coverImageView.clipsToBounds = YES;
    [self customizeAppearance];
    
    if (!self.savedBook) {
        
        [self configureViewForLoadedBook];
        
    } else {
        
        [self configureViewForSavedBook];
    }
}

- (void)customizeAppearance
{
    self.descriptionTextView.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f
                                                          blue:19/255.0f alpha:0.8f];
    self.publisherLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f
                                                     blue:19/255.0f alpha:0.8f];
    
    self.titleLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:1.0f];
    self.authorLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:1.0f];
    self.pagesLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:0.8f];
    self.dateLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:0.8f];
    self.ratingLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:0.8f];
    self.previewLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f
                                                   blue:19/255.0f alpha:0.8f];
    self.languageLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f
                                                    blue:19/255.0f alpha:0.8f];
}

- (void)configureViewForLoadedBook
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(save)];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [self.coverImageView setImageWithURL:[NSURL URLWithString:self.bookResult.imageLink]];
    self.titleLabel.text = [NSString stringWithFormat:@"%@", self.bookResult.title];
    self.authorLabel.text = [NSString stringWithFormat:@"%@", self.bookResult.author];
    self.pagesLabel.text = [NSString stringWithFormat:@"%@ pages", self.bookResult.pages];
    self.publisherLabel.text = [NSString stringWithFormat:@"%@", self.bookResult.publisher];
    self.descriptionTextView.text = [NSString stringWithFormat:@"%@", self.bookResult.bookDescription];
    self.dateLabel.text = [NSString stringWithFormat:@"%@", self.bookResult.year];
    self.languageLabel.text = [NSString stringWithFormat:@"%@", self.bookResult.language];
    self.previewLabel.text = [NSString stringWithFormat:@"More on %@", self.bookResult.title];
    self.ratingLabel.text = [NSString stringWithFormat:@"Rating: %@/5 (%@ ratings)",
                             self.bookResult.rating, self.bookResult.numberOfRatings];
}

- (void)configureViewForSavedBook
{
    [self.coverImageView setImageWithURL:[NSURL URLWithString:self.book.imageLink]];
    self.titleLabel.text = [NSString stringWithFormat:@"%@", self.book.title];
    self.authorLabel.text = [NSString stringWithFormat:@"%@", self.book.author];
    self.pagesLabel.text = [NSString stringWithFormat:@"%@ pages", self.book.pages];
    self.publisherLabel.text = [NSString stringWithFormat:@"%@", self.book.publisher];
    self.descriptionTextView.text = [NSString stringWithFormat:@"%@", self.book.bookDescription];
    self.dateLabel.text = [NSString stringWithFormat:@"%@", self.book.year];
    self.languageLabel.text = [NSString stringWithFormat:@"%@", self.book.language];
    self.previewLabel.text = [NSString stringWithFormat:@"More on %@", self.book.title];
    self.ratingLabel.text = [NSString stringWithFormat:@"Rating: %@/5 (%@ ratings)",
                             self.book.rating, self.book.ratingNumber];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        if (!self.savedBook) {
            [self performSegueWithIdentifier:@"Preview" sender:self.bookResult.previewLink];
        } else {
            [self performSegueWithIdentifier:@"Preview" sender:self.book.previewLink];
        }
    }
}

#pragma mark - Navigation

- (void)dismissViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Preview"]) {
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:nil
                                                                                action:nil];
        
        PBSWebViewController *webVC = (PBSWebViewController *)segue.destinationViewController;
        webVC.urlString = (NSString *)sender;
    }
}

#pragma mark - Core Data

- (void)save
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Saving...";
    [hud show:YES];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSLog(@"Saving: %@", self.bookResult.title);
    
    PBSBook *book = [NSEntityDescription insertNewObjectForEntityForName:@"PBSBook"
                                                          inManagedObjectContext:self.managedObjectContext];
    book.title = self.bookResult.title;
    book.subtitle = self.bookResult.subtitle;
    book.author = self.bookResult.author;
    book.publisher = self.bookResult.publisher;
    book.bookDescription = self.bookResult.bookDescription;
    book.year = self.bookResult.year;
    book.imageLink = self.bookResult.imageLink;
    book.previewLink = self.bookResult.previewLink;
    book.language = self.bookResult.language;
    
    book.pages = self.bookResult.pages;
    book.rating = self.bookResult.rating;
    book.ratingNumber = self.bookResult.numberOfRatings;
    book.isbn10 = self.bookResult.ISBN10;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error Saving Objects: %@", [error localizedDescription]);
        [[NSNotificationCenter defaultCenter] postNotificationName:
                                              ManagedObjectContextSaveDidFailNotification object:nil];
        return;
    }
    
    [self performSelector:@selector(dismissViewController)
               withObject:nil
               afterDelay:1];
    
    [hud hide:YES afterDelay:1];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
